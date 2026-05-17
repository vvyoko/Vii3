## 特殊
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


## 设置
  - 请悬浮查看注释,如仍不知用途可反馈

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
* #### ZoomMultiply
  - 说明: 设置缩放倍数（相对当前值）
  - ID: 200
  - 参数: `double` 
    - 举例: `1.1` -> 当前缩放 * 1.1
* #### ZoomSet
  - 说明: 设置缩放比例（绝对数值）
  - ID: 201
  - 参数: `double` 
    - 举例: `1.1` -> 设置当前缩放为 110%
* #### SetFillMode
  - 说明: 设置填充模式
  - ID: 202
  - 参数: [ImageFillMode](#ImageFillMode)
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
* #### CropSet
  - 说明: 设置裁剪模式
  - ID: 300
  - 参数: `double` 
    - `-2.0` -> 切换裁剪模式
    - `-1.0` -> 关闭裁剪
    - `≥0` -> 开启并设裁剪比例
* #### CropSave
  - 说明: 保存当前裁剪区域
  - ID: 301
* #### CropAdjustAction
  - 说明: 裁剪选框调整
  - ID: 305
  - 参数: [CropAdjustment](#CropAdjustment)
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
    - mspaint -> 用画图打开当前文件
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
      - 坐标体系 (指定时旋转URL最前)
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
  - 参数: string ([SortField](#SortField))
    -  示例: `Path,Size`
* #### CycleFillMode
  - 说明: 循环切换填充模式
  - ID: 403
  - 参数: string ([ImageFillMode](#ImageFillMode))
    -  示例: `FillWindow,FitWindow`
</details>

<details style="margin-left: 20px;" open>
<summary><b>属性</b></summary>

* #### SortField
  - 说明: 排序类型
  - ID: 1
  - 类型: [SortField](#SortField)
* #### SortDescend
  - 说明: 是否降序
  - ID: 2
  - 类型: bool
* #### FillMode
  - 说明: 填充模式
  - ID: 3
  - 类型: [ImageFillMode](#ImageFillMode)
* #### IsFolderLooping
  - 说明: 文件夹循环
  - ID: 4
  - 类型: bool
* #### WindowState
  - 说明: 窗口状态
  - ID: 100
  - 类型: WindowState
    - Normal
    - Minimized
    - Maximized
    - FullScreen
* #### Topmost
  - 说明: 窗口置顶状态
  - ID: 101
  - 类型: bool
* #### IsImageInfoEnabled
  - 说明: 是否启用图片信息
  - ID: 110
  - 类型: bool
* #### IsTitleEnabled
  - 说明: 是否启用标题
  - ID: 112
  - 类型: bool
* #### IsThumbnailActive
  - 说明: 缩略图是否激活
  - ID: 113
  - 类型: bool
* #### IsWindowLocked
  - 说明: 是否锁定窗口
  - ID: 114
  - 类型: bool
* #### Rotation
  - 说明: 旋转角度
  - ID: 200
  - 类型: double
  - 合法值: 0, 90, 180, 270
* #### Mirror
  - 说明: 镜像
  - ID: 201
  - 类型: ImageMirrorMode
    - None
    - Horizontal
    - Vertical
* #### Zoom
  - 说明: 缩放比例
  - ID: 202
  - 类型: double
  - 合法值: 0.1-10.0
* #### CropRatio
  - 说明: 裁剪比例
  - ID: 203
  - 类型: double
  - 合法值:
    - `-2.0` -> 切换裁剪模式
    - `-1.0` -> 关闭裁剪
    - `≥0` -> 开启并设裁剪比例
* #### IsCropMode
  - 说明: 是否处于裁剪模式
  - ID: 210
  - 类型: bool
* #### IsMiniMapEnabled
  - 说明: 是否启用迷你地图
  - ID: 220
  - 类型: bool
* #### IsWindowFitsImageEnabled
  - 说明: 是否启用窗口适应图片
  - ID: 221
  - 类型: bool
* #### IsSideArrowEnabled
  - 说明: 是否启用侧边箭头
  - ID: 222
  - 类型: bool
* #### IsBottomButtonsEnabled
  - 说明: 是否启用底部操作栏
  - ID: 223
  - 类型: bool
* #### Path
  - 说明: 当前文件路径
  - ID: 1000
  - 类型: string
  - 不可写
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
</details>

<details style="margin-left: 20px;" id="CropAdjustment" open>
<summary><b>CropAdjustment</b></summary>

* ##### MoveUp
  - 说明: 裁剪框上移
  - ID: 0
* ##### MoveDown
  - 说明: 裁剪框下移
  - ID: 1
* ##### MoveLeft
  - 说明: 裁剪框左移
  - ID: 2
* ##### MoveRight
  - 说明: 裁剪框右移
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
* ##### FitToImage
  - 说明: 适配图片范围 (全选)
  - ID: 12
* ##### ResetCrop
  - 说明: 重置裁剪框
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
</details>