-- @name     褪色
-- @author   vii3
-- @desc     抬黑位、低对比、轻微降饱和（旧照片感）
-- @version  1.0
-- @builtin  no
-- @needs    none
-- @oneshot  no

-- 褪色：抬黑位 + 低对比 + 轻微降饱和（旧照片 / 一次性相机感）
return {
  { look = {
      contrast = 0.86, saturation = 0.88, lift = 0.038,
  } },
}
