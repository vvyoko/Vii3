- **Large Image Loading Issues**
   - Framework limitation: each image can only occupy 2GB of memory
   - `Skia` or `WIC` Tries to load the maximum supported resolution
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
  - Ocr , Crop and save operations are not supported
    - However, they are not blocked; calling them will operate on the first frame of the image
  - `Avif` has suspected transparency support issues
  - `Avif` does not display correct frame count
      - It is actually a video format, getting data is very slow
      - So data reading was implemented manually for now
      - Waiting for upstream fix or it may not be fixable

- **Slow Loading of Avif Animations**
  - By default, **libmpv** is not included, meaning the slow parsing is currently the fallback solution.
  - **Avif** belongs to video streams; when **libmpv** is not included, **Magick.Net** is used for parsing instead.
  - **Magick.Net** is positioned as an image processing library and may not naturally excel at parsing this specific format.
    - See [MagickImage.ping() of some special avif file very slow](https://github.com/dlemstra/Magick.NET/issues/2005)
    - This discussion only addresses loading basic information, and the fix only reads the first frame.
  - When loading the full animation stream, the time consumption mentioned in the discussion above is unavoidable.
    - Attempted to implement "play while loading", but the time overhead mentioned above still cannot be bypassed.
  - Given that an optional **libmpv** solution exists, no other specialized libraries will be introduced to handle this.
  - If there is a high demand for **Avif animations**, please refer to the documentation to download **libmpv**.
    - **libmpv** is a professional video processing library that excels at handling video formats.

- ### Window Flicker with Window Fit To Image
  - Window auto-sizing essentially triggers window resizing operations fully controlled by the system; no custom handling can be implemented at the application layer
  - Flicker becomes more severe when ** Window Fit To Image Support Zoom** is enabled
    - Scaling modifies window dimensions almost every time
    - Switching between images with identical resolutions may not trigger window resizing at all
  - A common workaround adopted by some applications: launch the main window maximized, set all UI elements except the image to transparent with click-through enabled
  - This approach disables interaction with other components entirely, hence it is not adopted here

- ### OCR-Related Notes
  - This is an experimental feature and may be removed in future versions
  - Imprecise selection occurs because selection is based on bounding boxes (Box) returned by OCR, not plain text content
    - Spaced selections within a single line indicate word-level (Word) selection
    - Solid rectangular selection covering an entire line indicates line-level (Line) selection
  - Overlapping highlighted regions exist in certain scenarios; attempts to resolve this issue have not yet succeeded
  - The OCR implementation relies on non-public APIs, making the following issues unsolvable:
  - Conventional model limitations including recognition failures and misidentified text
  - Input size constraints of the underlying model prevent recognition on overly large or tiny images
    - Current solution: preprocess images with upscaling or downscaling
    - Combined overhead of resizing and OCR processing leads to noticeable latency. To prevent UI thread blocking, the entire workflow is offloaded to a separate worker thread
    - Thread safety of the underlying OCR library is unconfirmed. If crashes occur randomly during OCR invocation, please submit feedback for logic adjustments

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
  - Suspected sharp performance drop without any code changes
    - Replaced core dependency property `ExtendClientAreaChromeHints` with `None`
    - Replaced all deprecated methods with recommended alternatives