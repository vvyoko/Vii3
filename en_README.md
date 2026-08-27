# Vii3
> A high-performance frameless image viewer based on Avalonia, delivering ultra-smooth switching experience, comprehensive format support.
---
## Features
- Avalonia AOT compilation for extreme startup speed
- Highly optimized loading process ensuring smooth switching without blocking
    - Ensures excellent experience even on mechanical hard drives
- Full image format support powered by SkiaSharp and Magick.Net
- Animation Gif, Webp, Apng, Jxl, Avif support
- live photo support powered by Libmpv
   - You need to download `libmpv-2.dll` yourself and place it in the program directory
   - Most people don't need this, and `libmpv` is quite large, download it yourself if needed
- Zip, Rar, Cbz, Cbr archive format support powered by SharpCompress
- Advanced Lua scripting support powered by Lua-CSharp
- OCR Support (Testing)
   - Need to download models according to the document
- All interface elements can be removed to eliminate browsing distractions
- Fully customizable keyboard shortcuts and contextmenu
- Multi-language support can be created and updated by users
    - Create new in settings interface
    - Export untranslated items
    - Have AI translate and copy
    - Import
---
## Screenshots
![switch](images/switch.gif)

![main](images/main.jpeg)

![main](images/main_2.jpeg)

![thumbnail](images/thumbnail.jpeg)

![ocr](images/ocr.jpeg)

![contextmenu](images/contextmenu.jpeg)

![setting_contextmenu](images/setting_contextmenu.jpeg)

![setting_quictshort](images/setting_quictshort.jpeg)

![sesettingtting_quictshort](images/setting.jpeg)

---
## Other
  - [Why 3? Because there was a predecessor](https://meta.appinn.net/t/topic/35989/)
  - [Documentation](Documentation.md)
  - [Lua Documentation](Lua-Documentation.md)
  - [Known Issues](Known-Issues.md)
---
## Dependencies
 - [Avalonia](https://avaloniaui.net/)
 - [Magick.NET](https://github.com/dlemstra/Magick.NET)
 - [Lua-CSharp](https://github.com/nuskey8/Lua-CSharp)
 - [SharpCompress](https://github.com/adamhathcock/sharpcompress)
 - [Microsoft.Data.Sqlite](https://docs.microsoft.com/dotnet/standard/data/sqlite/)
 - [CommunityToolkit.Mvvm](https://github.com/CommunityToolkit/dotnet)
