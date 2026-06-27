
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

-- 1.PowerShell 代码
local psCode = [[
$regPath = "HKCU:\SOFTWARE\Vii3"
$valueName = "LastCheckTime"
$needsCheck = $true

# 检查注册表项
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
} else {
    $lastCheck = Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue
    if ($lastCheck -and $lastCheck.$valueName) {
        $lastDate = [datetime]::Parse($lastCheck.$valueName)
        if (((Get-Date) - $lastDate).TotalDays -lt 7) {
            $needsCheck = $false
        }
    }
}

# 检查时间策略
if (-not $needsCheck) {
    Write-Output "SKIP_CHECK"
    exit 0
}

# 发起网络更新检测
$response = Invoke-RestMethod -Uri "https://api.github.com/repos/vvyoko/Vii3/releases/latest" -ErrorAction SilentlyContinue
if ($response) {
    # 这里直接用标准的 'yyyy-MM-dd HH:mm:ss' 字符串
    $currentTime = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    Set-ItemProperty -Path $regPath -Name $valueName -Value $currentTime | Out-Null
    Write-Output $response.tag_name
} else {
    exit 1
}
]]

-- 2. 转为 PowerShell 要求的 Base64 (UTF-16LE / CP 1200) 密文
local base64Code = utils.base64_encode(psCode, 1200)
local arguments = "-NoProfile -ExecutionPolicy Bypass -EncodedCommand " .. base64Code

-- 3. 执行外部程序
local result = utils.execute_process(exePath, arguments, "", true, true, 65001)

-- 4. 业务逻辑判断
if result and result.exitCode == 0 then
    -- 清洗首尾多余换行符
    local latestTag = result.stdout:gsub("^%s*(.-)%s*$", "%1")

    if latestTag == "SKIP_CHECK" then
        print("距离上次检查未满 7 天，静默跳过版本更新检查。")
    elseif latestTag == "" then
        app.toast("未能获取到有效的 Tag 标签")
    elseif latestTag == localVersion then
        app.toast(string.format("当前已是最新版本！(Tag: %s)", latestTag))
    else
        local tip = ""
        if key ~= nil and #key > 0 then
            tip = string.format("，请按 %s 键前往下载", key)
        end
        app.toast(string.format("发现新版本！最新: %s，本地: %s%s", latestTag, localVersion, tip))
    end
else
    -- 只有在 exitCode 不为 0 时，stderr 里的内容才是真正的致命错误
    local errorMsg = "未知错误"
    if result and result.stderr and result.stderr ~= "" then
        -- 如果是 CLIXML 进度条干扰，提取不出有效错误，可以给个友好提示
        if result.stderr:find("#< CLIXML") then
            errorMsg = "网络连接超时或 API 请求失败"
        else
            errorMsg = result.stderr
        end
    end
    app.toast("检查更新失败: " .. errorMsg)
end

if key ~= nil and #key > 0 then
    app.add_key_binding(key, function()
        utils.execute_process("https://github.com/vvyoko/Vii3/releases")
    end)
end
