-- @name     线性提亮
-- @author   vii3
-- @desc     sRGB→线性→曝光→sRGB
-- @version  1.0
-- @builtin  no
-- @needs    none
-- @oneshot  no

-- 线性提亮：内部就是"转线性 → 乘系数 → 转回来"（约 +0.35EV）
-- 2^0.35 ≈ 1.2746
return {
  { compose = {
      outer = { linearToSrgb = true },
      inner = { compose = {
          outer = { matrix = {
              1.2746,0,0,0,0,
              0,1.2746,0,0,0,
              0,0,1.2746,0,0,
              0,0,0,1,0,
          } },
          inner = { srgbToLinear = true },
      } },
  } },
}
