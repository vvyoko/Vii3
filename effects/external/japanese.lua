-- @name     日系
-- @author   vii3
-- @desc     明亮通透、低对比、暗部提亮、轻微偏青绿
-- @version  1.0
-- @builtin  no
-- @needs    none
-- @oneshot  no

-- 日系：提亮 + 低对比 + 暗部提亮，轻微偏青绿
return {
  { look = {
      exposure = 1.04, contrast = 0.92, saturation = 0.94,
      warmth = -0.008, tint = -0.006,
      lift_r = 0.020, lift_g = 0.023, lift_b = 0.024,
  } },
  { curve = {
      r = { { 0, 0.03 }, { 0.5, 0.51 }, { 1, 0.97 } },
      g = { { 0, 0.02 }, { 1, 0.99 } },
  } },
}
