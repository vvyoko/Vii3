-- 关闭界面所有元素并置顶方便查看
-- 关闭程序时重置为启用前状态
-- 如果中途手动修改某状态，不会重置该状态

-- 快捷键或菜单绑定方法
-- 命令 - 向脚本发送消息
-- 参数 - CleanMode Toggle
-- 切换
-- 参数 - CleanMode On
-- 开启
-- 参数 - CleanMode Off
-- 关闭

-- 命令行启动方法
-- Vii3.exe --OpenClipboardFilesOrImage --SendMessageToScript="CleanMode On"
-- 打开剪贴板中图片，并切换至打开清洁模式状态
-- Vii3.exe --SendMessageToScript="CleanMode On" “图片路径”
-- 打开某图片，并切换至打开清洁模式状态

local app = require 'app'

-- 【全局状态缓存】只记录一次原始状态，切换时恢复
local originalState = nil

-- 【目标状态表】定义清洁模式下，每个属性“应该是”什么样子
local TARGET_STATE = {
    IsImageInfoEnabled       = false,
    IsTitleEnabled           = false,
    Topmost                  = true,
    IsWindowFitsImageEnabled = true
}

local function ToggleCleanMode()
    if not originalState then
        -- 【进入清洁模式】
        originalState = {}
        for key, target in pairs(TARGET_STATE) do
            local current = app.get_property(key)
            originalState[key] = current -- 记录原始值

            -- 只有当前值不等于目标值时，才执行设置
            if current ~= target then
                app.set_property(key, target)
            end
        end
    else
        -- 【恢复原始模式】
        for key, original in pairs(originalState) do
            -- 只有当前（清洁模式下）的值不等于原始值，才拨回去
            if app.get_property(key) ~= original then
                app.set_property(key, original)
            end
        end
        originalState = nil
    end
end

-- 绑定快捷键 F3 切换
app.add_key_binding("F3", ToggleCleanMode)

app.on_message("Toggle", function()
    ToggleCleanMode()
end)

app.on_message("On", function()
    if not originalState then
        ToggleCleanMode()
    end
end)

app.on_message("Off", function()
    if originalState then
        ToggleCleanMode()
    end
end)

app.on_event("Shutdown", function()
    if originalState then
        ToggleCleanMode()
    end
end)
