-- 用于其他程序调用 Vii3 OCR指定图片
-- 其他程序生成或设置某张图片，然后通过命令行调用
-- 如果全新启动每次都会加载模型，它比较耗时
-- 如果多次调用可在每次 OCR 后保持程序打开状态，后续不必加载模型

-- 命令行启动方法
-- Vii3.exe --OpenClipboardFilesOrImage --SendMessageToScript="Ocr Request"
-- 打开剪贴板中图片并OCR
-- Vii3.exe --SendMessageToScript="Ocr Request" “图片路径”
-- 打开指定图片并OCR

local app = require 'app'

local isOcrPending = false
app.on_event("ImageLoaded", function()
    if isOcrPending then
        app.command("Toggle", "Ocr")
        isOcrPending = false
    end
end)

app.on_message("Request", function()
    isOcrPending = true
end)
