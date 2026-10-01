-- @name     暗角
-- @author   vii3
-- @desc     靠近原图四角才变暗（放大到中央时完全不暗）
-- @version  1.0
-- @builtin  no
-- @needs    none
-- @oneshot  no

-- 暗角：只有靠近原图四角才变暗（放大只看中央时不暗）
-- 空间效果就是一段 SkSL：imgPx（产出像素 → 源图像素）是引擎给的约定，一切按"原图"算。
return {
  { shader = [[
      uniform shader src;
      uniform float2 uImageSize;
      uniform float2 uSrcOrigin;
      uniform float2 uSrcScale;
      uniform float2 uDstOrigin;

      half4 main(float2 p) {
          float2 imgPx = uSrcOrigin + (p - uDstOrigin + 0.5) * uSrcScale;
          half4 color = src.eval(imgPx);

          float2 centerPx = 0.5 * uImageSize;
          float dist = length((imgPx - centerPx) / min(uImageSize.x, uImageSize.y));
          half k = half(0.85) * smoothstep(half(0.45), half(1.0), half(dist));
          color.rgb = color.rgb * mix(half(1.0), half(0.30), k);

          return color;
      }
  ]] },
}
