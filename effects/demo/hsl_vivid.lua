-- @name     HSL 鲜艳
-- @author   vii3
-- @desc     HSL 空间增饱和 + 轻微提亮
-- @version  1.0
-- @builtin  no
-- @needs    none
-- @oneshot  no

-- HSL 空间增饱和 + 轻微提亮：行依次 H / S / L / A
-- 四个分量都是 0..1（H 是"圈"：1.0 = 360°），所以 S 行对角 1.25 = 饱和 ×1.25、L 行平移 0.03 = 亮度 +0.03
return {
  { hslaMatrix = {
      1, 0,    0, 0, 0,
      0, 1.25, 0, 0, 0,
      0, 0,    1, 0, 0.03,
      0, 0,    0, 1, 0,
  } },
}
