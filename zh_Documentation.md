## 特殊
- 动态照片
  - 播放动态照片中的视频流依赖于 `libmpv-2.dll`。
  - 由于文件体积较大且涉及开源协议传染性，本软件默认不附带此组件，有需求的用户需自行下载并放置于 `vii3.exe` 同级目录下。
  - 下载方案：
    - A（体积小, 版本旧）：下载 [media-kit (v1.1.10)](https://github.com/media-kit/media-kit/releases/tag/media_kit-v1.1.10) 发布的 `media_kit_test_win32_x64.7z`，解压并提取其中的 `libmpv-2.dll`。
    - B（体积大,版本新）： 下载 [zhongfly/mpv-winbuild](https://github.com/zhongfly/mpv-winbuild/releases)  `mpv-dev-x86_64-v3` 或 `mpv-dev-x86_64` ，解压并提取其中的 `libmpv-2.dll`。
  - 复用方案: 
    - 若你在系统其他地方已拥有该组件，可彻底退出软件后，打开程序目录下的 `data\set.json` 文件。
    - 找到 `"LibMpvPath"` 字段，将其值修改为你想复用的 `libmpv-2.dll` 的**绝对路径**。
      - 文件名必需为 `libmpv-2.dll` 而不是 `libmpv.dll` 或其他
      - 路径需符合 `Json` 规范使用转义 `\\` 或用 `/`
      - 如 `"LibMpvPath": "D:\\OneDrive\\Program\\AHK\\lib\\libmpv\\libmpv-2.dll"`
- 加载流程
  - 图片的定义是后缀名是图片后缀名
  - 打开单张图片会打开同目录下所有图片
    - 会启动文件变更监听以响应外部修改
    - 即外部程序删除,修改文件会响应并更新
  - 打开文件夹本身会搜索包括子文件夹下所有图片
    - 不会扫描压缩包
  - 打开压缩包会搜索压缩包内所有图片文件
  - 可以同时打开多个图片,文件夹,压缩包
    - 文件夹会搜索子文件夹
  - 除直接打开单张图片,其他情况不会响应外部修改
  - 可通过拖拽,粘贴,运行参数加载
    - 运行参数加载(可传递多个或单个)
      - `Vii3.exe img1 img2 dir1 dir2 zip1 rar2`
- 文件关联图标
  - 未提供的原因是我无力制作较美观的图标
  - 在`data`目录下新建子文件夹`icons`
  - 获取或制作 `ico` 格式的图标
  - 以 `后缀名.ico` 格式命名 
     - 如 `bmp.ico` `jpg.ico` 
- 临时目录位置 `%temp%\vvyoko\Vii3`
  - 暂时只存放日志
  - 压缩包,动态照片中视频已完全迁至内存流
- 快捷键
  - 层级 - 除全局外其余是同级,优先执行非全局
  - 右键菜单部分不显示快捷键是因为它只能放它认为的快捷键
  - Lua 中定义的快捷键会覆盖设置中的快捷键
  - 设置中的快捷键显示太乱属于美工无力
  - 缩略图层级绑定限制
    - 请勿绑定任何涉及鼠标按键或滚轮的操作（即使带有 Ctrl/Shift 等修饰键）。
    - 因为缩略图的原生控件本身会强行持有鼠标事件
    - 自定义的鼠标绑定大概率会被控件拦截而失效。
- 在标题和图片信息处按住左键可移动窗口位置
- 缩略图
  - 缓存命中与失效机制：
    - 匹配阈值：请求质量与缓存质量绝对差值 ≤ 10，且请求尺寸与缓存宽或高任意一项的绝对差值 ≤ 10。
    - 失效重构：若调整幅度超出上述容差范围，旧缓存将直接判定为失效并跳过，随后触发新缓存的生成与覆盖。
  - 允许命令
    - ThumbnailGridAction
    - CloseApp
    - SendMessageToScript
      - 如有必要可借助它(Lua)实现其他命令
    - Navigate
      - NextFolderOrArchive
      - PrevFolderOrArchive
- Ocr
  - 模型下载
    - 从 `Microsoft Store` 下载 [Microsoft 照片](https://apps.microsoft.com/detail/9wzdncrfjbh4)
    - 打开应用,打开任务管理器,右键 `照片`-`照片`, 打开文件所在位置
    - 复制 `oneocr.dll` `oneocr.onemodel` `onnxruntime.dll` 到 `Vii3` 所在目录
  - 在 `快捷键` - `全局` 添加新快捷键,绑定至命令 `切换` 参数 `Ocr`
- 命令行参数
  - 以 `--` 开始的是待执行命令
    - 格式 `--命令名[=可选参数]`
    - 参数包含空格用`"参数"`裹住
    - 不保证执行顺序
    - 不保证在初始阶段可执行
    - 可视为它是专门为特殊操作服务的
    - 如剪贴板命令,运行并执行指定命令,以打开剪贴板中图片
      - `Vii3.exe --OpenClipboardFilesOrImage --SendMessageToScript="CleanMode On"`
      - AutoHotkey 示例脚本
        ```
          OnClipboardChange(ClipChanged)
          Vii3Path := "路径"
          ClipChanged(clipType)
          {
              if (clipType == 2 && ;图片
                  !WinActive("ahk_exe Vii3.exe"))
              {
                  ; if (WinActive("ahk_exe chrome.exe"))
                  Run(Vii3Path ' --OpenClipboardFilesOrImage --SendMessageToScript="CleanMode On"')
              }
          }
        ```
  - 遇到第一个以非 `--` 开始直到结束,都视为文件或文件夹并加载

---
## 设置
  - 通用设置手动编辑选项
    - 需退出程序后编辑 `data\set.json`
    - 未在设置界面添加代表不希望普通用户去自定义
    - `LibMpvPath` 参考上文
    - `OneOcrDirectory` 设置OCR模型文件夹位置,复用模型,注意部分目录无权限读取如`WindowsApps`
    - `Background`
      - 用于设置软解渲染下背景颜色 `#AARRGGBB` 或 `#RRGGBB`
      - 无效值或未设置回退至 `#202020`
    - `DateTimeFormat` 指定日期格式
      - 参考 [自定义日期和时间格式字符串](https://learn.microsoft.com/dotnet/standard/base-types/custom-date-and-time-format-strings)
      - 示例 `yyyy-MM-dd hh:mm:ss` -> `2026-09-05 19:13:34`
    - [DebugOverlays](https://docs.avaloniaui.net/api/avalonia/rendering/rendererdebugoverlays) 性能测试
      - 0 `None`
      - 1 `Fps`
      - 2 `DirtyRects`
      - 4 `LayoutTimeGraph`
      - 8 `RenderTimeGraph`

  - 快捷键和菜单
    - 如参数或目标值不明白如何设置
    - 悬浮 `命令` `绑定状态` 查看原始值
    - 并在下方定义中搜索并查看其详细说明
---
<details>
<summary><h2 style="display: inline; margin: 0; font-size: 1.5em;">定义</h2></summary>

<details style="margin-left: 20px;" open>
<summary><b>命令</b></summary>

* #### CloseApp
  - 说明: 退出程序
  - ID: 1
* #### OpenSetting
  - 说明: 打开设置界面
  - ID: 2
* #### ShowContextMenu
  - 说明: 显示右键菜单
  - ID: 3
* #### Open
  - 说明: 打开文件对话框
  - ID: 4
* #### Navigate
  - 说明: 导航
  - ID: 5
  - 参数: [NavigationType](#NavigationType)
* #### Toggle
  - 说明: 切换
  - ID: 6
  - 参数: [ToggleTarget](#ToggleTarget)
  
* #### SendMessageToScript
  - 说明: 向脚本引擎发送消息
  - ID: 21
  - 参数: `string` 
    - 举例: 脚本ID 函数名 [参数 1 参数 2 ...]
      - 脚本ID 是`data\scripts`目录下lua文件无后缀文件名, 如 `Slideshow`
    - 转换优先级：带引号的字符串 → true/false → 整数 → 小数 → 普通字符串
    - 带空格的参数需用双引号包裹（如 "hello world"），双引号转义用 \""
* #### Sort
  - 说明: 设置排序方式
  - ID: 130
  - 参数: [SortField](#SortField)
* #### ShowCacheStatistics
  - 说明: 查看缓存统计
  - ID: 140
* #### LoadFiles
  - 说明: 加载文件
  - ID: 190
  - 参数: string[]
  - 内部属性
* #### ZoomSet
  - 说明: 设置缩放比例（绝对数值）
  - ID: 201
  - 参数: `double` 
    - 举例: `1.1` -> 设置当前缩放为 110%
* #### SetFillMode
  - 说明: 设置填充模式
  - ID: 202
  - 参数: [ImageFillMode](#ImageFillMode)
* #### ZoomIn
  - 说明: 放大
  - ID: 203
* #### ZoomOut
  - 说明: 缩小
  - ID: 204
* #### RotateMirror
  - 说明: 旋转&镜像
  - ID: 210
  - 参数: [SortField](#SortField)
* #### LoadOriginalImage
  - 说明: 加载/查看原图
  - ID: 220
* #### ThumbnailGridAction
  - 说明: 缩略图动作
  - ID: 230
  - 参数: [ThumbnailGridAction](#ThumbnailGridAction)
* #### VideoAction
  - 说明: 视频动作
  - ID: 240
  - 参数: [VideoAction](#VideoAction)
* #### SelectorSet
  - 说明: 设置选择器
  - ID: 300
  - 参数: `double` 
    - `-2.0` -> 切换选择器
    - `-1.0` -> 关闭选择器
    - `≥0` -> 开启并设选择比例
* #### CropSave
  - 说明: 保存当前裁剪区域
  - ID: 301
* #### SelectorAdjustAction
  - 说明: 选框调整
  - ID: 305
  - 参数: [SelectorAdjustment](#SelectorAdjustment)
* #### RotateMirrorSave
  - 说明: 保存旋转镜像
  - ID: 310
* #### CropSaveToPath
  - 说明: 保存裁剪到指定路径
  - ID: 320
  - 参数: string
    - 指定要保存的文件路径
* #### RotateMirrorSaveToPath
  - 说明: 保存旋转镜像到指定路径
  - ID: 322
  - 参数: string
    - 指定要保存的文件路径
* #### ConvertImageFormat
  - 说明: 转换图片格式
    - 只能转换当前图片
    - 仅适用于临时用途
  - ID: 330
  - 参数: string
    - 目标图片格式后缀名
    - 举例: `.jpg` 转换至 `Jpg` 格式
* #### FileRecycle
  - 说明: 移至回收站
  - ID: 350
* #### ShowInFolder
  - 说明: 在资源管理器中定位
  - ID: 351
* #### SetWallPaper
  - 说明: 设为桌面壁纸
  - ID: 352
* #### CreateCopy
  - 说明: 创建副本
  - ID: 353
* #### CreateCopyToPath
  - 说明: 创建副本到指定路径
  - ID: 354
  - 参数: string
    - 指定要保存的文件路径
* #### ExportPlaylist
  - 说明: 导出播放列表
  - ID: 355
* #### OpenClipboardFilesOrImage
  - 说明: 打开剪贴板文件/图片
    - 除 [CopyFormat](#CopyFormat) 的类型, 额外支持 `<svg>...</svg>`
  - ID: 361
* #### Copy
  - 说明: 复制
  - ID: 362
  - 参数: [CopyFormat](#CopyFormat)
* #### OpenWithExternalProgram
  - 说明: 调用外部程序打开当前文件
  - ID: 370
  - 参数: string
    - 运行程序EXE|可选程序参数|可选是否隐藏|可选运行文件夹
    - 占位符 
      - `<path>` -> 当前文件路径
      - `<dir>` -> 当前文件文件夹
      - `<AppDir>` -> `Vii3.exe` 所在文件夹
      - `<ConfDir>` -> `data` 所在文件夹
      - `<TempDir>` -> `%temp%\vvyoko\Vii3`
    - 参数解析规则
      - 运行程序EXE：可含空格（无需加引号），支持系统命令（如notepad）和占位符
      - 程序参数：按引号/空格拆分为参数数组处理，规则如下
        - 以"开头则取到"结束作为单个参数，否则按空格拆分
        - 替换占位符后，无引号且含空格的参数自动加引号
        - 手动加引号的参数保留引号，不重复处理
    - 是否隐藏：0=显示外部程序窗口（默认），1=隐藏外部程序窗口
    - 运行文件夹：支持占位符替换，替换后自动标准化为绝对路径
    - 分隔符：| 仅作为参数分隔符
    - 举例: `mspaint` -> 用画图打开当前文件
* #### ClearDatabase
  - 说明: 清理配置目录中数据库
  - ID: 371
* #### ClearDatabasePath
  - 说明: 清理指定文件夹数据库
  - ID: 372
  - 参数: string
    - 清理指定目录下的数据库
* #### OpenGpsMap
  - 说明: 打开地图定位
  - ID: 380
  - 参数: string (URL)
    - 占位符 
      - 坐标体系 (指定时添加到URL前面并追加 `|`)
        - `GCJ02`
        - `BD09`
        - `WGS84` (默认)
      - `{lat}` 纬度
      - `{lng}` 经度
    - 举例: `BD09|https://api.map.baidu.com/marker?location={lat},{lng}&output=html`
    - 举例: `https://maps.google.com/?q={lat},{lng}`
* #### CycleCropRatio
  - 说明: 循环切换裁剪比例
  - ID: 401
  - 参数: string
    - 值用英文逗号分隔（如`16:9,4:3,1:1`或`1.778,1.333,1.0`）
    - 比例支持 简单无括号四则运行 解析（如"16:9"→1.778），且必须>0
* #### CycleSortType
  - 说明: 循环切换排序模式
  - ID: 402
  - 参数: ([SortField](#SortField))
    -  示例: `Path,Size`
* #### CycleFillMode
  - 说明: 循环切换填充模式
  - ID: 403
  - 参数: ([ImageFillMode](#ImageFillMode))
    -  示例: `FillWindow,FitWindow`
</details>
<details style="margin-left: 20px;" open>
<summary><b>属性</b></summary>

* #### None
  - 说明: 无
  - ID: 0
  - 类型: -
* #### SortMode
  - 说明: 排序类型
  - ID: 1
  - 类型: [SortField](#SortField)
* #### IsSortDescend
  - 说明: 是否逆序
  - ID: 30
  - 类型: bool
* #### IsFolderLooping
  - 说明: 文件夹是否循环
  - ID: 31
  - 类型: bool
* #### WindowState
  - 说明: 窗口状态
  - ID: 100
  - 类型: WindowState
    - Normal
    - Minimized
    - Maximized
    - FullScreen
* #### IsWindowTopmost
  - 说明: 窗口是否置顶
  - ID: 130
  - 类型: bool
* #### IsWindowLocked
  - 说明: 窗口是否锁定
  - ID: 131
  - 类型: bool
* #### IsWindowFitsImage
  - 说明: 窗口是否适应图片
  - ID: 160
  - 类型: bool
* #### IsTitleVisible
  - 说明: 标题是否显示
  - ID: 200
  - 类型: bool
* #### IsImageInfoVisible
  - 说明: 图片信息是否显示
  - ID: 201
  - 类型: bool
* #### IsThumbnailVisible
  - 说明: 缩略图是否显示
  - ID: 202
  - 类型: bool
* #### IsMiniMapEnabled
  - 说明: 迷你地图是否启用
  - ID: 230
  - 类型: bool
* #### IsSideArrowEnabled
  - 说明: 侧边方向键是否启用
  - ID: 231
  - 类型: bool
* #### IsBottomButtonsEnabled
  - 说明: 底部操作栏是否启用
  - ID: 232
  - 类型: bool
* #### IsInCropMode
  - 说明: 是否处于裁剪模式
  - ID: 260
  - 类型: bool
* #### IsInOcrMode
  - 说明: 是否处于Ocr模式
  - ID: 261
  - 类型: bool
* #### FillMode
  - 说明: 填充模式
  - ID: 500
  - 类型: [ImageFillMode](#ImageFillMode)
* #### MirrorMode
  - 说明: 镜像模式
  - ID: 501
  - 类型: ImageMirrorMode
    - None
    - Horizontal
    - Vertical
* #### ZoomFactor
  - 说明: 缩放比例
  - ID: 530
  - 类型: double
  - 合法值: 0.1-10.0
* #### RotateAngle
  - 说明: 旋转角度
  - ID: 531
  - 类型: double
  - 合法值: 0, 90, 180, 270
* #### CropRatio
  - 说明: 裁剪比例
  - ID: 533
  - 类型: double
  - 合法值:
    - `-2.0` -> 切换裁剪模式
    - `-1.0` -> 关闭裁剪
    - `≥0` -> 开启并设裁剪比例
* #### IsImageTopAligned
  - 说明: 图片是否对齐顶部
  - ID: 560
  - 类型: bool
* #### Path
  - 说明: 当前文件路径
  - ID: 1000
  - 类型: string
  - 不可写
* #### HasImage
  - 说明: 是否存在图片
  - ID: 1010
  - 类型: bool
  - 内部属性
* #### HasFile
  - 说明: 是否存在文件
  - ID: 1011
  - 类型: bool
  - 内部属性
* #### FileCount
  - 说明: 文件总数
  - ID: 1012
  - 类型: int
  - 内部属性
* #### CanNavigate
  - 说明: 是否可以上下翻页导航
  - ID: 1013
  - 类型: bool
  - 内部属性
</details>

<details style="margin-left: 20px;" id="InputLayer" open>
<summary><b>InputLayer</b></summary>

* ##### Global
  - 说明: 全局
  - ID: 0
* ##### Thumbnail
  - 说明: 缩略图
  - ID: 1
* ##### Crop
  - 说明: 裁剪
  - ID: 2
* ##### Video
  - 说明: 视频
  - ID: 3
* ##### Ocr
  - 说明: Ocr
  - ID: 4
</details>

<details style="margin-left: 20px;" id="SelectorAdjustment" open>
<summary><b>SelectorAdjustment</b></summary>

* ##### MoveUp
  - 说明: 选框上移
  - ID: 0
* ##### MoveDown
  - 说明: 选框下移
  - ID: 1
* ##### MoveLeft
  - 说明: 选框左移
  - ID: 2
* ##### MoveRight
  - 说明: 选框右移
  - ID: 3
* ##### EnlargeTop
  - 说明: 上边缘放大
  - ID: 4
* ##### EnlargeBottom
  - 说明: 下边缘放大
  - ID: 5
* ##### EnlargeLeft
  - 说明: 左边缘放大
  - ID: 6
* ##### EnlargeRight
  - 说明: 右边缘放大
  - ID: 7
* ##### ShrinkTop
  - 说明: 上边缘缩小
  - ID: 8
* ##### ShrinkBottom
  - 说明: 下边缘缩小
  - ID: 9
* ##### ShrinkLeft
  - 说明: 左边缘缩小
  - ID: 10
* ##### ShrinkRight
  - 说明: 右边缘缩小
  - ID: 11
* ##### SelectAll
  - 说明: 全选
  - ID: 12
* ##### ResetCrop
  - 说明: 重置选框
  - ID: 13
</details>

<details style="margin-left: 20px;" id="ThumbnailGridAction" open>
<summary><b>ThumbnailGridAction</b></summary>

* ##### MoveUp
  - 说明: 向上移动
  - ID: 0
* ##### MoveDown
  - 说明: 向下移动
  - ID: 1
* ##### MoveLeft
  - 说明: 向左移动
  - ID: 2
* ##### MoveRight
  - 说明: 向右移动
  - ID: 3
* ##### MoveToFirst
  - 说明: 跳至第一项
  - ID: 4
* ##### MoveToLast
  - 说明: 跳至最后一项
  - ID: 5
* ##### ScrollUp
  - 说明: 向上翻
  - ID: 6
* ##### ScrollDown
  - 说明: 向下翻
  - ID: 7
* ##### OpenSelected
  - 说明: 打开选中项
  - ID: 8
* ##### ZoomIn
  - 说明: 放大
  - ID: 9
* ##### ZoomOut
  - 说明: 缩小
  - ID: 10
</details>

<details style="margin-left: 20px;" id="VideoAction" open>
<summary><b>VideoAction</b></summary>

* ##### Play
  - 说明: 播放
  - ID: 0
* ##### ToggleMute
  - 说明: 切换静音
  - ID: 1
</details>

<details style="margin-left: 20px;" id="SaveMode" open>
<summary><b>SaveMode</b></summary>

* ##### Auto
  - 说明: 自动保存为新文件
  - ID: 0
* ##### Ask
  - 说明: 询问保存路径
  - ID: 1
* ##### Replace
  - 说明: 替换原文件
  - ID: 2
</details>

<details style="margin-left: 20px;" id="ImageFillMode" open>
<summary><b>ImageFillMode</b></summary>

* ##### Original
  - 说明: 原始大小
  - ID: 0
* ##### FitWindow
  - 说明: 适合窗口
  - ID: 1
* ##### FillWindow
  - 说明: 填充窗口
  - ID: 2
* ##### FitWidth
  - 说明: 适合宽度
  - ID: 3
* ##### FitHeight
  - 说明: 适合高度
  - ID: 4
* ##### StretchWidth
  - 说明: 拉伸宽度 (在图片分辨率小于窗口时, 放大宽度适应窗口)
  - ID: 5
* ##### StretchHeight
  - 说明: 拉伸高度 (在图片分辨率小于窗口时, 放大高度适应窗口)
  - ID: 6
</details>

<details style="margin-left: 20px;" id="SortField" open>
<summary><b>SortField</b></summary>

* ##### Path
  - 说明: 路径
  - ID: 0
* ##### Size
  - 说明: 大小
  - ID: 1
* ##### Extension
  - 说明: 后缀名
  - ID: 2
* ##### CreationTime
  - 说明: 创建时间
  - ID: 3
* ##### LastWriteTime
  - 说明: 修改时间
  - ID: 4
* ##### Resolution
  - 说明: 分辨率
  - ID: 5
* ##### AspectRatio
  - 说明: 宽高比
  - ID: 6
* ##### Width
  - 说明: 宽度
  - ID: 7
* ##### Height
  - 说明: 高度
  - ID: 8
* ##### Random
  - 说明: 随机
  - ID: 9
</details>

<details style="margin-left: 20px;" id="ToggleTarget" open>
<summary><b>ToggleTarget</b></summary>

* ##### Title
  - 说明: 标题
  - ID: 1
* ##### ImageInfo
  - 说明: 图片信息
  - ID: 2
* ##### Topmost
  - 说明: 置顶
  - ID: 3
* ##### FullScreen
  - 说明: 全屏
  - ID: 4
* ##### Maximized
  - 说明: 最大化
  - ID: 5
* ##### WindowLock
  - 说明: 窗口锁定 (启用时程序内部窗口会锁定大小, 位置)
  - ID: 6
* ##### SortDescend
  - 说明: 逆序
  - ID: 10
* ##### Thumbnail
  - 说明: 缩略图
  - ID: 20
* ##### MiniMap
  - 说明: 迷你地图
  - ID: 30
* ##### ImageTopAligned
  - 说明: 图片顶部对齐
  - ID: 31
* ##### Crop
  - 说明: 裁剪
  - ID: 32
* ##### Ocr
  - 说明: Ocr
  - ID: 33
* ##### WindowFitsImage
  - 说明: 窗口适应图片
  - ID: 35
</details>

<details style="margin-left: 20px;" id="NavigationType" open>
<summary><b>NavigationType</b></summary>

* ##### Next
  - 说明: 下一张
  - ID: 0
* ##### Prev
  - 说明: 上一张
  - ID: 1
* ##### First
  - 说明: 第一张
  - ID: 2
* ##### Last
  - 说明: 最后一张
  - ID: 3
* ##### Random
  - 说明: 随机一张
  - ID: 4
* ##### NextFolderOrArchive
  - 说明: 下个文件夹/压缩包
  - ID: 10
* ##### PrevFolderOrArchive
  - 说明: 上个文件夹/压缩包
  - ID: 11
* ##### ScrollNextPage
  - 说明: 滚动至下一页
  - ID: 20
* ##### ScrollPreviousPage
  - 说明: 滚动至上一页
  - ID: 21
</details>

<details style="margin-left: 20px;" id="CopyFormat" open>
<summary><b>CopyFormat</b></summary>

* ##### Image
  - 说明: 复制图片
  - ID: 0
* ##### ImageToBase64
  - 说明: 复制图片Base64
  - ID: 1
* ##### Path
  - 说明: 复制路径
  - ID: 10
* ##### File
  - 说明: 复制文件
  - ID: 11
* ##### ImageInfo
  - 说明: 复制图片信息 (包含界面上显示的数据及AI Prompt, XMP)
  - ID: 20
</details>


<details style="margin-left: 20px;" id="RotateMirrorType" open>
<summary><b>RotateMirrorType</b></summary>

* ##### Restore
  - 说明: 重置
  - ID: 0
* ##### RotateRight
  - 说明: 向右旋转
  - ID: 1
* ##### RotateLeft
  - 说明: 向左旋转
  - ID: 2
* ##### RotateReverse
  - 说明: 反向旋转
  - ID: 3
* ##### MirrorHorizontal
  - 说明: 水平镜像
  - ID: 4
* ##### MirrorVertical
  - 说明: 垂直镜像
  - ID: 5
</details>

<details style="margin-left: 20px;" id="RotateMirrorType" open>
<summary><b>OcrAction</b></summary>

* ##### SelectAll 
  - 说明: 全选
  - ID: 1
* ##### ExpandCurrentSelection 
  - 说明: 扩展选择(全选当前已有部分选中的`Box`)
  - ID: 2
* ##### Copy
  - 说明: 复制
    - 包含基础排版重组功能
    - 遵循阅读顺序尽可能还原布局,但不保证完美复刻
    - 字符串本身不包含布局,所以不会也不可能补充多个空格强制对齐
    - 多 `Box` 合并至同一行以制表符 `Tab` 分隔
    - 其余空白属于源数据中空白或单个 `Box` 未全选时兜底情况
    - 它可抗部分倾斜以合并不处于同一水平线上的 `Box` 为同一行
  - ID: 10
* ##### CopyUnordered
  - 说明: 无序复制 (按坐标位置从上到下每个一行)
  - ID: 11
* ##### CopyJson
  - 说明: 复制Json (源数据)
  - ID: 12
</details>



<details style="margin-left: 20px;" id="RotateMirrorType" open>
<summary><b>AppEvent</b></summary>

* ##### Shutdown
  - 说明: 程序退出触发
  - ID: 1
* ##### ImageLoaded
  - 说明: 每次图片加载完成后触发
  - ID: 10
</details>

</details>