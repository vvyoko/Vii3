-- 要求程序版本 3.1.18

-- 用于检查程序更新
-- 每7天检查一次
-- 需确保 powershell 可以访问 github
-- 检查到更新后需手动前往下载
-- 默认绑定快捷键 F1 前往下载页
-- 它会覆盖配置中的用户定义快捷键中的F1
-- 如不需要可将其注释掉,并取消 local key = nil 的注释
-- 如需要此键但冲突,可更改为其他不冲突键

local app = require 'app'
local utils = require 'utils'
local env = require 'env'

local key = "F1" --如需取消快捷键请注释本行,取消取消下行
-- local key = nil

local localVersion = env.AppVersion
local exePath = "powershell.exe"

---------------------------------------------------------
-- 1. 注册表时间戳检查策略 (利用新增的 API)
---------------------------------------------------------
local SEVEN_DAYS_MS = 7 * 24 * 60 * 60 * 1000 -- 7天的毫秒数
local currentTime = utils.get_time()          -- 获取当前 Unix 毫秒时间戳
local lastCheckTime = utils.reg_read("LastCheckTime")

-- 绑定快捷键
if key and #key > 0 then
    app.add_key_binding(key, function()
        utils.execute_process("https://github.com/vvyoko/Vii3/releases")
    end)
end

-- 如果注册表里有上次检查时间，且当前时间距离上次检查未满 7 天，则静默跳过
if lastCheckTime and type(lastCheckTime) == "number" then
    if (currentTime - lastCheckTime) < SEVEN_DAYS_MS then
        print("距离上次检查未满 7 天，静默跳过版本更新检查。")
        return -- 直接结束脚本，不再启动 PowerShell
    end
end

---------------------------------------------------------
-- 2. 核心网络请求 PowerShell 代码 (不再包含注册表逻辑)
---------------------------------------------------------
local psCode = [[
$response = Invoke-RestMethod -Uri "https://api.github.com/repos/vvyoko/Vii3/releases/latest" -ErrorAction SilentlyContinue
if ($response) {
    Write-Output $response.tag_name
} else {
    exit 1
}
]]

-- 转为 PowerShell 要求的 Base64 (UTF-16LE / CP 1200) 密文
local base64Code = utils.base64_encode(psCode, 1200)
local arguments = "-NoProfile -ExecutionPolicy Bypass -EncodedCommand " .. base64Code

-- 执行外部程序进行更新检测
local result = utils.execute_process(exePath, arguments, "", true, true, 65001)

---------------------------------------------------------
-- 3. 业务逻辑与结果判断
---------------------------------------------------------
if result and result.exitCode == 0 then
    -- 清洗首尾多余换行符
    local latestTag = result.stdout:gsub("^%s*(.-)%s*$", "%1")

    if latestTag == "" then
        app.toast.warning("未能获取到有效的 Tag 标签", "UpdateCheck", "UpdateCheck", 5000)
    else
        -- 成功获取到新标签，更新注册表中的最后检查时间
        utils.reg_write("LastCheckTime", currentTime)

        if latestTag == localVersion then
            app.toast.info(string.format("当前已是最新版本！(Tag: %s)", latestTag), "UpdateCheck", 5000)
        else
            local tip = ""
            if key ~= nil and #key > 0 then
                tip = string.format("，请按 %s 键前往下载", key)
            end
            app.toast.info(string.format("发现新版本！最新: %s，本地: %s%s", latestTag, localVersion, tip), "UpdateCheck", 5000)
        end
    end
else
    -- 只有在 exitCode 不为 0 时，stderr 里的内容才是真正的致命错误
    local errorMsg = "未知错误"
    if result and result.stderr and result.stderr ~= "" then
        if result.stderr:find("#< CLIXML") then
            errorMsg = "网络连接超时或 API 请求失败"
        else
            errorMsg = result.stderr
        end
    end
    app.toast.error("检查更新失败: " .. errorMsg, "UpdateCheck", 5000)
end
