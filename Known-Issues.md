- **Large Image Loading Issues**
   - Framework limitation: each image can only occupy 2GB of memory
   - `SkiaSharp` supports subsampled decoding
      - Tries to load the maximum supported resolution
      - Supported formats: `.bmp`, `.jpg`, `.jpeg`, `.png`, `.webp`, `.gif`, `.ico`, `.wbmp`
  - `Magick.Net` does not support this
      - To load, you need to load the original image first then scale
      - The entire process takes very long, so it's abandoned


- **Animated Images, Live Photos Related**
  - Mini map displays the first frame, only used for position navigation
  - Live photos may be locked to 30fps in some cases
    - Most live photos' internal video does not have 60fps
    - Suspected to be a framework compositor issue or decoding pressure
    - You can hide UI elements and shrink images to see if there's improvement
  - Some live photos do not follow rules, may write incorrectly or not write `XMP` at all, and are simply ignored
  - Crop and save operations are not supported
    - However, they are not blocked; calling them will operate on the first frame of the image
  - `Avif` has suspected transparency support issues
  - `Avif` does not display correct frame count
      - It is actually a video format, getting data is very slow
      - So data reading was implemented manually for now
      - Waiting for upstream fix or it may not be fixable

- **Thumbnails**
  - **The control is no longer maintained; bugs may occur, but there is no alternative**
  - **Intermittent (or Frequent?) Positional Glitches**:
    - Suspected to be an issue with the control itself, making it difficult to resolve
  - **Size Adjustment**:
    - Certain values may cause incorrect positioning and movement
      - Set other values
    - Occasionally, some images may fail to load
      - Difficult to replicate, making it hard to target and resolve
      - The simplest workaround for now is to restart the application
  - **Image failure messages appear on the thumbnail interface**:
    - An edge case; please switch to the next image

- **Some Exif Values are Garbled, Mainly Because EXIF Has No Encoding**

- **ICO is a Container Format, the Image Info Detection Shows Png is Correct Behavior**

- **Avalonia Version Stuck at 11**
  - Version 12 removed the core property `ExtendClientAreaChromeHints` that the program depends on
  - Various attempts were made but still unable to resolve

- **Image Failure Info Appears in Thumbnail Interface**
  - Extreme case, please switch to next image
