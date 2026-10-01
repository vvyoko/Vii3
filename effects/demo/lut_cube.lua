-- @name     LUT 示例（胶片 S 曲线 + 分区染色）
-- @author   vii3
-- @desc     载入 luts/film_s_curve.cube：S 曲线提对比，暗部偏冷、亮部偏暖
-- @version  1.1
-- @builtin  no
-- @needs    none
-- @oneshot  no
--
-- 示例：lut（3D LUT 调色）
--   file 只写文件名 —— 所有 .cube 都放在 data/effects/luts/ 里（不写路径、不许子目录，
--   写 "../x.cube" / "sub/x.cube" 会被直接拒绝并说明原因）。
--   film_s_curve.cube 是随程序发布的 33³ LUT（红最快 → 绿 → 蓝，值域 0..1）：
--   r/g/b 先过一条 S 曲线 x²(3-2x)（提对比），再按亮度分区染色 ——
--   暗部抬一点蓝绿、亮部加一点黄红（split toning）。
--
-- 为什么它是 .cube 文件、而不是脚本里算出来的（值得一读）：
--   33³ = 35937 行本来就是数据 —— 算一次、读一万次的东西，没理由每次加载都现算。
--   脚本里现算还有两堵墙（各自就够撞）：求值只有 300ms 预算；#t 在 LuaCSharp 里是 O(n)
--   （t[#t + 1] = v 实际是 O(n²)），以及 string.format 每次调用都要解析格式串。
--   这两条对 33³ 是几百毫秒的量级 ⇒ 只能走文件。见 api.md 的 1.3。
--
-- 只想"沾一点"LUT 的味道就套 lerp（t = 强度）：
--   { lerp = { t = 0.7, a = { identity = true }, b = { lut = { file = "film_s_curve.cube" } } } }
return {
  { lut = { file = "film_s_curve.cube" } },
}
