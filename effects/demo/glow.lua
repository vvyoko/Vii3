-- @name     柔光发光
-- @author   vii3
-- @desc     亮部外扩一圈再轻微提亮（dilate：发光 / 梦幻）
-- @version  1.0
-- @builtin  no
-- @needs    none
-- @oneshot  no
--
-- 示例：dilate（原生形态学膨胀）
--   每个像素取邻域最大值 ⇒ 亮部向外"撑开"一圈。半径越大扩散越广。
--   注意：这是"形态学"扩散，不是模糊 —— 边缘不会柔化，只是亮部变胖，
--   所以它单独用会显得很硬；这里配一次轻降对比，才像"发光"而不是"发白"。
--   erode 是它的反向（取邻域最小值 = 收细亮部），见 ink.lua。
return {
  { dilate = { radius = 4 } },
  { look = { exposure = 1.02, contrast = 0.95, lift = 0.01 } },
}
