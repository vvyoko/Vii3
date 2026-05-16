<details>
<summary><h1>Lua API Documentation</h1>
</summary>


Vii3 provides a complete Lua scripting interface, allowing users to extend application functionality through scripts.

---

## Module Overview

| Module | Description |
|--------|-------------|
| `app` | Application core interface, including property read/write, command execution, event listening, etc. |
| `env` | Environment variables, providing runtime environment information for scripts |
| `utils` | Utility functions, including string operations, path processing, regular expressions, etc. |
| `factory` | Factory functions, used to create objects such as timers |

---

## app Module

### app.get_property(key, returnType)

Get application property value.

**Parameters:**
- `key`: string - Property name (e.g., "Zoom", "FillMode")
- `returnType`: string (optional) - Return type
  - `"raw"` (default): Returns raw value (enums return string names)
  - `"display"`: Returns translated display text
  - `"number"`: Returns numeric value (only effective for enums)

**Return Value:** Property value

**Example:**
```lua
local zoom = app.get_property("Zoom")
local fillModeName = app.get_property("FillMode")
local fillModeNum = app.get_property("FillMode", "number")
local fillModeText = app.get_property("FillMode", "display")
```

---

### app.set_property(key, value)

Set application property value.

**Parameters:**
- `key`: string - Property name
- `value`: any - Property value (type conversion is automatic)

**Example:**
```lua
app.set_property("Zoom", 1.5)
app.set_property("FillMode", "FitWindow")
app.set_property("Topmost", true)
```

---

### app.observe_property(key, callback)

Listen for property change events.

**Parameters:**
- `key`: string - Property name
- `callback`: function(newValue) - Callback function when property changes

**Example:**
```lua
app.observe_property("Path", function(newPath)
    print("Current file path changed:", newPath)
end)
```

---

### app.command(id, param)

Execute application command.

**Parameters:**
- `id`: string - Command name (e.g., "CloseApp", "ZoomSet")
- `param`: any (optional) - Command parameter

**Example:**
```lua
app.command("CloseApp")
app.command("ZoomSet", 1.5)
app.command("Navigate", "Next")
app.command("Toggle", "FullScreen")
```

---

### app.command_can_execute(id, param)

Check if a command can be executed.

**Parameters:**
- `id`: string - Command name
- `param`: any (optional) - Command parameter

**Return Value:** boolean - Whether it can be executed

**Example:**
```lua
if app.command_can_execute("CropSave") then
    app.command("CropSave")
end
```

---

### app.add_key_binding(gesture, callback, layer)

Register key binding.

**Parameters:**
- `gesture`: string - Key gesture (e.g., "Ctrl+S", "F5")
- `callback`: function() - Callback function when triggered
- `layer`: string (optional) - Input layer, default is `Global`
  - `"Global"`: Global layer
  - `"Thumbnail"`: Thumbnail layer
  - `"Crop"`: Crop layer
  - `"Video"`: Video layer

**Example:**
```lua
app.add_key_binding("Ctrl+Shift+S", function()
    print("Custom shortcut triggered")
end, "Global")
```

---

### app.on_message(eventName, callback)

Register message event listener.

**Parameters:**
- `eventName`: string - Event name
- `callback`: function(...) - Event callback function

**Example:**
```lua
app.on_message("MyCustomEvent", function(arg1, arg2)
    print("Received message:", arg1, arg2)
end)
```

---

### app.off_message(eventName)

Unregister message event listener.

**Parameters:**
- `eventName`: string - Event name

**Example:**
```lua
app.off_message("MyCustomEvent")
```

---

### app.on_shutdown(callback)

Register application shutdown event.

**Parameters:**
- `callback`: function() - Callback function when application shuts down

**Example:**
```lua
app.on_shutdown(function()
    print("Application is about to close")
end)
```

---

### app.send_message(target, funcName, ...)

Send message to another script.

**Parameters:**
- `target`: string - Target script ID (script filename without extension)
- `funcName`: string - Target function name
- `...`: any - Variable parameters

**Example:**
```lua
app.send_message("Slideshow", "play", "next")
app.send_message("MyScript", "notify", "hello", 123)
```

---

### app.toast

Message notification interface, supporting multiple shortcut methods and custom configuration.

#### Shortcut Methods

```lua
app.toast.info(message, id, duration)    -- Info notification
app.toast.success(message, id, duration) -- Success notification
app.toast.error(message, id, duration)   -- Error notification
app.toast.warn(message, id, duration)    -- Warning notification
app.toast.center(message, id, duration)  -- Center notification
app.toast.at(message, x, y, id, duration) -- Specified position notification
```

**Parameters:**
- `message`: string - Message content
- `id`: string (optional) - Message ID, used to override same ID messages
- `duration`: number (optional) - Display duration (milliseconds), default is 2000
- `x`, `y`: number - Coordinate position

#### Custom Configuration

```lua
app.toast.show({
    text = "Message content",
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

**Configuration Options:**
- `text`: string - Message text
- `id`: string - Message ID
- `duration`: number - Display duration
- `type`: string - Type (`"default"`, `"success"`, `"error"`, `"warning"`, `"info"`, `"center"`, `"custom"`)
- `color`: string - Text color
- `bgColor`: string - Background color
- `fontSize`: number - Font size
- `radius`: number - Corner radius
- `align`: number - Alignment (0=Left, 1=Center, 2=Right)
- `x`, `y`: number - Display position

---

## env Module

### env.id

Current script's ID (filename without extension).

**Type:** string

**Example:**
```lua
print("Current script ID:", env.id)
```

---

### env.ScriptsDir

Scripts directory path.

**Type:** string

---

### env.AppDir

Application directory path.

**Type:** string

---

### env.TempDir

Temp directory path.

**Type:** string

---

## utils Module

### utils.sleep(ms)

Blocking sleep.

**Parameters:**
- `ms`: number - Sleep time (milliseconds)

**Example:**
```lua
utils.sleep(1000)  -- Wait 1 second
```

---

### utils.wait(ms, callback)

Non-blocking wait.

**Parameters:**
- `ms`: number - Wait time (milliseconds)
- `callback`: function() - Callback after wait completes

**Example:**
```lua
utils.wait(2000, function()
    print("Wait completed")
end)
```

---

### utils.execute_process(exePath, arguments, workingDir, hidden, waitForExit, codepage)

Execute external program.

**Parameters:**
- `exePath`: string - Executable file path
- `arguments`: string (optional) - Command line arguments, default empty
- `workingDir`: string (optional) - Working directory, default empty
- `hidden`: boolean (optional) - Whether to hide window, default false
- `waitForExit`: boolean (optional) - Whether to wait for program to complete, default false
- `codepage`: number (optional) - Output encoding code page, default 0 (auto)

**Return Value:**
- When `waitForExit=false` returns `{ pid = number }`
- When `waitForExit=true` returns `{ exitCode = number, stdout = string, stderr = string }`
- Returns `nil` on failure

**Example:**
```lua
-- Async execution
local result = utils.execute_process("notepad.exe", "test.txt", "", false, false)
print("Process ID:", result.pid)

-- Sync execution and wait for completion
local result = utils.execute_process("ping.exe", "localhost", "", false, true)
print("Exit code:", result.exitCode)
print("Standard output:", result.stdout)
```

---

### utils.path_get_dir(path)

Get directory part of file path.

**Parameters:**
- `path`: string - File path

**Return Value:** string - Directory path

**Example:**
```lua
local dir = utils.path_get_dir("C:\\Files\\image.jpg")
-- Returns: "C:\\Files"
```

---

### utils.path_get_name(path)

Get filename (with extension).

**Parameters:**
- `path`: string - File path

**Return Value:** string - Filename

**Example:**
```lua
local name = utils.path_get_name("C:\\Files\\image.jpg")
-- Returns: "image.jpg"
```

---

### utils.path_get_ext(path)

Get file extension.

**Parameters:**
- `path`: string - File path

**Return Value:** string - Extension (with dot)

**Example:**
```lua
local ext = utils.path_get_ext("C:\\Files\\image.jpg")
-- Returns: ".jpg"
```

---

### utils.path_get_name_without_ext(path)

Get filename (without extension).

**Parameters:**
- `path`: string - File path

**Return Value:** string - Filename

**Example:**
```lua
local name = utils.path_get_name_without_ext("C:\\Files\\image.jpg")
-- Returns: "image"
```

---

### utils.path_get_unique(basePath, createDir)

Get unique path (to avoid file overwriting).

**Parameters:**
- `basePath`: string - Base path
- `createDir`: boolean - Whether to create directory

**Return Value:** string - Unique path

**Example:**
```lua
local uniquePath = utils.path_get_unique("C:\\Files\\output.jpg", true)
```

---

### utils.str_lower(str)

Convert to lowercase.

**Parameters:**
- `str`: string - Input string

**Return Value:** string - Lowercase string

---

### utils.str_upper(str)

Convert to uppercase.

**Parameters:**
- `str`: string - Input string

**Return Value:** string - Uppercase string

---

### utils.str_trim(str)

Trim leading and trailing whitespace.

**Parameters:**
- `str`: string - Input string

**Return Value:** string - Trimmed string

---

### utils.str_replace(str, old, new)

Replace string.

**Parameters:**
- `str`: string - Original string
- `old`: string - String to replace
- `new`: string - New string

**Return Value:** string - Replaced string

---

### utils.str_contains(str, value)

Check if string contains specified substring.

**Parameters:**
- `str`: string - Original string
- `value`: string - Substring to find

**Return Value:** boolean - Whether it contains

---

### utils.regex_match(haystack, needle)

Regular expression match.

**Parameters:**
- `haystack`: string - String to search
- `needle`: string - Regular expression pattern

**Return Value:** Match result object `{ index = number, match = table }`
- `index`: number - Match position (starting from 1), 0 means no match
- `match`: table - Match details
  - `[0]`, `[1]`, ...: Capture group contents
  - `["name"]`: Named capture group content
  - `Value`: Table of all capture group values
  - `Pos`: Table of all capture group positions
  - `Len`: Table of all capture group lengths
  - `Count`: Number of capture groups

**Example:**
```lua
local result = utils.regex_match("Hello World 123", "World (\\d+)")
if result.index > 0 then
    print("Match position:", result.index)
    print("Capture group 1:", result.match[1])
end
```

---

### utils.regex_replace(haystack, needle, replacement, limit, startingPos)

Regular expression replace.

**Parameters:**
- `haystack`: string - String to process
- `needle`: string - Regular expression pattern
- `replacement`: string - Replacement string
- `limit`: number (optional) - Maximum replacement count, default -1 (unlimited)
- `startingPos`: number (optional) - Starting position, default 1

**Return Value:** Replacement result object `{ result = string, count = number }`
- `result`: string - Replaced string
- `count`: number - Replacement count

**Example:**
```lua
local result = utils.regex_replace("aabbcc", "b", "x", 1)
-- result.result = "aaxbcc"
-- result.count = 1
```

---

### utils.clip_set(text)

Set clipboard text.

**Parameters:**
- `text`: string - Text to set

**Example:**
```lua
utils.clip_set("Content to copy to clipboard")
```

---

### utils.clip_get()

Get clipboard text.

**Return Value:** string - Clipboard content

**Example:**
```lua
local text = utils.clip_get()
print("Clipboard content:", text)
```

---

## factory Module

### factory.timer(interval, callback)

Create a timer.

**Parameters:**
- `interval`: number - Timer interval (milliseconds)
- `callback`: function() - Callback function to trigger periodically

**Return Value:** LuaTimer object with the following methods:
- `start()`: Start timer
- `stop()`: Stop timer
- `dispose()`: Release timer resources

**Example:**
```lua
local timer = factory.timer(1000, function()
    print("Execute once per second")
end)
timer.start()

-- Stop after 5 seconds
utils.wait(5000, function()
    timer.stop()
    timer.dispose()
end)
```

---

## Usage Examples

### Example 1: Create a Simple Timer Script

```lua
local timer = factory.timer(2000, function()
    local path = app.get_property("Path")
    app.toast.info("Current file: " .. path, "file_watcher", 1500)
end)

timer.start()

app.on_shutdown(function()
    timer.stop()
    timer.dispose()
end)
```

### Example 2: Register a Shortcut Key

```lua
app.add_key_binding("Ctrl+Shift+Z", function()
    local zoom = app.get_property("Zoom")
    app.set_property("Zoom", zoom * 1.2)
    app.toast.success("Zoom in: " .. string.format("%.1f%%", zoom * 120))
end)
```

### Example 3: Listen for Property Changes

```lua
app.observe_property("FillMode", function(newMode)
    print("Fill mode changed to:", newMode)
end)
```

### Example 4: Send Message to Another Script

```lua
-- In ScriptA.lua
app.on_message("custom_event", function(data)
    print("Received message:", data)
end)

-- In ScriptB.lua
app.send_message("ScriptA", "custom_event", "Hello from ScriptB")
```
