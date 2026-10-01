-- @name     奶油柔光
-- @author   vii3
-- @desc     轻微低对比 + 一层奶油色柔光
-- @version  1.0
-- @builtin  no
-- @needs    none
-- @oneshot  no

-- 奶油柔光：先压一点对比，再叠一层奶油色柔光（blend 把 color 当"前景"按 SoftLight 混上去）
return {
  { look = { exposure = 1.02, contrast = 0.97, saturation = 1.02 } },
  { blend = { color = 0xFFF6E8, mode = "SoftLight" } },
}
