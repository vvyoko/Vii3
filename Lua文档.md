<details>
<summary><h1>Lua API 文档</h1></summary>


Vii3 提供了完整的 Lua 脚本接口，允许用户通过脚本扩展应用功能。

---

## 模块概览

| 模块 | 说明 |
|------|------|
| `app` | 应用核心接口，包含属性读写、命令执行、事件监听等 |
| `env` | 环境变量，提供脚本运行时的环境信息 |
| `utils` | 工具函数，包含字符串操作、路径处理、正则表达式等 |
| `factory` | 工厂函数，用于创建定时器等对象 |

---

## app 模块

### app.get_property(key, returnType)

获取应用属性值。

**参数：**
- `key`: string - 属性名称（如 "Zoom", "FillMode"）
- `returnType`: string (可选) - 返回类型
  - `"raw"` (默认): 返回原始值（枚举返回字符串名称）
  - `"display"`: 返回翻译后的显示文本
  - `"number"`: 返回数字值（仅枚举生效）

**返回值：** 属性值

**示例：**
```lua
local zoom = app.get_property("Zoom")
local fillModeName = app.get_property("FillMode")
local fillModeNum = app.get_property("FillMode", "number")
local fillModeText = app.get_property("FillMode", "display")
```

---

### app.set_property(key, value)

设置应用属性值。

**参数：**
- `key`: string - 属性名称
- `value`: any - 属性值（会自动进行类型转换）

**示例：**
```lua
app.set_property("Zoom", 1.5)
app.set_property("FillMode", "FitWindow")
app.set_property("Topmost", true)
```

---

### app.observe_property(key, callback)

监听属性变化事件。

**参数：**
- `key`: string - 属性名称
- `callback`: function(newValue) - 属性变化时的回调函数

**示例：**
```lua
app.observe_property("Path", function(newPath)
    print("当前文件路径已变更:", newPath)
end)
```

---

### app.command(id, param)

执行应用命令。

**参数：**
- `id`: string - 命令名称（如 "CloseApp", "ZoomSet"）
- `param`: any (可选) - 命令参数

**示例：**
```lua
app.command("CloseApp")
app.command("ZoomSet", 1.5)
app.command("Navigate", "Next")
app.command("Toggle", "FullScreen")
```

---

### app.command_can_execute(id, param)

检查命令是否可以执行。

**参数：**
- `id`: string - 命令名称
- `param`: any (可选) - 命令参数

**返回值：** boolean - 是否可以执行

**示例：**
```lua
if app.command_can_execute("CropSave") then
    app.command("CropSave")
end
```

---

### app.add_key_binding(gesture, callback, layer)

注册快捷键绑定。

**参数：**
- `gesture`: string - 快捷键手势（如 "Ctrl+S", "F5"）
- `callback`: function() - 触发时的回调函数
- `layer`: string (可选) - 输入层，默认 `Global`
  - `"Global"`: 全局层
  - `"Thumbnail"`: 缩略图层
  - `"Crop"`: 裁剪层
  - `"Video"`: 视频层

**示例：**
```lua
app.add_key_binding("Ctrl+Shift+S", function()
    print("自定义快捷键触发")
end, "Global")
```

---

### app.on_message(eventName, callback)

注册消息事件监听。

**参数：**
- `eventName`: string - 事件名称
- `callback`: function(...) - 事件回调函数

**示例：**
```lua
app.on_message("MyCustomEvent", function(arg1, arg2)
    print("收到消息:", arg1, arg2)
end)
```

---

### app.off_message(eventName)

取消消息事件监听。

**参数：**
- `eventName`: string - 事件名称

**示例：**
```lua
app.off_message("MyCustomEvent")
```

---

### app.on_shutdown(callback)

注册应用关闭事件。

**参数：**
- `callback`: function() - 应用关闭时的回调函数

**示例：**
```lua
app.on_shutdown(function()
    print("应用即将关闭")
end)
```

---

### app.send_message(target, funcName, ...)

向其他脚本发送消息。

**参数：**
- `target`: string - 目标脚本ID（脚本文件名不含后缀）
- `funcName`: string - 目标函数名
- `...`: any - 可变参数

**示例：**
```lua
app.send_message("Slideshow", "play", "next")
app.send_message("MyScript", "notify", "hello", 123)
```

---

### app.toast

消息通知接口，支持多种快捷方法和自定义配置。

#### 快捷方法

```lua
app.toast.info(message, id, duration)    -- 信息提示
app.toast.success(message, id, duration) -- 成功提示
app.toast.error(message, id, duration)   -- 错误提示
app.toast.warn(message, id, duration)    -- 警告提示
app.toast.center(message, id, duration)  -- 居中提示
app.toast.at(message, x, y, id, duration) -- 指定位置提示
```

**参数：**
- `message`: string - 消息内容
- `id`: string (可选) - 消息ID，用于覆盖相同ID的消息
- `duration`: number (可选) - 显示时长（毫秒），默认2000
- `x`, `y`: number - 坐标位置

#### 自定义配置

```lua
app.toast.show({
    text = "消息内容",
    id = "my_id",
    duration = 3000,
    type = "custom",
    color = "#FF0000",
    bgColor = "#000000",
    fontSize = 14,
    radius = 8,
    align = 1,
    x = 100,
    y = 200
})
```

**配置项：**
- `text`: string - 消息文本
- `id`: string - 消息ID
- `duration`: number - 显示时长
- `type`: string - 类型 (`"default"`, `"success"`, `"error"`, `"warning"`, `"info"`, `"center"`, `"custom"`)
- `color`: string - 文字颜色
- `bgColor`: string - 背景颜色
- `fontSize`: number - 字体大小
- `radius`: number - 圆角半径
- `align`: number - 对齐方式 (0=Left, 1=Center, 2=Right)
- `x`, `y`: number - 显示位置

---

## env 模块

### env.id

当前脚本的ID（文件名不含后缀）。

**类型：** string

**示例：**
```lua
print("当前脚本ID:", env.id)
```

---

### env.ScriptsDir

脚本目录路径。

**类型：** string

---

### env.AppDir

应用程序目录路径。

**类型：** string

---

### env.TempDir

临时目录路径。

**类型：** string

---

## utils 模块

### utils.sleep(ms)

阻塞式睡眠。

**参数：**
- `ms`: number - 睡眠时间（毫秒）

**示例：**
```lua
utils.sleep(1000)  -- 等待1秒
```

---

### utils.wait(ms, callback)

非阻塞式等待。

**参数：**
- `ms`: number - 等待时间（毫秒）
- `callback`: function() - 等待完成后的回调

**示例：**
```lua
utils.wait(2000, function()
    print("等待完成")
end)
```

---

### utils.execute_process(exePath, arguments, workingDir, hidden, waitForExit, codepage)

执行外部程序。

**参数：**
- `exePath`: string - 可执行文件路径
- `arguments`: string (可选) - 命令行参数，默认为空
- `workingDir`: string (可选) - 工作目录，默认为空
- `hidden`: boolean (可选) - 是否隐藏窗口，默认false
- `waitForExit`: boolean (可选) - 是否等待程序完成，默认false
- `codepage`: number (可选) - 输出编码代码页，默认0（自动）

**返回值：**
- `waitForExit=false` 时返回 `{ pid = number }`
- `waitForExit=true` 时返回 `{ exitCode = number, stdout = string, stderr = string }`
- 失败时返回 `nil`

**示例：**
```lua
-- 异步执行
local result = utils.execute_process("notepad.exe", "test.txt", "", false, false)
print("进程ID:", result.pid)

-- 同步执行并等待完成
local result = utils.execute_process("ping.exe", "localhost", "", false, true)
print("退出码:", result.exitCode)
print("标准输出:", result.stdout)
```

---

### utils.path_get_dir(path)

获取文件路径的目录部分。

**参数：**
- `path`: string - 文件路径

**返回值：** string - 目录路径

**示例：**
```lua
local dir = utils.path_get_dir("C:\\Files\\image.jpg")
-- 返回: "C:\\Files"
```

---

### utils.path_get_name(path)

获取文件名（含扩展名）。

**参数：**
- `path`: string - 文件路径

**返回值：** string - 文件名

**示例：**
```lua
local name = utils.path_get_name("C:\\Files\\image.jpg")
-- 返回: "image.jpg"
```

---

### utils.path_get_ext(path)

获取文件扩展名。

**参数：**
- `path`: string - 文件路径

**返回值：** string - 扩展名（含点号）

**示例：**
```lua
local ext = utils.path_get_ext("C:\\Files\\image.jpg")
-- 返回: ".jpg"
```

---

### utils.path_get_name_without_ext(path)

获取文件名（不含扩展名）。

**参数：**
- `path`: string - 文件路径

**返回值：** string - 文件名

**示例：**
```lua
local name = utils.path_get_name_without_ext("C:\\Files\\image.jpg")
-- 返回: "image"
```

---

### utils.path_get_unique(basePath, createDir)

获取唯一路径（避免文件覆盖）。

**参数：**
- `basePath`: string - 基础路径
- `createDir`: boolean - 是否创建目录

**返回值：** string - 唯一路径

**示例：**
```lua
local uniquePath = utils.path_get_unique("C:\\Files\\output.jpg", true)
```

---

### utils.str_lower(str)

转换为小写。

**参数：**
- `str`: string - 输入字符串

**返回值：** string - 小写字符串

---

### utils.str_upper(str)

转换为大写。

**参数：**
- `str`: string - 输入字符串

**返回值：** string - 大写字符串

---

### utils.str_trim(str)

去除首尾空白字符。

**参数：**
- `str`: string - 输入字符串

**返回值：** string - 处理后的字符串

---

### utils.str_replace(str, old, new)

替换字符串。

**参数：**
- `str`: string - 原始字符串
- `old`: string - 要替换的子串
- `new`: string - 新字符串

**返回值：** string - 替换后的字符串

---

### utils.str_contains(str, value)

检查字符串是否包含指定子串。

**参数：**
- `str`: string - 原始字符串
- `value`: string - 要查找的子串

**返回值：** boolean - 是否包含

---

### utils.regex_match(haystack, needle)

正则表达式匹配。

**参数：**
- `haystack`: string - 要搜索的字符串
- `needle`: string - 正则表达式模式

**返回值：** 匹配结果对象 `{ index = number, match = table }`
- `index`: number - 匹配位置（从1开始），0表示未匹配
- `match`: table - 匹配详情
  - `[0]`, `[1]`, ...: 捕获组内容
  - `["name"]`: 命名捕获组内容
  - `Value`: 所有捕获组值的表
  - `Pos`: 所有捕获组位置的表
  - `Len`: 所有捕获组长度的表
  - `Count`: 捕获组数量

**示例：**
```lua
local result = utils.regex_match("Hello World 123", "World (\\d+)")
if result.index > 0 then
    print("匹配位置:", result.index)
    print("捕获组1:", result.match[1])
end
```

---

### utils.regex_replace(haystack, needle, replacement, limit, startingPos)

正则表达式替换。

**参数：**
- `haystack`: string - 要处理的字符串
- `needle`: string - 正则表达式模式
- `replacement`: string - 替换字符串
- `limit`: number (可选) - 最大替换次数，默认-1（无限制）
- `startingPos`: number (可选) - 开始位置，默认1

**返回值：** 替换结果对象 `{ result = string, count = number }`
- `result`: string - 替换后的字符串
- `count`: number - 替换次数

**示例：**
```lua
local result = utils.regex_replace("aabbcc", "b", "x", 1)
-- result.result = "aaxbcc"
-- result.count = 1
```

---

### utils.clip_set(text)

设置剪贴板文本。

**参数：**
- `text`: string - 要设置的文本

**示例：**
```lua
utils.clip_set("复制到剪贴板的内容")
```

---

### utils.clip_get()

获取剪贴板文本。

**返回值：** string - 剪贴板内容

**示例：**
```lua
local text = utils.clip_get()
print("剪贴板内容:", text)
```

---

## factory 模块

### factory.timer(interval, callback)

创建定时器。

**参数：**
- `interval`: number - 定时间隔（毫秒）
- `callback`: function() - 定时触发的回调函数

**返回值：** LuaTimer 对象，具有以下方法：
- `start()`: 启动定时器
- `stop()`: 停止定时器
- `dispose()`: 释放定时器资源

**示例：**
```lua
local timer = factory.timer(1000, function()
    print("每秒执行一次")
end)
timer.start()

-- 5秒后停止
utils.wait(5000, function()
    timer.stop()
    timer.dispose()
end)
```

---

## 使用示例

### 示例1：创建一个简单的定时器脚本

```lua
local timer = factory.timer(2000, function()
    local path = app.get_property("Path")
    app.toast.info("当前文件: " .. path, "file_watcher", 1500)
end)

timer.start()

app.on_shutdown(function()
    timer.stop()
    timer.dispose()
end)
```

### 示例2：注册快捷键

```lua
app.add_key_binding("Ctrl+Shift+Z", function()
    local zoom = app.get_property("Zoom")
    app.set_property("Zoom", zoom * 1.2)
    app.toast.success("放大: " .. string.format("%.1f%%", zoom * 120))
end)
```

### 示例3：监听属性变化

```lua
app.observe_property("FillMode", function(newMode)
    print("填充模式已变更为:", newMode)
end)
```

### 示例4：发送消息到其他脚本

```lua
-- 在 ScriptA.lua 中
app.on_message("custom_event", function(data)
    print("收到消息:", data)
end)

-- 在 ScriptB.lua 中
app.send_message("ScriptA", "custom_event", "Hello from ScriptB")
```
</details>