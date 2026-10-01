-- @name     锐化
-- @author   vii3
-- @desc     3×3 卷积锐化（画质修复 / 缩图后找回一点锐度）
-- @version  1.0
-- @builtin  no
-- @needs    none
-- @oneshot  no
--
-- 示例：convolution（原生卷积核）
--   kernel 展平成一维数组，长度必须 = width × height（行主序）；
--   gain 是整体乘子、bias 是加性偏移、offset_x/offset_y 是核中心（默认取中心）。
-- 这个核就是经典锐化：中心 5、上下左右 -1 ⇒ 边缘两侧差值被放大。
-- 想要更强的锐化：把中心改成 9、四周 -1（和为 1，整体亮度不变）。
return {
  { convolution = {
      kernel = { 0, -1, 0, -1, 5, -1, 0, -1, 0 },
      width = 3,
      height = 3,
  } },
}
