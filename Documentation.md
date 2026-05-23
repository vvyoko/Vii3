## Special
- Live Photos
  - Apple currently only supports Live Photos when a `.mov` file with the exact same name as the `.heic` file exists within the same directory.
  - Playing the video stream in Live Photos requires `libmpv-2.dll`.
  - Due to the large file size and the copyleft nature of its open-source license, this software does not include this component by default. Users who need this feature must download it manually and place it in the same directory as `vii3.exe`.
  - Download Methods:
    - A (Smaller Size, Older Version): Download `media_kit_test_win32_x64.7z` from the [media-kit (v1.1.10)](https://github.com/media-kit/media-kit/releases/tag/media_kit-v1.1.10) release, then extract `libmpv-2.dll` from it.
    - B (Larger Size, Newer Version): Download `mpv-dev-x86_64-v3` or `mpv-dev-x86_64` from [zhongfly/mpv-winbuild](https://github.com/zhongfly/mpv-winbuild/releases), then extract `libmpv-2.dll` from it.
  - Reusing an Existing Component: 
    - If you already have this component elsewhere on your system, you can reuse it. Completely exit the software, then open the `data\set.json` file located in the program directory.
    - Find the `"LibMpvPath"` field and change its value to the **absolute path** of the `libmpv-2.dll` you want to reuse.
      - The file name must be exactly `libmpv-2.dll`, not `libmpv.dll` or anything else.
      - The path must comply with JSON specifications, using either escaped backslashes `\\` or forward slashes `/`.
      - Example: `"LibMpvPath": "D:\\OneDrive\\Program\\AHK\\lib\\libmpv\\libmpv-2.dll"`
- Loading Process
  - An image is defined as a file with an image file extension
  - Opening a single image will open all images in the same directory
    - File change monitoring is enabled to respond to external modifications
    - i.e., deleting or modifying files by external programs will be detected and updated
  - Opening a folder itself will search for all images including subfolders
    - Compressed archives are not scanned
  - Opening a compressed archive will search for all image files within
  - Multiple images, folders, and archives can be opened simultaneously
    - Folders will search subfolders
  - External modifications are not monitored except when opening a single image directly
  - Files can be loaded via drag & drop, clipboard, or command line arguments
    - Command line arguments (multiple files or folders supported)
      - `Vii3.exe img1 img2 dir1 dir2 zip1 rar2`
- File Association Icons
  - Icons are not provided because I cannot create aesthetically pleasing ones
  - Create a subfolder named `icons` in the `data` directory
  - Obtain or create icons in `ico` format
  - Name them using the format `extension.ico`
     - Example: `bmp.ico`, `jpg.ico`
- Temp Directory Location: `%temp%\vvyoko\Vii3`
  - Currently only stores logs
  - Compressed archives and videos from dynamic photos have been fully migrated to memory streams
- Shortcut Keys
  - Layer Priority: Except for the global layer, all layers are peer levels; keys registered in a specific layer take precedence over global ones.
  - Shortcut keys are not displayed in right-click menus, as the menu only shows system-recognized shortcuts.
  - Shortcuts defined in Lua override those configured in settings.
  - Cluttered display of shortcut keys in settings is due to insufficient UI design optimization.
  - Thumbnail layer Mouse Binding Restrictions:
    - Never bind any actions involving mouse clicks or scroll wheel (even with Ctrl/Shift modifiers).
    - The native grid control forcefully hooks and monopolizes all mouse-related window messages.
    - Any custom mouse hotkeys will invariably be swallowed and neutralised by the control itself.
- Press and hold the left mouse button on the title and image info area to move the window
- Thumbnail
  - Cache Hit & Invalidation Mechanism:
    - Matching Threshold: Requires the absolute delta of quality to be ≤ 10, and the absolute delta between the requested size and either the cached width or height to be ≤ 10.
    - Invalidation & Regeneration: Any adjustment exceeding this tolerance scale will cause the old cache to be deemed invalid and skipped, subsequently triggering the generation and overwriting of a new cache entry.
  - Allowed commands
    - ThumbnailGridAction
    - ThumbnailSizeChange
    - CloseApp
    - SendMessageToScript
      - Use Lua to implement other commands if needed
    - Navigate
      - NextFolderOrArchive
      - PrevFolderOrArchive
- Command Line Arguments
  - Arguments starting with `--` are commands to be executed
    - Format: `--commandname[=optionalparameter]`
    - Use `"parameter"` to wrap parameters containing spaces
    - Execution order is not guaranteed
    - Commands are not guaranteed to be executable during initialization
    - They are specifically designed for special operations
    - Example: clipboard paste command, run and execute specified command, open clipboard image
      - `Vii3.exe --OpenClipboardFilesOrImage --SendMessageToScript="CleanMode On"`
      - AutoHotkey example script
        ```
          OnClipboardChange(ClipChanged)
          Vii3Path := "path"
          ClipChanged(clipType)
          {
              if (clipType == 2 && ;image
                  !WinActive("ahk_exe Vii3.exe"))
              {
                  ; if (WinActive("ahk_exe chrome.exe"))
                  Run(Vii3Path ' --OpenClipboardFilesOrImage --SendMessageToScript="CleanMode On"')
              }
          }
        ```
  - The first non `--` argument until the end is treated as a file or folder and loaded


## Settings
  - Please hover over items to view comments. If you still don't understand the purpose, feel free to provide feedback

<details>
<summary><h2 style="display: inline; margin: 0; font-size: 1.5em;">Definitions</h2></summary>

<details style="margin-left: 20px;" open>
<summary><b>Commands</b></summary>

* #### CloseApp
  - Description: Exit program
  - ID: 1
* #### OpenSetting
  - Description: Open settings interface
  - ID: 2
* #### ShowContextMenu
  - Description: Show context menu
  - ID: 3
* #### Open
  - Description: Open file dialog
  - ID: 4
* #### Navigate
  - Description: Navigate
  - ID: 5
  - Parameter: [NavigationType](#NavigationType)
* #### Toggle
  - Description: Toggle
  - ID: 6
  - Parameter: [ToggleTarget](#ToggleTarget)

* #### SendMessageToScript
  - Description: Send message to script engine
  - ID: 21
  - Parameter: `string`
    - Example: scriptID functionname [param1 param2 ...]
      - scriptID is the filename without extension of lua files in `data\scripts`, e.g., `Slideshow`
    - Conversion priority: Quoted string → true/false → integer → decimal → plain string
    - Parameters with spaces must be wrapped in double quotes (e.g., "hello world"), escape double quotes with \"
* #### Sort
  - Description: Set sort method
  - ID: 130
  - Parameter: [SortField](#SortField)
* #### ShowCacheStatistics
  - Description: View cache statistics
  - ID: 140
* #### ZoomMultiply
  - Description: Set zoom multiplier (relative to current value)
  - ID: 200
  - Parameter: `double`
    - Example: `1.1` → current zoom * 1.1
* #### ZoomSet
  - Description: Set zoom ratio (absolute value)
  - ID: 201
  - Parameter: `double`
    - Example: `1.1` → set current zoom to 110%
* #### SetFillMode
  - Description: Set fill mode
  - ID: 202
  - Parameter: [ImageFillMode](#ImageFillMode)
* #### RotateMirror
  - Description: Rotate & Mirror
  - ID: 210
  - Parameter: [SortField](#SortField)
* #### LoadOriginalImage
  - Description: Load/View original image
  - ID: 220
* #### ThumbnailGridAction
  - Description: Thumbnail grid action
  - ID: 230
  - Parameter: [ThumbnailGridAction](#ThumbnailGridAction)
* #### ThumbnailSizeChange
  - Description: Adjust thumbnail dimensions
  - ID: 231
  - Parameter: `int`
    - Example: `4` -> Current size `+4`
    - Example: `-4` -> Current size `-4`
* #### VideoAction
  - Description: Video action
  - ID: 240
  - Parameter: [VideoAction](#VideoAction)
* #### CropSet
  - Description: Set crop mode
  - ID: 300
  - Parameter: `double`
    - `-2.0` → toggle crop mode
    - `-1.0` → close crop
    - `≥0` → enable and set crop ratio
* #### CropSave
  - Description: Save current crop area
  - ID: 301
* #### CropAdjustAction
  - Description: Crop selection adjustment
  - ID: 305
  - Parameter: [CropAdjustment](#CropAdjustment)
* #### RotateMirrorSave
  - Description: Save rotation/mirror
  - ID: 310
* #### CropSaveToPath
  - Description: Save crop to specified path
  - ID: 320
  - Parameter: string
    - Specify the file path to save to
* #### RotateMirrorSaveToPath
  - Description: Save rotation/mirror to specified path
  - ID: 322
  - Parameter: string
    - Specify the file path to save to
* #### FileRecycle
  - Description: Move to recycle bin
  - ID: 350
* #### ShowInFolder
  - Description: Locate in explorer
  - ID: 351
* #### SetWallPaper
  - Description: Set as desktop wallpaper
  - ID: 352
* #### CreateCopy
  - Description: Create copy
  - ID: 353
* #### CreateCopyToPath
  - Description: Create copy to specified path
  - ID: 354
  - Parameter: string
    - Specify the file path to save to
* #### ExportPlaylist
  - Description: Export playlist
  - ID: 355
* #### OpenClipboardFilesOrImage
  - Description: Open clipboard files/image
    - Additionally supports `<svg>...</svg>` beyond [CopyFormat](#CopyFormat) types
  - ID: 361
* #### Copy
  - Description: Copy
  - ID: 362
  - Parameter: [CopyFormat](#CopyFormat)
* #### OpenWithExternalProgram
  - Description: Open current file with external program
  - ID: 370
  - Parameter: string
    - ProgramEXE|optional program arguments|optional hide flag|optional working directory
    - Placeholders
      - `<path>` → current file path
      - `<dir>` → current file directory
      - `<AppDir>` → directory where `Vii3.exe` is located
      - `<ConfDir>` → directory where `data` is located
      - `<TempDir>` → `%temp%\vvyoko\Vii3`
    - Parameter parsing rules
      - ProgramEXE: Can contain spaces (no quotes needed), supports system commands (like notepad) and placeholders
      - Program arguments: Split by quotes/spaces into argument array, rules:
        - If starts with " then take until " ends as single parameter, otherwise split by space
        - After placeholder replacement, parameters without quotes but containing spaces are automatically quoted
        - Manually quoted parameters retain quotes, no duplicate processing
    - Hide flag: 0=show external program window (default), 1=hide external program window
    - Working directory: Supports placeholder replacement, automatically normalized to absolute path after replacement
    - Separator: | is only used as parameter separator
    - Example: `mspaint` → open current file with Paint
* #### ClearDatabase
  - Description: Clear database in config directory
  - ID: 371
* #### ClearDatabasePath
  - Description: Clear database in specified folder
  - ID: 372
  - Parameter: string
    - Clear database in the specified directory
* #### OpenGpsMap
  - Description: Open map location
  - ID: 380
  - Parameter: string (URL)
    - Placeholders
      - Coordinate system (add to front of URL when specified with `|`)
        - `GCJ02`
        - `BD09`
        - `WGS84` (default)
      - `{lat}` latitude
      - `{lng}` longitude
    - Example: `BD09|https://api.map.baidu.com/marker?location={lat},{lng}&output=html`
    - Example: `https://maps.google.com/?q={lat},{lng}`
* #### CycleCropRatio
  - Description: Cycle through crop ratios
  - ID: 401
  - Parameter: string
    - Values separated by English commas (e.g., `16:9,4:3,1:1` or `1.778,1.333,1.0`)
    - Ratios support simple parenthesis-free arithmetic parsing (e.g., "16:9" → 1.778), must be >0
* #### CycleSortType
  - Description: Cycle through sort modes
  - ID: 402
  - Parameter: ([SortField](#SortField))
    - Example: `Path,Size`
* #### CycleFillMode
  - Description: Cycle through fill modes
  - ID: 403
  - Parameter: ([ImageFillMode](#ImageFillMode))
    - Example: `FillWindow,FitWindow`
</details>

<details style="margin-left: 20px;" open>
<summary><b>Properties</b></summary>

* #### SortField
  - Description: Sort type
  - ID: 1
  - Type: [SortField](#SortField)
* #### SortDescend
  - Description: Sort descending
  - ID: 2
  - Type: bool
* #### FillMode
  - Description: Fill mode
  - ID: 3
  - Type: [ImageFillMode](#ImageFillMode)
* #### IsFolderLooping
  - Description: Folder looping
  - ID: 4
  - Type: bool
* #### WindowState
  - Description: Window state
  - ID: 100
  - Type: WindowState
    - Normal
    - Minimized
    - Maximized
    - FullScreen
* #### Topmost
  - Description: Window topmost state
  - ID: 101
  - Type: bool
* #### IsImageInfoEnabled
  - Description: Enable image info
  - ID: 110
  - Type: bool
* #### IsTitleEnabled
  - Description: Enable title
  - ID: 112
  - Type: bool
* #### IsThumbnailActive
  - Description: Thumbnail active
  - ID: 113
  - Type: bool
* #### IsWindowLocked
  - Description: Window locked
  - ID: 114
  - Type: bool
* #### Rotation
  - Description: Rotation angle
  - ID: 200
  - Type: double
  - Valid values: 0, 90, 180, 270
* #### Mirror
  - Description: Mirror
  - ID: 201
  - Type: ImageMirrorMode
    - None
    - Horizontal
    - Vertical
* #### Zoom
  - Description: Zoom ratio
  - ID: 202
  - Type: double
  - Valid values: 0.1-10.0
* #### CropRatio
  - Description: Crop ratio
  - ID: 203
  - Type: double
  - Valid values:
    - `-2.0` → toggle crop mode
    - `-1.0` → close crop
    - `≥0` → enable and set crop ratio
* #### IsCropMode
  - Description: In crop mode
  - ID: 210
  - Type: bool
* #### IsMiniMapEnabled
  - Description: Enable mini map
  - ID: 220
  - Type: bool
* #### IsWindowFitsImageEnabled
  - Description: Enable window fit to image
  - ID: 221
  - Type: bool
* #### IsSideArrowEnabled
  - Description: Enable side arrow
  - ID: 222
  - Type: bool
* #### IsBottomButtonsEnabled
  - Description: Enable bottom bar
  - ID: 223
  - Type: bool
* #### Path
  - Description: Current file path
  - ID: 1000
  - Type: string
  - Not writable
</details>

<details style="margin-left: 20px;" id="InputLayer" open>
<summary><b>InputLayer</b></summary>

* ##### Global
  - Description: Global
  - ID: 0
* ##### Thumbnail
  - Description: Thumbnail
  - ID: 1
* ##### Crop
  - Description: Crop
  - ID: 2
* ##### Video
  - Description: Video
  - ID: 3
</details>

<details style="margin-left: 20px;" id="CropAdjustment" open>
<summary><b>CropAdjustment</b></summary>

* ##### MoveUp
  - Description: Move crop box up
  - ID: 0
* ##### MoveDown
  - Description: Move crop box down
  - ID: 1
* ##### MoveLeft
  - Description: Move crop box left
  - ID: 2
* ##### MoveRight
  - Description: Move crop box right
  - ID: 3
* ##### EnlargeTop
  - Description: Enlarge top edge
  - ID: 4
* ##### EnlargeBottom
  - Description: Enlarge bottom edge
  - ID: 5
* ##### EnlargeLeft
  - Description: Enlarge left edge
  - ID: 6
* ##### EnlargeRight
  - Description: Enlarge right edge
  - ID: 7
* ##### ShrinkTop
  - Description: Shrink top edge
  - ID: 8
* ##### ShrinkBottom
  - Description: Shrink bottom edge
  - ID: 9
* ##### ShrinkLeft
  - Description: Shrink left edge
  - ID: 10
* ##### ShrinkRight
  - Description: Shrink right edge
  - ID: 11
* ##### FitToImage
  - Description: Fit to image range (select all)
  - ID: 12
* ##### ResetCrop
  - Description: Reset crop box
  - ID: 13
</details>

<details style="margin-left: 20px;" id="ThumbnailGridAction" open>
<summary><b>ThumbnailGridAction</b></summary>

* ##### MoveUp
  - Description: Move up
  - ID: 0
* ##### MoveDown
  - Description: Move down
  - ID: 1
* ##### MoveLeft
  - Description: Move left
  - ID: 2
* ##### MoveRight
  - Description: Move right
  - ID: 3
* ##### MoveToFirst
  - Description: Jump to first item
  - ID: 4
* ##### MoveToLast
  - Description: Jump to last item
  - ID: 5
* ##### ScrollUp
  - Description: Scroll up
  - ID: 6
* ##### ScrollDown
  - Description: Scroll down
  - ID: 7
* ##### OpenSelected
  - Description: Open selected item
  - ID: 8
</details>

<details style="margin-left: 20px;" id="VideoAction" open>
<summary><b>VideoAction</b></summary>

* ##### Play
  - Description: Play
  - ID: 0
* ##### ToggleMute
  - Description: Toggle mute
  - ID: 1
</details>

<details style="margin-left: 20px;" id="SaveMode" open>
<summary><b>SaveMode</b></summary>

* ##### Auto
  - Description: Auto save as new file
  - ID: 0
* ##### Ask
  - Description: Ask save path
  - ID: 1
* ##### Replace
  - Description: Replace original file
  - ID: 2
</details>

<details style="margin-left: 20px;" id="ImageFillMode" open>
<summary><b>ImageFillMode</b></summary>

* ##### Original
  - Description: Original size
  - ID: 0
* ##### FitWindow
  - Description: Fit window
  - ID: 1
* ##### FillWindow
  - Description: Fill window
  - ID: 2
* ##### FitWidth
  - Description: Fit width
  - ID: 3
* ##### FitHeight
  - Description: Fit height
  - ID: 4
* ##### StretchWidth
  - Description: Stretch width (when image resolution is smaller than window, enlarge width to fit window)
  - ID: 5
* ##### StretchHeight
  - Description: Stretch height (when image resolution is smaller than window, enlarge height to fit window)
  - ID: 6
</details>

<details style="margin-left: 20px;" id="SortField" open>
<summary><b>SortField</b></summary>

* ##### Path
  - Description: Path
  - ID: 0
* ##### Size
  - Description: Size
  - ID: 1
* ##### Extension
  - Description: Extension
  - ID: 2
* ##### CreationTime
  - Description: Creation time
  - ID: 3
* ##### LastWriteTime
  - Description: Modification time
  - ID: 4
* ##### Resolution
  - Description: Resolution
  - ID: 5
* ##### AspectRatio
  - Description: Aspect ratio
  - ID: 6
* ##### Width
  - Description: Width
  - ID: 7
* ##### Height
  - Description: Height
  - ID: 8
* ##### Random
  - Description: Random
  - ID: 9
</details>

<details style="margin-left: 20px;" id="ToggleTarget" open>
<summary><b>ToggleTarget</b></summary>

* ##### Title
  - Description: Title
  - ID: 1
* ##### ImageInfo
  - Description: Image info
  - ID: 2
* ##### Topmost
  - Description: Topmost
  - ID: 3
* ##### FullScreen
  - Description: Full screen
  - ID: 4
* ##### Maximized
  - Description: Maximized
  - ID: 5
* ##### WindowLock
  - Description: Window lock (when enabled, the program internal window will lock size and position)
  - ID: 6
* ##### SortDescend
  - Description: Sort descending
  - ID: 10
* ##### Thumbnail
  - Description: Thumbnail
  - ID: 20
* ##### MiniMap
  - Description: Mini map
  - ID: 30
* ##### ImageTopAligned
  - Description: Image top aligned
  - ID: 31
* ##### WindowFitsImage
  - Description: Window fit to image
  - ID: 35
</details>

<details style="margin-left: 20px;" id="NavigationType" open>
<summary><b>NavigationType</b></summary>

* ##### Next
  - Description: Next image
  - ID: 0
* ##### Prev
  - Description: Previous image
  - ID: 1
* ##### First
  - Description: First image
  - ID: 2
* ##### Last
  - Description: Last image
  - ID: 3
* ##### Random
  - Description: Random image
  - ID: 4
* ##### NextFolderOrArchive
  - Description: Next folder/archive
  - ID: 10
* ##### PrevFolderOrArchive
  - Description: Previous folder/archive
  - ID: 11
* ##### ScrollNextPage
  - Description: Scroll to next page
  - ID: 20
* ##### ScrollPreviousPage
  - Description: Scroll to previous page
  - ID: 21
</details>

<details style="margin-left: 20px;" id="CopyFormat" open>
<summary><b>CopyFormat</b></summary>

* ##### Image
  - Description: Copy image
  - ID: 0
* ##### ImageToBase64
  - Description: Copy image as Base64
  - ID: 1
* ##### Path
  - Description: Copy path
  - ID: 10
* ##### File
  - Description: Copy file
  - ID: 11
* ##### ImageInfo
  - Description: Copy image info (includes data displayed on interface and AI Prompt, XMP)
  - ID: 20
</details>

<details style="margin-left: 20px;" id="RotateMirrorType" open>
<summary><b>RotateMirrorType</b></summary>

* ##### Restore
  - Description: Restore
  - ID: 0
* ##### RotateRight
  - Description: Rotate right
  - ID: 1
* ##### RotateLeft
  - Description: Rotate left
  - ID: 2
* ##### RotateReverse
  - Description: Rotate reverse
  - ID: 3
* ##### MirrorHorizontal
  - Description: Mirror horizontal
  - ID: 4
* ##### MirrorVertical
  - Description: Mirror vertical
  - ID: 5
</details>
</details>
