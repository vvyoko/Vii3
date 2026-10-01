-- @name     水波
-- @author   vii3
-- @desc     噪声位移扭曲（displacement：水波 / 热浪 / 玻璃感）
-- @version  1.0
-- @builtin  no
-- @needs    none
-- @oneshot  no
--
-- 示例：displacement（原生位移图）
--   引擎用 Perlin 湍流噪声当位移图，取它的 R/G 通道分别当 x/y 偏移量：
--     scale       偏移强度（像素级，越大扭曲越夸张）
--     frequency   噪声密度：越大波纹越密（越小越"大块扭曲"）
--                 有范围：非负、常规 0~1，且不能是整数 ——
--                 整数频率（1/2/3…，老版本这里写过 6）会让噪声恒为 0，位移图变常量，
--                 效果退化成"整图平移"（照片上几乎看不出来，但像素确实变了）。
--                 实用区间 0.002~0.5，从 0.02 起步
--     octaves     叠加层数：越多细节越多（1~4 一般够）
--     seed        换个种子就换一套波纹（同一张图每次开程序都一样）
-- 想让波纹动起来（动画）得靠每帧换 seed / scale —— 那是"动画"那条路的事，脚本这边是静态的。
return {
  { displacement = { scale = 20, frequency = 0.02, octaves = 2, seed = 7 } },
}
