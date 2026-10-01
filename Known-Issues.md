- **Large Image Loading Issues**
   - Framework limitation: each image can only occupy 2GB of memory
   - `Skia` or `WIC` Tries to load the maximum supported resolution
   - `Magick.Net` does not support this
      - To load, you need to load the original image first then scale
      - The entire process takes very long, so it's abandoned


- **Extremely Large PNG Crashes**
  - See #8
  - This program will attempt to load the maximum supported resolution
  - `PNG` decoding is assigned to `Skia` by default
  - `Skia` may fail to handle this case, but it is unclear whether it is an isolated incident or widespread
  - Adding `.png` to `Wic Format` to assign it to `Wic` decoding temporarily avoids this issue
  - More observation to follow
  - Formats other than `jpeg` and `jpg` may also exhibit this, but pending observation

- **Animated Image Memory Usage**
  - There are two options
  - 1 Decode each frame
    - **In some** cases, sustained high CPU usage
    - More power-consuming, and frame rate may be unstable
  - 2 Cache decoded frames
    - **In some** cases, excessive memory usage
    - After decoding completes, frame rate is stable and more energy-efficient
  - Current logic caches all frames
  - Extremely large animated images can occupy over 1.5GB of local memory (Method 1: sustained 20% or even higher CPU usage)
  - Memory usage is currently at an acceptable level
  - If there are more complex animated images, memory usage may be higher, but pending observation

- **Animated Images, Live Photos Related**
  - Mini map displays the first frame, only used for position navigation
  - Live photos may be locked to 30fps in some cases
    - Most live photos' internal video does not have 60fps
    - Suspected to be a framework compositor issue or decoding pressure
    - You can hide UI elements and shrink images to see if there's improvement
  - Some live photos do not follow rules, may write incorrectly or not write `XMP` at all, and are simply ignored
  - Crop, OCR, Effects, Annotation, and save operations are not supported
    - However, they are not blocked; calling them will operate on the first frame of the image

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

- **ICO is a Container Format, the Image Info Detection Shows Png is Correct Behavior**