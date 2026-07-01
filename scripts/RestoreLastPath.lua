-- 要求程序版本 3.1.18

-- 恢复上次关闭前最后打开的路径
-- 压缩包内文件会保存为压缩包本体
-- 存在上次打开文件时绑定快捷键 F3
-- 它会覆盖配置中的用户定义快捷键中的 F3
-- 如此键但冲突,可更改为其他不冲突键

local app = require 'app'
local utils = require 'utils'

local key = "F3"

local lastPath = utils.reg_read("lastPath")
local currentPath = nil

if lastPath and key and #key > 0 then
    --没有文件是否存在的api,但有此api,如果它返回的值相同则代表历史记录不存在,反之则代表当前记录存在
    local isExist = utils.path_get_unique(lastPath) ~= lastPath
    if isExist then
        app.add_key_binding(key, function()
            --此命令要求参数 string[],用 table {路径1,路径2} 传过去
            app.command("LoadFiles", { lastPath })
        end)
    end
end

app.observe_property("Path", function(newVal)
    if newVal and #newVal > 0 then
        currentPath = newVal
    end
end)

app.on_event("Shutdown", function()
    if currentPath then
        utils.reg_write("lastPath", currentPath)
    end
end)
