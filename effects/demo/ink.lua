-- @name     墨感
-- @author   vii3
-- @desc     收细亮部 + 提对比、略降饱和（erode：沉稳、版画感）
-- @version  1.0
-- @builtin  no
-- @needs    none
-- @oneshot  no
--
-- 示例：erode（原生形态学腐蚀）
--   每个像素取邻域最小值 ⇒ 亮部被"啃掉"一圈、细亮线会消失。
--   与 glow.lua 的 dilate 正好相反：那个让亮部变胖，这个让亮部变瘦。
return {
  { erode = { radius = 2 } },
  { look = { contrast = 1.10, saturation = 0.92 } },
}
