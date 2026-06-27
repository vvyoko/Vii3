-- 用于其他程序调用 Vii3 OCR指定图片
-- 其他程序生成或设置某张图片，然后通过命令行调用
-- 如果全新启动每次都会加载模型，它比较耗时
-- 如果多次调用可在每次 OCR 后保持程序打开状态，后续不必加载模型

-- 命令行启动方法
-- Vii3.exe --SendMessageToScript="Ocr Request --OpenClipboardFilesOrImage"
-- 打开剪贴板中图片并OCR
-- Vii3.exe --SendMessageToScript="Ocr Request" “图片路径”
-- 打开指定图片并OCR

local app = require 'app'
local factory = require 'factory'

local requestVersion = 0
local imageLoadedVersion = 0
local isOcrPending = false
local coldStartTimer = nil

app.on_event("ImageLoaded", function()
    imageLoadedVersion = imageLoadedVersion + 1
    if isOcrPending then
        if imageLoadedVersion >= requestVersion then
            app.command("Toggle", "Ocr")
        end
        isOcrPending = false
    end
end)

app.on_message("Request", function()
    isOcrPending = true
    requestVersion = requestVersion + 1

    -- 只针对第一张图片的冷启动处理
    if requestVersion == 1 then
        -- 开启周期轮询
        coldStartTimer = factory.timer(50, function()
            --用于检查定时器是否中止,即不再出现toast即代表中止
            -- app.toast("检测中", "test")

            -- 直到主程序真正出现图片,不论快慢
            if app.get_property("HasImage") then
                -- 此时有图了，检查第一张图的事件是不是被漏掉了
                if imageLoadedVersion == 0 and isOcrPending then
                    -- imageLoadedVersion 还是 0，说明事件可能在脚本出生前漏掉了(极快图)
                    app.command("Toggle", "Ocr")
                    isOcrPending = false
                    -- 修改版本号
                    imageLoadedVersion = 1
                end

                -- 无论如何,销毁定时器
                if coldStartTimer ~= nil then
                    coldStartTimer:Stop()
                    coldStartTimer:Kill()
                    coldStartTimer = nil
                end
            end
        end)

        -- 启动冷启动轮询
        coldStartTimer:ReStart()
    end
end)


-- Vii3.exe --SendMessageToScript="Ocr Request" “图片路径”
-- 命令行如上,它的作用是先请求,再加载图片
-- 在脚本已经加载的情况下,双方是"同步"的(即上面说的复用)

-- 但在新实例的情况下,脚本初始化是在新线程中
-- 而在脚本加载前它没监听事件了,也没监听消息
-- Request 会存至队列,因为它和脚本相关
-- 而 ImageLoaded 它属于事件,它和脚本是无关的
-- 这样就会导致一种情况
-- 某些图片加载的非常快(脚本加载完之前)就已经走完了整个流程并触发了 ImageLoaded
-- 而 Request 此时还在队列中,待脚本加载完后才收到
-- 这样就导致收到的请求,但 ImageLoaded 会在下一图片触发
-- 两个version用于解决这个,注意两个 version 它不是完全同样的值
-- 因为每张图片都会增加 imageLoadedVersion ,但不是每张图片都会请求 增加 requestVersion
-- 所以在 ImageLoaded 里它的条件是 imageLoadedVersion >= requestVersion
-- imageLoadedVersion它的值是否完全符合递增无所谓,因为它当前只是用于解决第一张的问题
-- 后续它是完全成立的表达式了(定时器中将它置为1就是为了追上这一点,即使 ImageLoaded 中递增为2也无所谓)
-- 定时器用于尝试解决第一个 ImageLoaded 未收到的问题

-- 上面是小图加载太快,那当然会有部分图片加载较慢
-- 正常情况下慢图不是需要处理的,但是由于加了定时器处理快图,所以在这解释下它不会影响到慢图
-- 基于UI的单线程和脚本的单线程推导
-- UI的命令,事件,属性等等是同步的
-- HasImage 是在 ImageLoaded 之前 更新
-- 然后会出现这样一种情况
-- 正好在定时器新一轮循环时走到了获取 HasImage 并获取true(属性已加载,事件未触发)
-- 由于脚本也是单线程,那么在这种情况,它会消耗掉 isOcrPending
-- 最终 ImageLoaded 事件触发时 isOcrPending 就为false了