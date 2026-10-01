## Notes
- This document (including lua / effect-related parameters) is primarily intended for AI to read and assist with customization; if you need to extend it yourself, have the AI read the **Chinese version**.
- The English version (Documentation.md) is a human-maintained, human-readable reference; its parameter tables may be out of sync with the Chinese version. For customization, always refer to the Chinese version.

## Special
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
- data sub-directories
  - `icons` file association icons
    - Not provided because I cannot make aesthetically pleasing ones
    - Obtain or create icons in `ico` format
    - Name them using the format `extension.ico`
      - Example: `bmp.ico`, `jpg.ico`
  - `scripts` lua scripts
  - `effects` effect scripts
  - `langs` language files
- Temp Directory Location: `%temp%\vvyoko\Vii3`
  - Currently only stores logs
  - `magick` magick temp directory (measures have been taken to avoid generating temp files as much as possible)
- Shortcut Keys
  - Layer Priority: Except for the global layer, all layers are peer levels; keys registered in a specific layer take precedence over global ones.
  - Shortcuts defined in Lua override those configured in settings.
- Press and hold the left mouse button on the title and image info area to move the window
- Thumbnail
  - Cache Hit & Invalidation Mechanism:
    - Matching Threshold: Requires the absolute delta of quality to be ≤ 10, and the absolute delta between the requested size and either the cached width or height to be ≤ 10.
    - Invalidation & Regeneration: Any adjustment exceeding this tolerance scale will cause the old cache to be deemed invalid and skipped, subsequently triggering the generation and overwriting of a new cache entry.
  - Allowed commands
    - ThumbnailGridAction
    - CloseApp
    - SendMessageToScript
      - Use Lua to implement other commands if needed
    - Navigate
      - NextFolderOrArchive
      - PrevFolderOrArchive
- OCR
  - Model Download
    - Download [Microsoft Photos](https://apps.microsoft.com/detail/9wzdncrfjbh4) from the `Microsoft Store`.
    - Open the app, launch `Task Manager`, right-click on `Photos` -> `Photos`, and select `Open file location`.
    - Copy `oneocr.dll`, `oneocr.onemodel`, and `onnxruntime.dll` to the directory where `Vii3` is located.
  - In `Hotkeys` - `Global`, add a new hotkey, bind it to the command `Toggle` with the parameter `Ocr`.
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
---

## Settings
  - Manual Editing Options for General Settings
    - Requires exiting the program before editing `data\set.json`.
    - Options not included in the settings interface imply that regular users are not encouraged to customize them.
    - `OneOcrDirectory` Set the OCR model folder location, reuse the model, and note that some directories may not have permission to read like `WindowsApps`
    - `Background`
      - Used to set the background color using the `#AARRGGBB` or `#RRGGBB` format.
      - Invalid values or missing configurations will fallback to the default frosted-glass theme.
    - `DateTimeFormat` specifies the date format
      - Refer to [Custom date and time format strings](https://learn.microsoft.com/dotnet/standard/base-types/custom-date-and-time-format-strings)
      - Example `yyyy-MM-dd hh:mm:ss` -> `2026-09-05 19:13:34`
    - [DebugOverlays](https://docs.avaloniaui.net/api/avalonia/rendering/rendererdebugoverlays) performance testing
      - 0 `None`
      - 1 `Fps`
      - 2 `DirtyRects`
      - 4 `LayoutTimeGraph`
      - 8 `RenderTimeGraph`
  - Shortcuts and Menus
    - If you are unsure how to configure parameters or target values:
    - Hover over `Command` or `Binding Status` to view the original values.
    - Then, search for and review their detailed descriptions in the definitions below.
---
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

* #### SaveAs
  - Description: Bake effects and annotations into the image and save as a new file (manual path selection each time, original untouched)
  - ID: 7

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
* #### LoadFiles
  - Description:LoadFiles
  - ID: 190
  - Parameter: string[]
  - Internal property
* #### ZoomSet
  - Description: Set zoom ratio (absolute value)
  - ID: 201
  - Parameter: `double`
    - Example: `1.1` → set current zoom to 110%
* #### SetFillMode
  - Description: Set fill mode
  - ID: 202
  - Parameter: [ImageFillMode](#ImageFillMode)
* #### ZoomIn
  - Description: Zoom In
  - ID: 203
* #### ZoomOut
  - Description: Zoom Out
  - ID: 204
* #### RotateMirror
  - Description: Rotate & Mirror
  - ID: 210
  - Parameter: [RotateMirrorType](#RotateMirrorType)
* #### LoadOriginalImage
  - Description: Load/View original image
  - ID: 220
* #### SetImageEffect
  - Description: Set display effect
  - ID: 225
  - Parameter: `string`
    - Format: `<id> [name value [; name value]…]`
    - id is the effect identifier; three forms are accepted:
      - Built-in effect = angle-bracketed id like `<lomo>`
      - Script directly under `data/effects` = filename without extension (e.g., `test.lua` → `test`)
      - Script in a subfolder = path relative to effects without extension (e.g., `demo/magnifier.lua` → `demo/magnifier`)
    - Empty string = no effect applied
    - id only = switch effect; with parameters (e.g., `demo/magnifier radius 0.3`) = switch effect + set parameters (`+/-` means increment/decrement on the current value)
* #### ThumbnailGridAction
  - Description: Thumbnail grid action
  - ID: 230
  - Parameter: [ThumbnailGridAction](#ThumbnailGridAction)
* #### VideoAction
  - Description: Video action
  - ID: 240
  - Parameter: [VideoAction](#VideoAction)
* #### OcrAction
  - Description: OCR action
  - ID: 245
  - Parameter: [OcrAction](#OcrAction)
* #### SelectorSet
  - Description: Set Selector
  - ID: 300
  - Parameter: `double`
    - `-2.0` → toggle selector
    - `-1.0` → close selector
    - `≥0` → enable and set select ratio
* #### CropSave
  - Description: Save current crop area
  - ID: 301
* #### SelectorAdjustAction
  - Description: Selection adjustment
  - ID: 305
  - Parameter: [SelectorAdjustment](#SelectorAdjustment)
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
* #### ConvertImageFormat
  - Description: Converts the image format
    - Can only convert the current image
    - Applicable for temporary use only
  - ID: 330
  - Parameters: string
    - The extension name of the target image format
    - Example: `.jpg` to convert to `Jpg` format
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

* #### AnnotateAction
  - Description: Annotation action (undo/redo/clear/delete)
  - ID: 500
  - Parameter: [AnnotationActionKind](#AnnotationActionKind)
    - No action is executable if not in annotation mode

</details>
<details style="margin-left: 20px;" open>
<summary><b>Properties</b></summary>

* #### None
  - Description: None
  - ID: 0
  - Type: -
* #### SortMode
  - Description: Sort type
  - ID: 1
  - Type: [SortField](#SortField)
* #### IsSortDescend
  - Description: Sort descending
  - ID: 30
  - Type: bool
* #### IsFolderLooping
  - Description: Folder looping
  - ID: 31
  - Type: bool
* #### WindowState
  - Description: Window state
  - ID: 100
  - Type: WindowState
    - Normal
    - Minimized
    - Maximized
    - FullScreen
* #### IsWindowTopmost
  - Description: Is Window Topmost
  - ID: 130
  - Type: bool
* #### IsWindowLocked
  - Description: Is Window locked
  - ID: 131
  - Type: bool
* #### IsWindowFitsImage
  - Description: Is window fit to image Enable
  - ID: 160
  - Type: bool
* #### IsTitleVisible
  - Description: Is Title Visible
  - ID: 200
  - Type: bool
* #### IsImageInfoVisible
  - Description: Is Image Info Visible
  - ID: 201
  - Type: bool
* #### IsThumbnailVisible
  - Description: Is Thumbnail Visible
  - ID: 202
  - Type: bool
* #### IsMiniMapEnabled
  - Description: Is MiniMap Enabled
  - ID: 230
  - Type: bool
* #### IsSideArrowEnabled
  - Description: Is Side Arrow Enabled
  - ID: 231
  - Type: bool
* #### IsBottomButtonsEnabled
  - Description: Is Bottom Buttons Enabled
  - ID: 232
  - Type: bool
* #### IsInCropMode
  - Description: In crop mode
  - ID: 260
  - Type: bool
* #### IsInOcrMode
  - Description: In OCR mode
  - ID: 261
  - Type: bool
* #### IsInAnnotateMode
  - Description: In annotation mode
  - ID: 262
  - Type: bool
* #### FillMode
  - Description: Fill mode
  - ID: 500
  - Type: [ImageFillMode](#ImageFillMode)
* #### MirrorMode
  - Description: Mirror
  - ID: 501
  - Type: ImageMirrorMode
    - None
    - Horizontal
    - Vertical
* #### ImageEffect
  - Description: Display effect (runtime state)
  - ID: 502
  - Type: string
    - Value is the effect id (e.g., `<lomo>`); empty = no effect applied
    - Menu check, shortcuts, and Lua all compare against this id
* #### ZoomFactor
  - Description: Zoom ratio
  - ID: 530
  - Type: double
  - Valid values: 0.1-10.0
* #### RotateAngle
  - Description: Rotation angle
  - ID: 531
  - Type: double
  - Valid values: 0, 90, 180, 270
* #### CropRatio
  - Description: Crop ratio
  - ID: 533
  - Type: double
  - Valid values:
    - `-2.0` → toggle crop mode
    - `-1.0` → close crop
    - `≥0` → enable and set crop ratio
* #### IsImageTopAligned
  - Description: Is image aligned to top
  - ID: 560
  - Type: bool
* #### Path
  - Description: Current file path
  - ID: 1000
  - Type: string
  - Not writable
* #### HasImage
  - Description: Has loaded image
  - ID: 1010
  - Type: bool
  - Internal property
* #### HasFile
  - Description: Has valid file
  - ID: 1011
  - Type: bool
  - Internal property
* #### FileCount
  - Description: Total file count
  - ID: 1012
  - Type: int
  - Internal property
* #### CanNavigate
  - Description: Allow prev/next navigation
  - ID: 1013
  - Type: bool
  - Internal property
</details>

<details style="margin-left: 20px;" id="InputLayer" open>
<summary><b>InputLayer</b></summary>

* ##### Global
  - Description: Global
  - ID: 0
* ##### Thumbnail
  - Description: Thumbnail
  - ID: 1
* ##### Selector
  - Description: Selector
  - ID: 2
* ##### Video
  - Description: Video
  - ID: 3
* ##### Ocr
  - Description: Ocr
  - ID: 4
* ##### Annotate
  - Description: Annotation layer
  - ID: 5
</details>

<details style="margin-left: 20px;" id="SelectorAdjustment" open>
<summary><b>SelectorAdjustment</b></summary>

* ##### MoveUp
  - Description: Move selection box up
  - ID: 0
* ##### MoveDown
  - Description: Move selection box down
  - ID: 1
* ##### MoveLeft
  - Description: Move selection box left
  - ID: 2
* ##### MoveRight
  - Description: Move selection box right
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
* ##### SelectAll
  - Description: Select all
  - ID: 12
* ##### ResetSelect
  - Description: Reset selection box
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
* ##### ZoomIn
  - Description: Zoom In
  - ID: 9
* ##### ZoomOut
  - Description: Zoom Out
  - ID: 10
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
* ##### Selector
  - Description: Selector
  - ID: 32
* ##### Ocr
  - Description: Ocr
  - ID: 33
* ##### Annotate
  - Description: Annotation mode (enter ↔ exit)
  - ID: 34
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
  - Description: Copy image (when annotations and effects are present, they are baked in and included)
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

<details style="margin-left: 20px;" id="AnnotationActionKind" open>
<summary><b>AnnotationActionKind</b></summary>

* ##### Undo
  - Description: Undo one annotation step
  - ID: 1
* ##### Redo
  - Description: Redo one annotation step
  - ID: 2
* ##### Clear
  - Description: Clear all annotations
  - ID: 3
* ##### Delete
  - Description: Delete the currently selected annotation
  - ID: 4
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

<details style="margin-left: 20px;" id="RotateMirrorType" open>
<summary><b>OcrAction</b></summary>

* ##### SelectAll 
  - Description: Select all
  - ID: 1
* ##### ExpandCurrentSelection 
  - Description: Expand selection (select all `Box` elements currently partially selected)
  - ID: 2
* ##### Copy
  - Description: Copy
    - Includes basic text layout restructuring
    - Attempts to restore layout based on reading order, though perfect reproduction is not guaranteed
    - The string itself does not contain layout information, so it will not and cannot insert multiple spaces to force alignment
    - Multiple `Boxes` merged into the same line are separated by a `Tab`
    - Remaining whitespace refers to gaps in the source data or fallback cases where only part of a single `Box` is selected
    - It can handle partial rotation to merge `Boxes` that are not on the same horizontal line into the same row
  - ID: 10
* ##### CopyUnordered
  - Description: Copy unordered (per line, from top to bottom based on coordinates)
  - ID: 11
* ##### CopyJson
  - Description: Copy JSON (raw data)
  - ID: 12
</details>


<details style="margin-left: 20px;" id="RotateMirrorType" open>
<summary><b>AppEvent</b></summary>

* ##### Shutdown 
  - Description: Trigger on program exit
  - ID: 1
* ##### ImageLoaded 
  - Description: Triggers after each image loading is completed
  - ID: 10
</details>

</details>
