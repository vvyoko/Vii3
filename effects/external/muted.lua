-- @name     灰调
-- @author   vii3
-- @desc     明显降饱和、略压对比，克制的纪实感
-- @version  1.0
-- @builtin  no
-- @needs    none
-- @oneshot  no

-- 灰调：明显降饱和、略压对比，克制的纪实感
return {
  { look = {
      contrast = 0.95, saturation = 0.55,
      lift_r = 0.010, lift_g = 0.010, lift_b = 0.014,
  } },
}
