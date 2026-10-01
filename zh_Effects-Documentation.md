# 特效脚本 API

<!-- @tokens: look matrix hslaMatrix table curve blend lighting highContrast srgbToLinear linearToSrgb identity compose lerp colorShader shader focusBlur lut blur dilate erode magnifier convolution displacement -->

一个效果 = 一段脚本：`return` 一个**步骤数组**，每步写成 `{ token = 参数 }`，
数组顺序 = 叠加顺序（后者看到前者的结果）。

脚本有两个来源，**写法和能力完全一样**，区别只在源码放哪、id 长什么样：

| 来源 | 源码 | id |
|---|---|---|
| 内置（默认菜单里的 8 个） | 程序里（`Feature/Image/Effects/Scripting/BuiltInEffectScripts.cs`） | `<lomo>`、`<invert>` |
| 外部 | `data/effects/<名字>.lua`（可带子文件夹） | `test`、`demo/magnifier` |

两条入口都能用：把 id 写进命令 / 菜单 / 快捷键（字符串语法见 1.4），或把 `data/effects` 里的 `.lua`
直接拖进窗口（拖拽时**落点即焦点**，改过的内容也会重读重编译，见 §6）。
调色文件 `.cube` 同样可以拖，且不限路径（见 `lut` 一节）。

> id 的完整规则 —— 后缀 `.lua`、前缀 `./`、反斜杠的容错，以及内置 id 为什么写成 `<名字>` ——
> 在 `EffectScripts.NormalizeId`、`EffectKeys`、`EffectScripts.TryGetIdFromPath` 的注释里，本文档不重复。

本文档是 token 的**唯一权威说明**：签名、参数（类型 / 默认 / 取值范围）、例子、对应的 Skia API。
带「实测」的数字由 `Tests/Vii3.Tests/ImageEffectTests.cs` 的 `Semantics_*` 用例钉住（改坏会红）。

---

## 1. 模块与全局约定

```lua
effect ::= return { step, ... }
step   ::= { token = 参数 } | { token = true } | { token = "单参数字符串" }
```

| 约定 | 值 |
|---|---|
| 颜色分量 | `0..1` 浮点，非预乘 |
| 矩阵（`matrix` / `hslaMatrix`）平移列 | `0..1`（"抬黑位 8/255" 写 `0.031`） |
| `table` 表项 | `0..255` 整数 |
| `curve` 控制点 | `x`、`y` 都是 `0..1`（`x` = 输入亮度、`y` = 输出亮度） |
| 颜色字面量 | `0..255`：`0xRRGGBB` / `"#RRGGBB"` / `{r,g,b}`（可带第 4 个 alpha） |
| 运算所在色彩空间 | **目标（surface）色彩空间**（Skia 默认）；例外：`highContrast` 在线性光里算 |
| 逐像素 / 空间 | 逐像素 = 只看当前像素（分块结果一致）；空间 = 需要坐标或邻居像素（见 `shader`） |
| 脚本解析 | 首次用到时解析一次，之后按路径缓存；**改了内容要重启**，或把文件拖进窗口（见 §6） |
| 脚本预算 | 求值最长 **300ms**（特效文件是数据，正常几十微秒；超时报"求值超时"） |
| 可用 Lua | `--` 注释、`local`、`for/if`、`math.*`、`string.*`、`table.*` |
| 不可用 | `require` / `io` / `os`（沙箱未开放） |

---

### 1.1 头部声明 `-- @key value`

写在文件开头（前 80 行内）。格式固定、由引擎解析并校验（未知键 / 非法值会记一条日志），不是随手注释。

| 键 | 值 | 作用 |
|---|---|---|
| `@name` | 文本 | 描述名：外部脚本的显示名用它 |
| `@author` | 文本 | 作者 / 出处（描述式，不进语言文件） |
| `@desc` | 文本 | 一句话说明（描述式，同上） |
| `@version` | 文本 | 脚本自己的版本号（与程序版本无关） |
| `@builtin` | `yes` / `no` | 内置效果的自述；内置的**判据是 id 形状**（见开头），不是这个声明 |
| `@needs` | `pointer` / `zoom` / `none` | 运行期需要什么，见 1.2。不写则回退到"看程序里有没有这些 uniform" |
| `@oneshot` | `yes` / `no` | 一次性：效果针对当前图上的某个目标（鱼眼 / 聚焦），换图应清掉。`yes` 优先于用户的"切换文件时的特效"设置 |
| `@param` | `名字 默认 [最小] [最大] [说明…]` | 自己声明的可调参数，见 1.4 |

```lua
-- @name     放大镜
-- @author   vii3
-- @desc     指针处一圈放大
-- @version  1.0
-- @builtin  no
-- @needs    pointer, zoom
-- @oneshot  yes
```

显示名从哪取（`EffectCatalog.DisplayName`，调用方只传 id）：

| id | 显示名 |
|---|---|
| `<名字>`（内置） | 语言词条 `Effect.<名字>`（键里不带尖括号：`<invert>` ⇒ `Effect.invert`） |
| 目录里的 id（外部） | `@name` |
| 对不上任何脚本 | id 本身 |
| 空 id（"不套效果"） | `Effect.None` |

`@desc` / `@author` / `@version` 只是描述，永不进语言文件。

> 声明只能写"效果关于自身的事实"（需要什么、是不是挑目标）；进不进菜单、挂不挂快捷键是调用方的策略 ——
> 脚本不承担语言 / 菜单 / 快捷键的职责。

### 1.2 运行期 uniform（指针类效果）

空间 `shader` 里可以声明下面这些 uniform，引擎在**调用那一刻**把真值填进去：

| uniform | 类型 | 引擎填什么 |
|---|---|---|
| `uFocus` | `float2` | 指针在**源图**上的归一化坐标（`0..1`）。取点走画布唯一那套换算（小地图优先、含旋转与镜像） |
| `uPointer` | `float` | `1` = 有指针、`0` = 没有（事件被吞 / 从菜单调用）⇒ 用 `mix(默认焦点, uFocus, uPointer)` 决定跟不跟 |
| `uZoom` | `float` | 画布缩放倍率（`0.1~10`） |
| `uImageSize` / `uSrcOrigin` / `uSrcScale` / `uDstOrigin` | | 坐标换算：`imgPx = uSrcOrigin + (p - uDstOrigin + 0.5) * uSrcScale`（见空间 shader 模板） |

要点：

- 位置是**快照**（调用那一刻），不跟随鼠标；
- 从窗口**拖入脚本**时，取的是**拖拽落点**；
- `@needs` 没声明 `pointer` / `zoom` ⇒ 拿不到这些值（也省掉一次无意义的重烘）；
- 一个脚本里写多段 `shader` 不叠加，最后一段生效。

参考实现：`demo/focus_blur.lua`、`demo/magnifier.lua`。

### 1.3 示例脚本索引

带尖括号的是内置（源码在程序里），其余是目录里的文件；两边都是脚本，读法一样。
每个脚本都由 `ShippedScripts_EveryEffectChangesPixels_AndSurvivesRepeatedBakes` 跑一遍（必须真的改动像素、且能连烘两次）。

| token | 示例脚本 | 演示什么 |
|---|---|---|
| `matrix` | `<invert>`、`<grayscale>`、`external/sepia.lua` | 一条 4×5 矩阵：反相 / Rec.709 亮度 / 现成 sepia 系数 |
| `look` | `<vintage>`、`<film>`、`<warm>`、`<cool>`、`<vivid>`、`external/japanese.lua`、`external/fade.lua`、`external/muted.lua` | 调色：降饱和 / 低对比 / 抬黑位 / 色温 |
| `curve` | `<vintage>`、`<film>` | 通道曲线 |
| `hslaMatrix` | `demo/hsl_vivid.lua` | HSL 空间增饱和 |
| `blend` | `external/soft_glow.lua` | SoftLight 柔光 |
| `colorShader` | `external/cinematic.lua` | 按亮度分区染色 |
| `shader` | `<lomo>`、`external/vignette.lua`、`external/grain.lua`、`demo/chroma_fringe.lua` | 暗角 / 颗粒 / 色差（§3 的三段模板） |
| `highContrast` | `demo/high_contrast.lua` | 灰度 + 反相 + 对比（线性光） |
| `srgbToLinear`、`linearToSrgb` | `demo/linear_lift.lua` | 在 `compose` 里夹一段线性光运算 |
| `focusBlur` | `demo/focus_blur.lua` | 焦点内清晰、越远越糊（焦点跟指针） |
| `lut` | `demo/lut_cube.lua`（配 `luts/film_s_curve.cube`，33³） | 3D LUT 调色；子文件夹 id 与大表走 `file` 的示范 |
| `blur` | `external/soft_focus.lua` | 整幅高斯模糊（柔焦） |
| `dilate` | `demo/glow.lua` | 亮部外扩（发光） |
| `erode` | `demo/ink.lua` | 亮部收细（墨感） |
| `convolution` | `demo/sharpen.lua` | 3×3 锐化核 |
| `displacement` | `demo/ripple.lua` | Perlin 噪声位移（水波） |
| `magnifier` | `demo/magnifier.lua` | 跟指针的透镜（SkSL；静态 `magnifier` token 位置固定） |

### 1.4 效果参数（`@param`）—— 效果声明，外部喂值

效果自己声明可调项（**效果不提供界面**，它只说明"我有哪些可调、范围多大、默认多少"）：

```lua
-- @param radius 0.18 0.05 0.45 透镜半径（按原图短边归一）
-- @param sigma  14   6    30   模糊 σ
```

引擎把每个参数填成**同名 uniform**（`u` + 首字母大写）：`radius` → `uRadius`。
程序里声明 `uniform float uRadius;` 就能用；**没设置过时它是 0**，所以程序里要有兜底：

```glsl
uniform float uRadius;
float radius = (uRadius > 0.0 ? uRadius : 0.18) * min(uImageSize.x, uImageSize.y);  // 0 = 没设置过
```

谁来调（外部）：

| 途径 | 用法 |
|---|---|
| 命令 `SetImageEffect`（可挂快捷键 / 菜单 / 用户脚本消息） | 参数是**一个字符串**：`[<id>] [名字 值 [; 名字 值]…]`（见下）—— 带参数就解析，不带就只换效果 |
| 用户脚本（`Scripts`） | 监听当前特效（状态键 `PropKey.ImageEffect`），处在某个特效时把命令挂到快捷键上，按一下就调一点 |
| 以后的设置界面 | 读 `@param` 的声明生成控件（范围 / 默认值都在声明里） |

**参数串语法**（`EffectParamText`，一个字符串里怎么写 id 与参数）：

```
<文本> ::= <id> [ <参数> [ ; <参数> ]… ]        （空文本 = 不套效果）
<参数> ::= <名字> <值>          -- 名字与值用空白或 = 分隔
<值>   ::= 数 | [+|-] 数        -- 带 + / - ⇒ 在当前值上加减
```

**第一个词是 id**（必填），写法就看脚本放在哪：

| 脚本放在哪 | id |
|---|---|
| 程序里（内置那 8 个） | `<lomo>`、`<invert>` |
| `data/effects/test.lua`（直接放根目录） | `test` |
| `data/effects/demo/magnifier.lua`（子文件夹） | `demo/magnifier` |

id 的容错（`NormalizeId`）：结尾 `.lua`、开头 `./` 可省（`test.lua`、`./test`、`TEST` 都等于 `test`），
反斜杠等价于 `/`（`demo\magnifier` = `demo/magnifier`）。`data/effects/test` 这种"贴一整个路径"的写法不认；
不做模糊匹配 —— 对不上就提示"没找到这个效果"，参数也不再解析。

| 例 | 意思 |
|---|---|
| `<lomo>` | 只换效果（内置） |
| `test` | 只换效果（根目录那个 `test.lua`） |
| `demo/magnifier radius 0.3` | 换效果 + 设一个参数 |
| `demo/magnifier radius +0.02; sigma 16` | 换效果 + 两个参数（`+` = 在当前值上加） |
| `color/vintage contrast +0.05` | id 可带子文件夹 |

多个参数用**分号**分隔，认不出的片段会被跳过。没有"省略 id、只改当前效果参数"的写法：
参数名在不同效果之间没有可比性。

规则：

- 范围由脚本声明**夹住**（`@param` 的 min/max），超出的值会被夹到边界上；
- 参数名不能撞引擎保留名（`focus` / `pointer` / `zoom` / `imageSize` / `srcOrigin` / `srcScale` / `dstOrigin` / `vignette` / `grain` / `chroma` / `lutSize`）—— 声明时会被拒并记日志；
- 改一次参数 = 参数中心 +1 版本号 = 重做产物（和别的可设置项同一套）；
- 值是**按名字存**的（不跟效果绑定）：先设 `radius` 再切到别的效果，值留着；切回来还是它。

---

## 2. token 参考

### look —— 逐像素滤镜

```lua
{ look = { exposure=1, contrast=1, saturation=1, warmth=0, tint=0,
           lift=0, lift_r=0, lift_g=0, lift_b=0 } }
```

| 参数 | 类型 | 默认 | 取值范围 / 说明 |
|---|---|---|---|
| `exposure` | 数 | `1` | 曝光倍数（乘性）：`1` 不变、`2` 亮一倍、`0.5` 暗一半。经验区 `0.5~2` |
| `contrast` | 数 | `1` | 对比：围绕中灰 `0.5` 缩放。`0.9` 更平、`1.2` 更硬。经验区 `0.6~1.6` |
| `saturation` | 数 | `1` | 饱和：`0` 黑白、`1` 不变、`1.25` 明显更艳。经验区 `0~2` |
| `warmth` | 数 | `0` | 色温：`>0` 暖（红↑蓝↓）、`<0` 冷。`0.05` 已肉眼可见。经验区 `-0.2~0.2` |
| `tint` | 数 | `0` | 色调：`>0` 品红（绿↓）、`<0` 绿。经验区 `-0.1~0.1` |
| `lift` | 数 | `0` | 抬黑位：整幅加一个常量（`0.03` ≈ 抬 `8/255`）⇒ 褪色感 |
| `lift_r` / `lift_g` / `lift_b` | 数 | `0` | 分通道抬黑位；给了分通道就不看 `lift`。蓝 > 红/绿 ⇒ 暗部偏青 |

**逐通道公式**（0..1 上算，按此顺序；`r,g,b` 是输入）：

```
① 色温/色调   r *= 1 + warmth + tint/2 ;  g *= 1 - tint ;  b *= 1 - warmth + tint/2
② 饱和        luma = 0.2126r + 0.7152g + 0.0722b ;  x = luma + (x - luma) * saturation
③ 对比        x = (x - 0.5) * contrast + 0.5
④ 曝光        x *= exposure
⑤ 抬黑位      x += lift_channel
```

**实测**：输入 `(200,120,60)`、`exposure .9 contrast 1.2 saturation .7 warmth .08 tint .04 lift .02/.01/.03`
⇒ 按上式算 `192,110,71`，实际 `192,110,71`（逐位一致）。

**例子**

```lua
{ look = { exposure = 1.02, contrast = 1.08, saturation = 1.25, warmth = 0.03 } }
```

**注意**：没有色相旋转（用 `hslaMatrix` 或 `colorShader`）。
**Skia**：由我们合成为一条 4×5 矩阵后走 `SkColorFilters::Matrix`（等价于手写 `matrix`）。

### matrix —— 逐像素滤镜

```lua
{ matrix = { 20 个数 } }              -- 或 { matrix = { values = { 20 个数 } } }
```

4 行 × 5 列、行主序；每行 = `[R G B A 平移]`（系数 `1` = 原样，平移 `0..1`）。
运算结果会**夹到 `0..1`**（Skia 默认 `Clamp::kYes`）。

```lua
-- 经典 sepia
{ matrix = { 0.393, 0.769, 0.189, 0, 0,
             0.349, 0.686, 0.168, 0, 0,
             0.272, 0.534, 0.131, 0, 0,
             0, 0, 0, 1, 0 } }
```

常用系数：Rec.709 亮度 = `0.2126 / 0.7152 / 0.0722`（黑白 = 三行都写这组）。
**Skia**：`SkColorFilters::Matrix(float rowMajor[20], Clamp = kYes)`。

### hslaMatrix —— 逐像素滤镜（HSL 空间）

```lua
{ hslaMatrix = { 20 个数 } }
```

4 行依次是 **H / S / L / A**；第 5 列（平移）**四个分量都用 `0..1`**：

| 分量 | 单位 | 实测 |
|---|---|---|
| `H` 行平移 | **0..1（1.0 = 360°）** | 纯红 `H+0.5` ⇒ `0,255,255`（青）；`H+180` ⇒ **不变**（超出 1 不绕圈，别写角度） |
| `S` 行平移 | `0..1` | 灰 `S+0.5` ⇒ `192,65,65`（灰的 H 视为 0，所以会推向红） |
| `L` 行平移 | `0..1` | 灰 `L+0.5` ⇒ 白 `255,255,255` |
| `A` 行平移 | `0..1` | α=200 的像素 `A-0.5` ⇒ α=73 |

**Skia**：`SkColorFilters::HSLAMatrix` = `HSLA-to-RGBA(Matrix(RGBA-to-HSLA(input)))`。

### table —— 逐像素滤镜

```lua
{ table = { r = <256 个数>, g = <256 个数>, b = <256 个数>, a = <256 个数> } }
```

| 参数 | 类型 | 默认 | 说明 |
|---|---|---|---|
| `r` / `g` / `b` | 256 个数 | 必填 | 第 i 个数 = 输入 i 时输出的值（`0..255`，不是 `0..1`） |
| `a` | 256 个数 | 恒等 | 可选 |

在**非预乘**空间逐分量查表（Skia 会先把预乘解掉、查完再乘回去）。

```lua
local inv = {}
for i = 0, 255 do inv[i + 1] = 255 - i end
return { { table = { r = inv, g = inv, b = inv } } }
```

**Skia**：`SkColorFilters::TableARGB(a, r, g, b)`（表为 `null` 的分量 = 恒等）。

### curve —— 逐像素滤镜

```lua
{ curve = { r = {{x,y}, ...}, g = {...}, b = {...} } }     -- 至少给一个通道
```

控制点 `x`/`y` 都是 `0..1`，**不用按顺序写**（内部按 `x` 排序，实测乱序与有序输出逐像素一致），
超出控制点范围的部分取端点值；插值是单调三次（Fritsch–Carlson，不会过冲）。

```lua
{ curve = { r = { {0, 0.02}, {0.5, 0.51}, {1, 0.96} },
            b = { {0, 0.05}, {1, 0.92} } } }
```

**注意**：结果是 8bit / 256 级表 ⇒ 强曲线在暗部渐变上可能出色带；要顺滑用 `colorShader`。
**Skia**：我们算出表后走 `SkColorFilters::TableARGB`。

### blend —— 逐像素滤镜（混合）

```lua
{ blend = { color = 0xFFF6E8, mode = "SoftLight" } }
```

| 参数 | 类型 | 默认 | 说明 |
|---|---|---|---|
| `color` | 颜色 | 必填 | `0xRRGGBB` / `"#RRGGBB"` / `{r,g,b}`（`0..255`）/ 可带第 4 个 alpha |
| `mode` | 名字 | `SrcOver` | 大小写不敏感、下划线可省；其余名字：`Overlay HardLight Lighten Darken ColorDodge ColorBurn Plus Hue Saturation Color Luminosity` |

`color` 是**前景（src）**，图像像素是**背景（dst）**。

| mode | 公式（`c` = color，`p` = 像素） | 实测（`p=100,150,200`、`c=40,80,120`） |
|---|---|---|
| `Src` | `c` | `40,80,120` |
| `Dst` | `p` | Skia 返回 null ⇒ 这一步没有产出（不可用） |
| `SrcOver` | `c·α + p·(1-α)` | α=128 ⇒ `70,115,160` |
| `Multiply` | `c·p / 255` | `16,47,94` |
| `Screen` | `255 - (255-c)(255-p)/255` | `124,183,226` |

常用：染色（强度看 alpha）`{ blend = { color = 0x50FFEEDD } }`、柔光罩 `SoftLight`、压暗 `Multiply`、提亮 `Screen`。
**Skia**：`SkColorFilters::Blend(SkColor c, SkBlendMode mode)`。

### lighting —— 逐像素滤镜

```lua
{ lighting = { mul = 0xFFFFFF, add = 0x000000 } }
```

`mul` / `add` 都是 `0..255` 的颜色，按 `/255` 使用；**alpha 分量被忽略**；结果夹到 `0..255`。

| 实测 | 输入 `200,100,50` |
|---|---|
| `mul = 0x808080`（≈ 0.502）、`add = 0x000000` | `100,50,25`（约减半） |
| `mul = 0xFFFFFF`、`add = 0x808080` | `255,228,178`（每通道 +约 0.5，夹住） |

**Skia**：`SkColorFilters::Lighting(SkColor mul, SkColor add)`。

### highContrast —— 逐像素滤镜

```lua
{ highContrast = { contrast = 0.5, grayscale = false, invert = "NoInvert" } }
```

| 参数 | 类型 | 默认 | 说明 |
|---|---|---|---|
| `contrast` | 数 | `0.5` | 合法 `-1~1`（越界会被夹住并记日志）；`0` = 不变 |
| `grayscale` | true/false | `false` | 先按亮度去色 |
| `invert` | 名字 | `NoInvert` | `NoInvert` / `InvertBrightness` / `InvertLightness` |

**执行顺序固定**：灰度 → 反相 → 对比（Skia 头文件声明），且**在线性光里算**（这就是下面数字反直觉的原因）。
`invert` 的两种：`InvertBrightness` = 逐通道取补（**色相一起翻**）；`InvertLightness` = 只把 HSL 的亮度取补（**保色相**）。

实测（输入 `200,100,50` / 第二组输入 `200,100,0`）：

| 设置 | 结果 |
|---|---|
| `contrast = 0` | `200,100,50`（不变） |
| `contrast = -1` | `188,188,188`（= 线性光中灰，**不是** `128`） |
| `contrast = 0.5` | `222,0,0` |
| `contrast = 1` | `255,0,0`（接近二值化） |
| `grayscale = true` | `128,128,128`（线性空间亮度；注意与 `matrix` 灰度的 `118` **不同**） |
| `invert = "InvertBrightness"` | `174,240,255`（线性取补，**不是** sRGB 取补的 `55,155,255`） |
| `invert = "InvertLightness"` | `255,196,174`（保色相：R>G>B） |

**Skia**：`SkHighContrastFilter::Make(SkHighContrastConfig{grayscale, invert, contrast})`。

### srgbToLinear —— 逐像素滤镜（sRGB → 线性光）

```lua
{ srgbToLinear = true }
```

无参数。把运算夹在它和 `linearToSrgb` 之间，就能在"线性光空间"里做曝光/加光/混合（暗部过渡更自然）。
单独用等于改 gamma（画面明显变亮）。
**例子**：见 `demo/linear_lift.lua`（`compose` + 曝光矩阵）。
**Skia**：`SkColorFilters::SRGBToLinearGamma()`。

### linearToSrgb —— 逐像素滤镜（线性光 → sRGB）

```lua
{ linearToSrgb = true }
```

无参数；与 `srgbToLinear` 成对使用（线性空间运算做完，用它转回来）。
**Skia**：`SkColorFilters::LinearToSRGBGamma()`。

### identity —— 逐像素滤镜

```lua
{ identity = true }
```

无参数、不改变像素。用于 `compose` / `lerp` 里占位（例如"只混 40% 的反相"）。
**Skia**：单位矩阵（`SkColorFilters::Matrix`）。

### compose —— 组合（逐像素）

```lua
{ compose = { outer = <步骤>, inner = <步骤> } }
```

语义：**结果 = outer(inner(像素))**，即 `inner` 先生效。两个分支都必须能编成"逐像素滤镜"
（空间 `shader` 不能塞进来）。实测：`compose(outer=灰度, inner=反相)` 与"先反相再单独跑灰度"逐像素一致。

**Skia**：`SkColorFilters::Compose(outer, inner)`（头文件原文：*result = this(inner(...))*）。

### lerp —— 组合（逐像素）

```lua
{ lerp = { t = 0.5, a = <步骤>, b = <步骤> } }
```

| 参数 | 类型 | 默认 | 说明 |
|---|---|---|---|
| `t` | 数 | `0.5` | `0` 得 `a`、`1` 得 `b`（`<0` 当 `0`、`>1` 当 `1`） |
| `a` / `b` | 步骤 | 必填 | 逐像素步骤 |

实测（像素 `200,100,50`；`a` = 反相、`b` = 灰度）：`t=0` ⇒ `55,155,205`（= `a`），
`t=0.5` ⇒ `86,136,161`（= 两者逐通道中点），`t=1` ⇒ `118,118,118`（= `b`）⇒ **在数值上直接混，不是线性光**。

**Skia**：`SkColorFilters::Lerp(t, dst, src)` —— `t=0` 得到第一个参数（我们 token 的 `a`）。

### colorShader —— 逐像素滤镜（SkSL）

```lua
{ colorShader = [[ half4 main(half4 color) { ... } ]] }
```

入口 `half4 main(half4 color)`：`color` = 当前像素（非预乘）。能做条件判断与跨通道混合，
但**拿不到坐标、读不到邻居像素**（要那个用 `shader`）。
编译失败 ⇒ 这一步跳过（画面不崩，日志里有编译器给的行号与原因）。

```lua
{ colorShader = [[
    half4 main(half4 color) {
        half luma = dot(color.rgb, half3(0.2126, 0.7152, 0.0722));
        half3 shadow = half3(0.85, 1.0, 1.15);
        half3 light  = half3(1.10, 1.02, 0.90);
        return half4(color.rgb * mix(shadow, light, luma), color.a);
    }
]] }
```

**Skia**：`SkRuntimeEffect::MakeForColorFilter` → `ToColorFilter()`。

### shader —— 空间效果（SkSL）

```lua
{ shader = [[ half4 main(float2 p) { ... } ]] }
```

入口 `half4 main(float2 p)`，`p` = **本块产出区域的局部坐标**（左上角为 0）。
`uniform shader src;` 是**整张源图**（所以邻居像素也能读）。

可声明的 uniform（声明了引擎才填，不用的别声明）：

| uniform | 含义 |
|---|---|
| `uniform shader src;` | 整张源图；`src.eval(源图像素坐标)` 取色 |
| `uniform float2 uImageSize;` | 源图尺寸（像素） |
| `uniform float2 uSrcOrigin;` | 本块产出区域左上角在源图里的坐标 |
| `uniform float2 uSrcScale;` | 源图像素 / 产出像素（1:1 时 = 1） |
| `uniform float2 uDstOrigin;` | 本块产出区域在画布上的左上角 |
| `uniform float2 uFocus;` | **引擎填的运行期值**：调用时的指针位置（图像归一化 0..1） |
| `uniform float uPointer;` | 1 = 调用时拿到了指针；0 = 没拿到（事件被吞 / 从菜单调用） |
| `uniform float uZoom;` | 快照时的缩放倍数（位置类效果用它把"屏幕距离"换算回图像像素） |

**"要运行时值"的写法**（脚本声明、运行时替换 —— 默认值写在脚本里）：

```glsl
uniform float2 uFocus;      // 引擎填
uniform float  uPointer;    // 引擎填
...
float2 focus = mix(float2(0.5, 0.45), uFocus, uPointer);   // 没指针就落默认
```

调用点（快捷键 / 命令）在**调用那一刻**把指针位置 + 缩放快照进参数中心
（`ImageEffectParameters.PointerX/PointerY/HasPointer/Zoom`），改值会 +1 版本号 ⇒ 重烘一次。
**不跟随鼠标移动**（跟随意味着每动一下都要重编规格、重烘产物）。见 `demo/focus_blur.lua`。

**坐标换算**（只记这一行；坐标一律按**原图**算）：

```glsl
float2 imgPx = uSrcOrigin + (p - uDstOrigin + 0.5) * uSrcScale;   // = 源图像素坐标（像素中心）
```

按原图算带来三件事：① 放大只看中央时暗角不会被误伤；② 颗粒的种子取原图坐标 ⇒ 缩放/平移不游动；
③ 大图分块烘（瓦片）与整图烘结果逐像素一致 ⇒ **没有接缝**。

**注意**：一个脚本里写多段 `shader` **不叠加**（最后一段生效）；强度/半径/种子直接写在 SkSL 里。

**能做什么（实测）**

| 能力 | 结论 |
|---|---|
| 邻域采样与循环 | ✅ `for` 循环可用（常量边界）。box 卷积：169 次采样在 256² 上烘一张 **157 ms**（81 次 82 ms、25 次 30 ms） |
| 模糊 | ✅ 黄金角螺旋（圆盘模糊）：25 次采样、半径 14 耗时 **32 ms**（代价取决于采样条数，与半径无关） |
| 带焦点的虚化 | ✅ 见 `demo/focus_blur.lua`（棋盘中心对比 `180`、角落 `74`） |
| 大半径 | ⚠️ 条数固定时半径越大越稀（噪点 / 环纹）；超大半径（bloom）目前没有低分辨率辅助层 |
| 识别人像 / 背景 | ❌ 2D 图没有深度信息；焦点只能是几何的（中心 + 半径） |

**Skia**：`SkRuntimeEffect::MakeForShader` → `ToShader(uniforms, children)`。

### lut —— 逐像素滤镜（3D LUT）

```lua
{ lut = { file = "test.cube" } }     -- 只写文件名：所有 LUT 都放在 data/effects/luts/ 里
```

两个键二选一：`file`（文件名，按下面的顺序解析）或 `text`（内容直接写进脚本，见下）。

`file` 的解析顺序：**完整路径**（`"D:/My Luts/x.cube"`、UNC 路径）⇒ **光名字** ⇒ 在 `data/effects/luts/` 里找
⇒ 再按**进程工作目录**解析一次。只认 `.cube`；写 `../x.cube`、`sub/x.cube`、`x.txt` 会被拒绝并说明原因。

> 反斜杠在 Lua 串里是转义 ⇒ 路径请用 `/`（Windows 一样认），或用 `[[...]]` 原样串。

**也可以直接把内容写进脚本**（`text`）：这格式本来就是文本，Lua 里一个循环就能生成，不必先落一个文件。

```lua
-- 生成一份"整体提亮 + 暖调"的 16³ LUT（红最快 → 绿 → 蓝，值域 0..1）
-- 注意：用计数下标 i 追加，不要写 lines[#lines + 1]（# 是 O(n) ⇒ 那样是 O(n²)）
local n, lines, i = 16, { "LUT_3D_SIZE 16" }, 0
for b = 0, n - 1 do
  for g = 0, n - 1 do
    for r = 0, n - 1 do
      local rf, gf, bf = r / (n - 1), g / (n - 1), b / (n - 1)
      i = i + 1
      lines[i] = string.format("%0.6f %0.6f %0.6f",
        math.min(1, rf * 1.05 + 0.02),
        math.min(1, gf * 1.01 + 0.015),
        math.min(1, bf * 0.95 + 0.01))
    end
  end
end
return { { lut = { text = table.concat(lines, "\n") } } }
```

**`.cube` 格式**：一行 `LUT_3D_SIZE N`（`N ≥ 2`，常见 16 / 33），随后 `N³` 行 `R G B`
（`0..1`，红最快 → 绿 → 蓝；`0..255` 也识别）。`LUT_1D_SIZE` 不支持。
它**替换**整幅颜色，只做一半就套 `lerp`：

```lua
{ lerp = { t = 0.5, a = { identity = true }, b = { lut = { file = "x.cube" } } } }
```

`text` 只适合**小表**：内容在脚本里现算，而求值有 300ms 预算（见 1 节）—— 16³ 约几十毫秒能跑，33³ 必超时，
大表应落成 `.cube` 用 `file`。内联时用注入的构建器（`text.new()` / `:add(...)` / `:text()`，另有 `:length()`）：
比 Lua 侧拼串省，也避开 `t[#t + 1]` 的二次方问题；单个构建器上限 16MB。细节见 `EffectScriptText` 的注释。

**引擎自带的 LUT 是另一条路**：拖一个 `.cube` 进窗口就用，不走脚本 —— 路径是运行期设置
（`ImageEffectParameters.LutFile`），换一份 = 版本 +1 = 重编规格；它占住"当前效果"的位置 ⇒ 菜单里一个都不选中。
两条路共用同一套读取与滤镜实现（`EffectLut` / `Lut3D`）。拖拽不限路径，但要有一张打开的图；
显示名取 `.cube` 的 `TITLE`，没有就用文件名。

找不到文件 / 格式不对 ⇒ 这一步跳过（日志写明原因）。
**Skia**：无直接对应（`.cube` 由我们铺成条带贴图 + runtime shader 三线性采样；布局 = 宽 `N²`、高 `N`）。

---

### focusBlur —— 空间效果（原生模糊 + SkSL 混合）

```lua
{ focusBlur = { sigma = 14, radius = 0.16, feather = 0.10 } }   -- 可选 default_x / default_y
```

| 参数 | 类型 | 默认 | 说明 |
|---|---|---|---|
| `sigma` | 数 | `12` | 模糊 σ（原图像素，必须 > 0）。12~20 是"背景虚化"的常见量 |
| `radius` | 数 | `0.16` | 清晰半径，按**原图短边**归一（0.16 ≈ 中心 16% 保持清晰） |
| `feather` | 数 | `0.10` | 过渡宽度（同样归一），越大过渡越柔 |
| `default_x` / `default_y` | 数 | `0.5` / `0.45` | 没有指针时的默认焦点（图像归一化坐标） |

**和 `blur` 的区别**：`blur` 是整幅、固定 σ，它没有"焦点"这个概念；`focusBlur` 是"焦点内清晰、越远越糊"。

**实现**：模糊仍交给原生 <c>CreateBlur</c>（整图糊**一次**，分离卷积 ⇒ σ 再大也不贵），
SkSL 只做 `mix(清晰, 模糊, 距离遮罩)` —— 所以**没有手写采样循环**（1.0 那版 24 次螺旋采样已废弃）。
引擎为此多给一个 child：`uniform shader blurred;`（按「源图 + σ」缓存一份离线模糊副本）。

**焦点跟指针**：程序声明了 `uFocus` / `uPointer`（脚本用 `@needs pointer` 声明它们），
引擎在调用那一刻把鼠标位置填进去；没有指针就落回 `default_x` / `default_y`（见 1.2）。

**Skia**：`SkImageFilters::Blur`（离线副本）+ 运行时 shader 的两个 child（`src` / `blurred`）。

---

### blur —— 空间效果（原生滤镜 · 高斯模糊）

```lua
{ blur = 8 }                        -- 或 { blur = { sigma = 8 } }
```

| 参数 | 类型 | 默认 | 取值 / 说明 |
|---|---|---|---|
| `sigma` | 数 | `4` | 模糊半径 σ；`0` 不变（但仍是滤镜，白跑）。经验区 `0.5~20` |

**产出**：整张图高斯模糊后的版本。
**实测**：`sigma = 8` 让相邻像素梯度下降约 60%（`Script_Blur_CompilesAndBakes` 钉住）；代价与 σ 无关，
256² 上无论 σ=4 / 8 / 20 都是 **2~3 ms**（比在 SkSL 里手写 169 次采样快约 60 倍）。
**例子**：`{ blur = 6 }` 朦胧；`{ blur = { sigma = 2 } }` 轻微柔化。
**注意**：要"背景虚化"（焦点内清晰、越远越糊）用两个 σ + 遮罩图混合，或用 `shader` 手写（见 `demo/focus_blur.lua`）。
**Skia**：`SKImageFilter.CreateBlur`。

### dilate —— 空间效果（原生滤镜 · 形态学膨胀）

```lua
{ dilate = 4 }                      -- 或 { dilate = { radius = 4 } } / { dilate = { rx = 3, ry = 5 } }
```

| 参数 | 类型 | 默认 | 取值 / 说明 |
|---|---|---|---|
| `radius` | 数 | `2` | 半径（rx = ry 时用它） |
| `rx` / `ry` | 数 | 同 `radius` | 横 / 纵半径，可不等（拉伸形变） |

**产出**：每个像素取邻域**最大值** ⇒ 亮部 / 边缘向外扩张（发光描边、去噪前"撑开"、把细线加粗）。
**注意**：半径别太大，开销随核面积涨。
**Skia**：`SKImageFilter.CreateDilate`。

### erode —— 空间效果（原生滤镜 · 形态学腐蚀）

```lua
{ erode = 4 }                       -- 参数同 dilate
```

**产出**：每个像素取邻域**最小值** ⇒ 暗部扩张、亮部收缩（去白边、去浅噪点）。
**Skia**：`SKImageFilter.CreateErode`。

### magnifier —— 空间效果（原生滤镜 · 放大镜）

```lua
{ magnifier = { x = 32, y = 32, w = 64, h = 64, zoom = 3, inset = 2 } }
```

| 参数 | 类型 | 默认 | 取值 / 说明 |
|---|---|---|---|
| `x` / `y` / `w` / `h` | 数 | `0 / 0 / 64 / 64` | 被放大的矩形（**源图像素**坐标） |
| `zoom` | 数 | `3` | 放大倍率 |
| `inset` | 数 | `2` | 镜框柔化宽度（边缘过渡，`0` = 硬边） |

**产出**：把指定矩形放大 `zoom` 倍盖在原图上（局部放大 / 鱼眼）。
**Skia**：`SKImageFilter.CreateMagnifier`。

### convolution —— 空间效果（原生滤镜 · 任意卷积核）

```lua
{ convolution = { kernel = { 0,-1,0, -1,5,-1, 0,-1,0 }, width = 3, height = 3 } }          -- 锐化
{ convolution = { kernel = { 1,1,1, 1,1,1, 1,1,1 }, width = 3, height = 3, gain = 1/9 } }   -- 盒状模糊
```

| 参数 | 类型 | 默认 | 取值 / 说明 |
|---|---|---|---|
| `kernel` | 表 | 必填 | 展平的一维数组，长度必须 = `width × height`（行主序） |
| `width` / `height` | 数 | 必填 | 核尺寸 |
| `gain` | 数 | `1` | 乘子（盒状模糊用它归一化，如 `1/9`） |
| `bias` | 数 | `0` | 加性偏移 |
| `offset_x` / `offset_y` | 数 | 核中心 | 核中心位置（默认正中心） |
| `tile` | 名 | `clamp` | 越界取样：`clamp` / `decal` / `mirror` |
| `convolve_alpha` | 布尔 | `false` | 是否连 alpha 一起卷（默认只卷 RGB） |

**产出**：与核卷积后的图 —— 锐化 / 模糊 / 浮雕 / 边缘检测只是换核。
**注意**：`kernel` 长度必须严格 = `width × height`，否则编译失败（已校验）。
**Skia**：`SKImageFilter.CreateMatrixConvolution`。

### displacement —— 空间效果（原生滤镜 · 位移扭曲）

```lua
{ displacement = { scale = 20, frequency = 0.02 } }
```

| 参数 | 类型 | 默认 | 取值 / 说明 |
|---|---|---|---|
| `scale` | 数 | `20` | 最大位移量（源图像素） |
| `channel_x` / `channel_y` | 名 | `R` / `G` | 取位移图的哪个通道当 x / y 偏移 |
| `frequency` / `frequency_x` / `frequency_y` | 数 | `0.02` | 噪声密度（越大越密）；取值 **非负、常规 `0~1`，且不能是整数**（见下） |
| `octaves` | 数 | `2` | 噪声叠加层数（越多越细）；上限 255，**1~4 够用**（每层频率翻倍，再多只剩细碎噪点） |
| `seed` | 数 | `0` | 噪声随机种子 |

**产出**：用一段 Perlin 湍流噪声当"位移图"扭曲源图（色差 / 水波 / 玻璃）。
**注意**：位移图内置为噪声；要自定义位移图就用 `shader` 自己写。
**Skia**：`SKImageFilter.CreateDisplacementMapEffect` + `SKShader.CreatePerlinNoiseTurbulence`。

> **`frequency` 必须是非负小数，且不能取整数**：整数频率会让噪声恒为 `0`（位移量变成常量 ⇒ 效果退化成整图平移 ——
> 肉眼看不出，但像素确实变了）。建议落在 **`0.002 ~ 0.5`**（默认 `0.02` 起步）。
> 成因与两个专门的用例见 `EffectScriptCompiler` 的 `DisplacementImage` 注释。

> 这一族都是 Skia 原生 `SKImageFilter`（SkSL 写起来笨重的那类），载体是 `SKPaint.ImageFilter`。
> **施加顺序**：空间 shader → 原生滤镜 → 逐像素调色。按瓦片烘时块内部与整图一致，块边界有一圈差异（见 §8.3）。

---

## 3. 空间 shader 的三段完整程序

```lua
-- 暗角：距离按原图算 ⇒ 放大只看中央时不会被误伤
{ shader = [[
    uniform shader src;
    uniform float2 uImageSize, uSrcOrigin, uSrcScale, uDstOrigin;
    half4 main(float2 p) {
        float2 imgPx = uSrcOrigin + (p - uDstOrigin + 0.5) * uSrcScale;
        half4 color = src.eval(imgPx);
        float dist = length((imgPx - 0.5 * uImageSize) / min(uImageSize.x, uImageSize.y));
        half k = half(0.85) * smoothstep(half(0.45), half(1.0), half(dist));   // 0.85 = 强度
        return half4(color.rgb * mix(half(1.0), half(0.30), k), color.a);
    }
]] }
```

```lua
-- 颗粒：种子取原图坐标 ⇒ 缩放、平移都不游动
{ shader = [[
    uniform shader src;
    uniform float2 uSrcOrigin, uSrcScale, uDstOrigin;
    float hash21(float2 p) {
        float3 q = fract(float3(p.x, p.y, p.x) * 0.1031);
        q += dot(q, float3(q.y, q.z, q.x) + 33.33);
        return fract((q.x + q.y) * q.z);
    }
    half4 main(float2 p) {
        float2 imgPx = uSrcOrigin + (p - uDstOrigin + 0.5) * uSrcScale;
        half4 color = src.eval(imgPx);
        float n = hash21(floor(imgPx / 2.0)) - 0.5;             // 2.0 = 每颗占多少原图像素
        half luma = dot(color.rgb, half3(0.2126, 0.7152, 0.0722));
        half g = half(n * 0.7 * 0.30) * color.a * mix(half(1.0), half(0.55), luma);
        return half4(clamp(color.rgb + g, half(0.0), half(1.0)), color.a);
    }
]] }
```

```lua
-- 色差：读邻居像素
{ shader = [[
    uniform shader src;
    uniform float2 uSrcOrigin, uSrcScale, uDstOrigin;
    half4 main(float2 p) {
        float2 imgPx = uSrcOrigin + (p - uDstOrigin + 0.5) * uSrcScale;
        half4 color = src.eval(imgPx);
        float d = 1.0 + 1.5 * 0.7;                              // 错开量（源图像素）
        half r = src.eval(imgPx + float2(d, 0.0)).r;
        half b = src.eval(imgPx - float2(d, 0.0)).b;
        return half4(r, color.g, b, color.a);
    }
]] }
```

同骨架的其它效果：

```
扫描线   float2 line = fract(imgPx.y * 0.5);  color.rgb *= step(0.5, line) * 0.12 + 0.94;
漏光     按 imgPx 到某个角的方向做渐变，与 color.rgb 相加（强度随距离衰减）
波纹     imgPx += float2(sin(imgPx.y * 0.05), 0.0) * 4.0;  再 eval(imgPx)
鱼眼     转成"相对原图中心"的极坐标，按半径压缩/拉伸后再 eval
锐化     取 imgPx ± 1 的邻居做差分
```

---

## 4. SkSL 语言约定

```
half / float 严格：字面量写小数（0.5），要 half 就显式包一层 half(0.85) / half3(1.0, 1.0, 1.0)
smoothstep(edge0, edge1, x)：三个参数类型一致 → smoothstep(half(0.45), half(1.0), half(dist))
mix(a, b, t)：t = 0 得 a、t = 1 得 b
clamp(x, lo, hi)：三个参数类型一致
src.eval(coord)：coord 是【源图像素】（不是 0..1）；越界自动夹住
返回值是【预乘】颜色：实测返回 (1,0,0,0.5) 落地是 R=255,A=128（Skia 不会替你预乘）
    ⇒ 想"在非预乘空间里算"就先 color.rgb /= max(color.a, 1e-5)，算完再乘回去
可以写 for 循环（常量边界，比如模糊的邻域采样）；不能递归 / 动态数组索引；不支持 #include
编译失败不让程序崩：这一步跳过，日志里有错误行号
```

---

## 5. 出错时的行为

| 情况 | 结果 |
|---|---|
| 文件语法错 / 表结构不对 / 效果链为空 / 解析超时 | 该效果**不可用**：点它的**那一次**会报出原因（列表里暂时还是亮的 —— 引擎不替你提前解析），**之后就变灰**；实际诊断以日志里的这条为准 |
| 单个 token 出错（未知 token / 参数错 / SkSL 编不过 / LUT 载入失败） | 只跳过这一段，其它段照旧生效 |
| 未知参数名 | 记一条日志并忽略（写错名字不会静默生效） |
| 日志位置 | 形如 `@<lomo>.lua[2]`：第 2 个步骤（内置也是这个形状；`external/sepia.lua` 则带子文件夹） |

---

## 6. 注册一个新效果

**外部（改数据目录就够，不用碰 C#）**

1. 写一个 `.lua` 扔进 `data/effects/`：根目录最省事（`test.lua` ⇒ id `test`），想分类就开子文件夹
   （`demo/magnifier.lua` ⇒ id `demo/magnifier`）。文件名就是 id，显示名用 `@name` 声明。
2. **试它：把它拖进窗口**（先打开一张图）。拖的那一刻这份脚本会重读、重新编译 ⇒ 刚写好、刚改过都能立即生效；
   写坏了直接提示编译失败原因；指针类效果以拖拽落点为焦点。只认就在 `data/effects` 里的 `.lua`。
3. 想从菜单点到它：在菜单配置里加一条 `SetImageEffect` 命令（参数 = 这个 id），或挂快捷键 / 在用户脚本里写 id。
4. 只有"改了脚本内容、又没拖过它"才需要重启；新加的文件拖一下就在册。

**内置（那 8 个，要走代码）**

1. 在 `Vii3/Feature/Image/Effects/Scripting/BuiltInEffectScripts.cs` 里加一段源码（照现有那段的写法）
2. `EffectKeys` 加一个常量 `"<名字>"`（`DefaultMenuNodes.DefaultEffectGroups` 会自动列出）
3. 想要中文名：`DefaultLangs.GetEffectDict()` 加一条（键 = `LangKeys.GetEffectKey(id)`，
   语言服务会把尖括号剥掉 ⇒ `Effect.<名字>`）
4. 重新编译（内置源码在程序里，改动随发布物走）

---

## 7. 溯源表（我们 → Skia）

| token | Skia API |
|---|---|
| `look` / `matrix` / `identity` | `SkColorFilters::Matrix`（`sk_colorfilter_new_color_matrix`） |
| `hslaMatrix` | `SkColorFilters::HSLAMatrix` |
| `table` / `curve` | `SkColorFilters::TableARGB` |
| `blend` | `SkColorFilters::Blend(SkColor, SkBlendMode)` |
| `lighting` | `SkColorFilters::Lighting` |
| `highContrast` | `SkHighContrastFilter::Make` |
| `srgbToLinear` / `linearToSrgb` | `SkColorFilters::SRGBToLinearGamma` / `LinearToSRGBGamma` |
| `compose` | `SkColorFilters::Compose` |
| `lerp` | `SkColorFilters::Lerp` |
| `colorShader` / `shader` | `SkRuntimeEffect::MakeForColorFilter` / `MakeForShader` |
| `lut` | 无（`.cube` 由我们解析成条带贴图 + runtime shader 采样） |
| `blur` / `dilate` / `erode` / `magnifier` / `convolution` / `displacement` | `SKImageFilter::Blur` / `Dilate` / `Erode` / `magnifier` / `MatrixConvolution` / `DisplacementMapEffect` |

---

## 8. Skia 原生特效 API 清单（本版本 3.119.4 可用）

> 这份清单是给"以后要加效果"的人看的：**先在这里找原生 API，别急着手写循环**。
> 全部方法都按本地源码 `VendorSources/SkiaSharp-release-3.119.4/binding/SkiaSharp/*.cs` 核对过
> （`SkiaSharp 3.119.4` 里 `SKColorMatrix` 类型、`SKImageFilter.CreateRuntimeShader`、`SKRuntimeEffect.ToImageFilter` 都**不存在**）。
> 行为由 `Tests/Vii3.Tests/ImageEffectTests.cs` 的 `Semantics_NativeApi_*` 探针钉住（改坏会红 / 编译不过）。

### 8.1 四类载体的边界（决定能不能进瓦片产出点）

| 载体 | 例子 | 能进瓦片产出点？ | 原因 |
|---|---|---|---|
| `SKColorFilter`（逐像素） | matrix / 曲线 / blend / SkSL color filter | ✅ 能 | 只看当前像素，分块结果一致，无接缝 |
| `SKShader`（空间，runtime effect） | 暗角 / 颗粒 / 色差 | ✅ 能 | 按原图坐标算、child 就是整张源图，分块一致（见 §3） |
| `SKImageFilter`（空间，内置） | `CreateBlur` / `CreateDilate` / `CreateMagnifier` / `CreateMatrixConvolution` | ⚠️ 能，但块边界有差 | 没有 SkSL→ImageFilter 入口 ⇒ 走"整层局部坐标的 `CreateImage`"；块内部与整图烘一致，块边界有一圈差异（见 §8.3） |
| ~~产出目标色彩空间~~ | 已移除 | — | 原 `TargetProfile` 那套已删（源图仍按文件声明的色彩空间正确解码） |

### 8.2 `SKColorFilter`（逐像素，可瓦片）

| 原生 API | 签名（最小） | 对应 token / 状态 |
|---|---|---|
| `CreateColorMatrix` | `(ReadOnlySpan<float> matrix20)` | `matrix` / `look` / `identity` |
| `CreateHslaColorMatrix` | `(ReadOnlySpan<float> matrix20)` | `hslaMatrix` |
| `CreateTable` | `(byte[] a, r, g, b)` 或单表 `(byte[])` | `table` / `curve` |
| `CreateLumaColor` | `()` | —（会把 RGB 清零，是遮罩不是调色；只在 `ImageEffectApiDemo` 演示） |
| `CreateLighting` | `(SKColor mul, SKColor add)` | `lighting` |
| `CreateBlendMode` | `(SKColor c, SKBlendMode mode)` | `blend` |
| `CreateHighContrast` | `(SKHighContrastConfig)` 或 `(bool gray, InvertStyle, float contrast)` | `highContrast` |
| `CreateSrgbToLinearGamma` / `CreateLinearToSrgbGamma` | `()`（静态单例） | `srgbToLinear` / `linearToSrgb` |
| `CreateCompose` | `(SKColorFilter outer, SKColorFilter inner)` | `compose` |
| `CreateLerp` | `(float t, SKColorFilter f0, SKColorFilter f1)` | `lerp` |
| `CreateColorFilter`(SkSL) | `SKRuntimeEffect.CreateColorFilter(sksl, out err)` → `ToColorFilter()` | `colorShader` |

### 8.3 `SKImageFilter`（空间，需整层路径）

每个工厂都有 `input` / `cropRect` 重载。已经接成脚本 token 的有：
`blur` / `dilate` / `erode` / `magnifier` / `convolution` / `displacement`（见 §2），由产出点经 `SKPaint.ImageFilter` 施加
（代码见 `ImageEffectBaker.DrawWithEffect`）。

> **接缝（已实测）**：产出点用"整层局部坐标的 `CreateImage`"接源图 ⇒ 块内部与整图烘一致，
> 但**块边界约 3σ 的环内仍有差**（σ=6、128px 块：内部 ≤2 级、边缘环 ~22 级，用例
> `ImageFilter_SubRegions_InteriorMatchesWholeImageBake`）。原因是 Skia 把滤镜输入裁在当前绘制区域里，块外邻居取不到。
> 要完全无缝需要 ① 外扩 apron（各扩 3σ 后裁掉）或 ② 这类规格走整层路径；两者都还没做 ⇒
> **大图用原生图像滤镜时块边界会有一圈差异**。

> **没有接成 token 的**：`CreateDropShadow` / `CreateDistantLitDiffuse` / `CreateDistantLitSpecular`
> （要靠 alpha 塑形，满幅不透明的照片上要么看不见、要么只是整块变亮），以及组合类
> `CreateMerge` / `CreateTile` / `CreateOffset` / `CreatePicture` / `CreateBlendMode` / `CreateArithmetic` /
> `CreateColorFilter` / `CreateCompose` / `CreateShader` / `CreateImage`。

| 原生 API | 签名（最小） | 用途 |
|---|---|---|
| `CreateBlur` | `(float σx, float σy, [TileMode], [input], [cropRect])` | 高斯模糊（柔光 / 朦胧） |
| `CreateDilate` / `CreateErode` | `(float rx, float ry, [input], [cropRect])` | 形态学膨胀 / 腐蚀（发光 / 描边 / 去噪） |
| `CreateDisplacementMapEffect` | `(Channel xSel, ySel, float scale, SKImageFilter displacement, [input])` | 位移扭曲（水波 / 色差） |
| `CreateDropShadow` / `CreateDropShadowOnly` | `(float dx, dy, σx, σy, SKColor, [input])` | 投影（外阴影 / 内阴影） |
| `CreateMatrixConvolution` | `(SKSizeI size, ReadOnlySpan<float> kernel, float gain, bias, SKPointI offset, TileMode, bool convAlpha, [input])` | 任意卷积（锐化 / 自定义模糊 / 浮雕） |
| `CreateMerge` | `(SKImageFilter first, second)` 或 `(ReadOnlySpan<SKImageFilter>)` | 多图层合并 |
| `CreateColorFilter` | `(SKColorFilter cf, [input])` | 把逐像素滤镜包进 ImageFilter 链 |
| `CreateCompose` | `(SKImageFilter outer, SKImageFilter inner)` | 组合两个 ImageFilter |
| `CreateOffset` | `(float rx, float ry, [input])` | 平移（视差） |
| `CreateTile` | `(SKRect src, SKRect dst, [input])` | 瓦片复制 |
| `CreateBlendMode` | `(SKBlendMode / SKBlender, SKImageFilter bg, [fg], [cropRect])` | 图层混合 |
| `CreateArithmetic` | `(float k1..k4, bool enforcePMColor, SKImageFilter bg, [fg])` | 算术混合（k1·src·dst + k2·src + k3·dst + k4） |
| `CreateImage` | `(SKImage, [SKRect src, SKRect dst, Sampling])` | 把源图接入滤镜链（整层引用，瓦片无需 apron） |
| `CreateMagnifier` | `(SKRect lensBounds, float zoom, float inset, Sampling, [input])` | 放大镜（局部放大） |
| `CreateDistantLitDiffuse` / `CreatePointLitDiffuse` / `CreateSpotLitDiffuse` | `(方向/位置, SKColor, surfaceScale, kd, [input])` | 漫反射光照（alpha 当高度图） |
| `CreateDistantLitSpecular` / `CreatePointLitSpecular` / `CreateSpotLitSpecular` | `(…, ks, shininess, [input])` | 镜面光照 |
| `CreatePicture` | `(SKPicture, [cropRect])` | 矢量内容当滤镜 |
| `CreateShader` | `(SKShader?, bool dither, [cropRect])` | 把 `SKShader` 当 ImageFilter（噪声 / 渐变填色） |

### 8.4 `SKShader`（绘制期 / 当 child）

| 原生 API | 签名（最小） | 用途 |
|---|---|---|
| `CreateLinearGradient` / `CreateRadialGradient` / `CreateSweepGradient` | `(点, 颜色[], [pos], TileMode, [localMatrix])` | 渐变（光晕 / 漏光 / 渐变蒙版） |
| `CreatePerlinNoiseFractalNoise` / `CreatePerlinNoiseTurbulence` | `(float fX, fY, int octaves, float seed, [tileSize])` | 程序化噪声（胶片颗粒 / 云 / 纹理） |
| `CreateCompose` | `(SKShader a, SKShader b, [SKBlendMode])` | 两个 shader 混合（b 合成在 a 之上） |
| `CreateLocalMatrix` | `(SKShader, SKMatrix)` | 给 shader 加局部变换 |
| `CreateColor` | `(SKColor)` 或 `(SKColorF, SKColorSpace)` | 纯色填充 |
| `CreateBitmap` / `CreateImage` / `CreatePicture` / `CreateEmpty` | — | 把既有图 / 矢量当 shader |

> **`CreatePerlinNoise*` 的 `fX` / `fY` 有范围**：上游规定 usual range `(0..1)` 且非负，
> 且**整数频率会让噪声恒为 `0`**（成因、实测与脚本侧的写法见 §2 `displacement` 一节的提醒）。
> `octaves` 上限 255。

### 8.5 `SKMaskFilter`（形状边缘）

| 原生 API | 签名 | 用途 |
|---|---|---|
| `CreateBlur` | `(SKBlurStyle, float σ, [bool respectCTM])` | 形状描边模糊（发光 / 柔边） |
| `CreateTable` | `(byte[] table)` | 形状 alpha 重映射 |
| `CreateGamma` | `(float gamma)` | 形状 alpha 的 gamma |
| `CreateClip` | `(byte min, byte max)` | 形状 alpha 裁剪 |

### 8.6 `SKBlender`（自定义混合，绘制期）

| 原生 API | 签名 | 用途 |
|---|---|---|
| `CreateBlendMode` | `(SKBlendMode mode)` | 标准混合模式当 Blender |
| `CreateArithmetic` | `(float k1..k4, bool enforcePMColor)` | 算术混合当 Blender（同 §8.3 公式） |

### 8.7 `SKRuntimeEffect`（SkSL 三入口）

| 工厂 | 用途 |
|---|---|
| `CreateColorFilter(sksl, out err)` | 逐像素滤镜（entry `half4 main(half4 color)`）→ `ToColorFilter()` |
| `CreateShader(sksl, out err)` | 空间 shader（entry `half4 main(float2 p)`）→ `ToShader(uniforms, children)` |
| `CreateBlender(sksl, out err)` | 自定义混合（entry `half4 main(half4 src, half4 dst)`）→ `ToBlender()` |

> 本版本**没有** `ToImageFilter`（runtime effect 不能产出 ImageFilter），所以"空间效果"只能走
> §8.3 的内置 `SKImageFilter`，或走 §8.4 的 shader 载体（按原图坐标算、可瓦片）。

### 8.8 `SKPaint` 宿主槽位

滤镜最终都挂到 `SKPaint` 的某个槽：

| 槽 | 类型 | 用于 |
|---|---|---|
| `Shader` | `SKShader` | 空间着色 / 渐变 / 噪声 / 颗粒 |
| `MaskFilter` | `SKMaskFilter` | 形状边缘 |
| `ColorFilter` | `SKColorFilter` | 逐像素调色 |
| `ImageFilter` | `SKImageFilter` | 模糊 / 投影 / 形态学 / 卷积（整层） |
| `BlendMode` | `SKBlendMode` | 标准混合 |
| `Blender` | `SKBlender` | 自定义混合 |
| `PathEffect` | `SKPathEffect` | 路径变换（描边虚线等，特效暂不用） |
