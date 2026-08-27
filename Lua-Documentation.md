<summary><h1>Lua API Documentation</h1></summary>


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

**Return Value:** Used to cancel listening

**Example:**
```lua
app.observe_property("Path", function(newPath)
    print("Current file path changed:", newPath)
end)
```

---

### app.unobserve_property(id)

Cancels a listener property callback.

**Parameters:**
- `id`: int - Return value from observe_property

**Example:**
```lua
local id = app.observe_property("Path", function(newPath)
end)
app.unobserve_property(id)
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
  - `"Ocr"`: OCR layer
  
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

### app.on_event(id,callback)

Listening for events.

**Parameters:**
- `id`: (string)AppEvent - event name
- `callback`: function() - Callback function when event is triggered

**Example:**
```lua
app.on_event("Shutdown", function()
    print("Application is about to close")
end)
```

---

### app.off_event(id)

Cancel the callback for a certain listening event.

**Parameters**
- `id`: int - Return value obtained from on_event

**Example:**
```lua
local id = app.on_event("ImageLoaded", function()
end)
app.off_event(id)
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

### env.AppVersion

Current program version.

**Type:** string

**Example:**
```lua
print("Current program version:", env.AppVersion)
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
### utils.regex_match(haystack, needle)

Regular expression match.

**Parameters:**
- `haystack`: string - String to search
- `needle`: string - Regular expression pattern (Perl-compatible)

**Return Value:**
- On success: Returns a `MatchInfo` object
- On failure: Returns `nil`

**MatchInfo Object Properties:**

| Property | Type | Description |
|----------|------|-------------|
| `[0]` | string | The entire match text |
| `[1]`, `[2]`, ... | string | Capture group contents (indexed by number) |
| `["name"]` | string | Named capture group content (if any) |
| `Count` | number | Total number of capture groups (excluding the overall match) |
| `Position` | number | Starting position of the entire match (1-based) |
| `Pos` | table | Position table for all capture groups (1-based) |
| `Len` | table | Length table for all capture groups |

**Pos/Len Table Indexing Rules:**
- `Pos[0]` / `Len[0]`: Position/length of the overall match
- `Pos[1]` / `Len[1]`: Position/length of the 1st capture group
- `Pos["name"]` / `Len["name"]`: Position/length of a named capture group

**Examples:**

```lua
-- Basic match
local m = utils.regex_match("Hello World 123", "World (\\d+)")
if m then
    print("Match position:", m.Position)        -- 7
    print("Overall match:", m[0])               -- "World 123"
    print("Capture group 1:", m[1])             -- "123"
    print("Number of groups:", m.Count)         -- 1
end

-- Named capture groups
local m = utils.regex_match("2026-08-20", "(?P<year>\\d{4})-(?P<month>\\d{2})")
if m then
    print(m["year"])                            -- "2026"
    print(m["month"])                           -- "08"
    print("Year position:", m.Pos["year"])      -- 1
    print("Year length:", m.Len["year"])        -- 4
end

-- Iterate over all capture groups
local m = utils.regex_match("abc123def", "(\\w+)(\\d+)")
if m then
    for i = 0, m.Count do
        print(string.format("Group %d: '%s' (position: %d, length: %d)",
            i, m[i], m.Pos[i], m.Len[i]))
    end
    -- Output:
    -- Group 0: 'abc123' (position: 1, length: 6)
    -- Group 1: 'abc' (position: 1, length: 3)
    -- Group 2: '123' (position: 4, length: 3)
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
  - Positive: start from the Nth character from the beginning (1 = first character)
  - Negative: start from the Nth character from the end (-1 = last character)
  - 0: start from the beginning

**Return Value:** Returns two values
- `result`: string - Replaced string
- `count`: number - Actual replacement count

**Example:**
```lua
-- Basic replacement
local result, count = utils.regex_replace("aabbcc", "b", "x", 1)
-- result = "aaxbcc"
-- count = 1

-- Replace starting from a specific position
local result, count = utils.regex_replace("aabbcc", "b", "x", -1, 3)
-- Start from the 3rd character, replace all 'b's
-- result = "aabxcc"

-- Unlimited replacement
local result, count = utils.regex_replace("aabbcc", "b", "x")
-- result = "aaxxcc"
-- count = 2
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

### utils.base64_encode(text, codepage)

Get Base64 encoded text.

**Parameters:**
- `text`: string - The string to encode.
- `codepage`: int - Codepage ID. The default encoding is UTF-8.

**Return Value:** string - Encoded content.

**Example:**
```lua
local text = utils.base64_encode("hello vii3")
print("Base64 encoded text:", text)
```

---

### utils.base64_decode(text, codepage)

Get Base64 decoded text.

**Parameters:**
- `text`: string - The string to be decoded.
- `codepage`: int - Codepage ID. The default encoding is UTF-8.

**Return Value:** string - Decoded content.

**Example:**
```lua
local text = utils.base64_decode("hello vii3")
print("Base64 decoded text:", text)
```

---

### utils.get_time()

Get current UTC Unix timestamp in milliseconds

**Return Value:**
- `long`: Total milliseconds elapsed from Unix epoch in UTC

---

### utils.reg_write(name, value)

Write value to registry entry exclusive to current script. All data is internally stored as REG_SZ string with type prefix

**Parameters:**
- `name`: string - Registry value name
- `value`: any - Value to write. Supported types: string, boolean, double, int, long, byte array. Other types will be automatically converted to string for storage

**Return Value:**
- `bool`: Returns true if write succeeds; returns false on exception or key creation failure

---

### utils.reg_read(name)

Read registry entry exclusive to current script, automatically parse internal type prefix and restore original data type

**Parameters:**
- `name`: string - Registry value name

**Return Value:**
- `object?`: Restored value with corresponding data type on successful read; returns nil if key not found or read error occurs; raw string will be returned directly if no type prefix exists

---

### utils.reg_delete(name)

Delete specified registry entry exclusive to current script

**Parameters:**
- `name`: string - Registry value name

**Return Value:**
- `bool`: Returns true if deletion succeeds or target value does not exist originally; returns false when operation throws exception

---

## factory Module

### factory.timer(interval, callback)

Create a timer.

**Parameters:**
- `interval`: number - Timer interval (milliseconds)
- `callback`: function() - Callback function to trigger periodically

**Return Value:** LuaTimer object with the following methods:
- `ReStart()`: Start timer
- `Stop()`: Stop timer
- `Kill()`: Release timer resources

**Example:**
```lua
local timer = factory.timer(1000, function()
    print("Execute once per second")
end)
timer.ReStart()

-- Stop after 5 seconds
utils.wait(5000, function()
    timer.Stop()
    timer.Kill()
end)
```

---
## print
- parameters follow the original definition of lua
- Results redirect to Log-Info
---

## Usage Examples

### Example 1: Create a Simple Timer Script

```lua
local timer = factory.timer(2000, function()
    local path = app.get_property("Path")
    app.toast.info("Current file: " .. path, "file_watcher", 1500)
end)

timer.ReStart()

app.on_event("Shutdown", function()
    timer.Stop()
    timer.Kill()
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
