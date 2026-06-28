-- 要求程序版本 3.1.18

-- 简单幻灯片,支持自定义切换时间

-- 快捷键或菜单绑定方法
-- 命令 - 向脚本发送消息
-- 参数 - Slideshow  Cycle 2000
-- 代表两秒一次的切换

-- 如需要直接启动某个文件夹的幻灯片，参考OCR脚本


local app = require 'app'
local factory = require 'factory'

-- 配置
local DEFAULT_INTERVAL = 5000
local SLIDESHOW_STATE = {
    WindowState    = "FullScreen",
    FillMode       = "FillWindow",
    IsTitleEnabled = false,
    IsImageInfoEnabled  = false
}

-- 定时器
local timer = factory.timer(DEFAULT_INTERVAL, function()
    app.command("Navigate", "Random")
end)
timer:Stop()

local isSlideshowRunning = false
local originalState = nil

local function restoreState()
    if not originalState then return end

    for key, originalVal in pairs(originalState) do
        -- 如果当前配置表里的目标值 和 原始值不一样，说明我们改过，直接恢复
        if SLIDESHOW_STATE[key] ~= originalVal then
            app.set_property(key, originalVal)
        end
    end
    originalState = nil
end

-- 启动幻灯片
local function startSlideshow(customInterval)
    if not app.get_property("HasImage") then return end
    if isSlideshowRunning then return end

    originalState = {}
    for key, target in pairs(SLIDESHOW_STATE) do
        local current = app.get_property(key)
        originalState[key] = current

        if current ~= target then
            app.set_property(key, target)
        end
    end

    -- 定时器
    local interval = tonumber(customInterval) or DEFAULT_INTERVAL
    timer:Stop()
    timer.Interval = interval
    timer:ReStart()

    isSlideshowRunning = true
    app.toast.info(string.format("幻灯片已启动 (%dms)", interval), "CycleSlideshow", 1200)
end

-- 停止幻灯片
local function stopSlideshow()
    if not isSlideshowRunning then return end

    timer:Stop()
    isSlideshowRunning = false


    restoreState()
    app.toast.info("幻灯片已停止", "CycleSlideshow", 1200)
end

-- 切换开关
function CycleSlideshow()
    if isSlideshowRunning then
        stopSlideshow()
    else
        startSlideshow()
    end
end

-- 消息监听
app.on_message("Cycle", function(customMs)
    if isSlideshowRunning then
        stopSlideshow()
    else
        startSlideshow(customMs)
    end
end)

-- 快捷键
app.add_key_binding("F2", CycleSlideshow)

-- 自动停止
app.observe_property("IsThumbnailActive", function(newVal)
    if newVal and isSlideshowRunning then
        stopSlideshow()
    end
end)

-- 退出时安全恢复
app.on_event("Shutdown",restoreState)