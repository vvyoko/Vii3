-- @name     青橙电影
-- @author   vii3
-- @desc     按亮度分离染色（暗部偏青、亮部偏橙）
-- @version  1.0
-- @builtin  no
-- @needs    none
-- @oneshot  no

-- 青橙电影感：按亮度分区染不同颜色（矩阵做不到 —— 那是跨通道混合），所以直接是一段 SkSL
return {
  { colorShader = [[
      half sCurve(half x) {
          return x * x * (half(3.0) - half(2.0) * x);
      }

      half4 main(half4 color) {
          half3 c = color.rgb;
          half luma = dot(c, half3(0.2126, 0.7152, 0.0722));

          // 阴影偏青、高光偏暖
          half w = smoothstep(half(0.18), half(0.75), luma);
          c *= mix(half3(0.88, 0.99, 1.08), half3(1.08, 1.00, 0.90), w);

          // 轻微 S 曲线 + 略加饱和
          c = mix(c, half3(sCurve(c.r), sCurve(c.g), sCurve(c.b)), half(0.22));
          c = mix(half3(luma), c, half(1.15));

          return half4(clamp(c, half(0.0), half(1.0)), color.a);
      }
  ]] },
}
