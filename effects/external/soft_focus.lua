-- @name     柔焦
-- @author   vii3
-- @desc     全幅轻糊 + 提黑位（朦胧 / 柔光摄影）
-- @version  1.0
-- @builtin  no
-- @needs    none
-- @oneshot  no
--
-- 示例：blur（原生高斯模糊，整幅、固定 σ）
--   它没有"焦点"这个概念 —— 要"焦点内清晰、越远越糊"用 focusBlur（见 focus_blur.lua）；
--   这里就是全幅柔化：σ 越大越朦胧，配合抬黑位/降对比才像镜头柔焦，而不是像糊了。
return {
  { blur = 6 },
  { look = { exposure = 1.02, contrast = 0.95, lift = 0.02, saturation = 0.96 } },
}
