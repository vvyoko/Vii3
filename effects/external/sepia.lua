-- @name     棕褐
-- @author   vii3
-- @desc     经典 sepia 矩阵 + 轻微对比与抬黑位
-- @version  1.0
-- @builtin  no
-- @needs    none
-- @oneshot  no

-- 棕褐：经典 sepia 矩阵（矩阵本身可以直接写 20 个数）+ 轻微对比与抬黑位
return {
  { matrix = {
      0.393, 0.769, 0.189, 0, 0,
      0.349, 0.686, 0.168, 0, 0,
      0.272, 0.534, 0.131, 0, 0,
      0, 0, 0, 1, 0,
  } },
  { look = { contrast = 0.95, lift_r = 0.015, lift_g = 0.010, lift_b = 0.005 } },
}
