-- @name     颗粒
-- @author   vii3
-- @desc     按原图坐标做位置哈希，缩放平移时颗粒不游动
-- @version  1.0
-- @builtin  no
-- @needs    none
-- @oneshot  no

-- 颗粒：位置哈希取"原图坐标" ⇒ 缩放、平移、换瓦片都是同一颗颗粒，不会游动
return {
  { shader = [[
      uniform shader src;
      uniform float2 uSrcOrigin;
      uniform float2 uSrcScale;
      uniform float2 uDstOrigin;

      float hash21(float2 p) {
          float3 q = fract(float3(p.x, p.y, p.x) * 0.1031);
          q += dot(q, float3(q.y, q.z, q.x) + 33.33);
          return fract((q.x + q.y) * q.z);
      }

      half4 main(float2 p) {
          float2 imgPx = uSrcOrigin + (p - uDstOrigin + 0.5) * uSrcScale;
          half4 color = src.eval(imgPx);

          float n = hash21(floor(imgPx / 2.0)) - 0.5;      // 2 = 每颗多少原图像素
          half luma = dot(color.rgb, half3(0.2126, 0.7152, 0.0722));
          half g = half(n * 0.7 * 0.30) * color.a * mix(half(1.0), half(0.55), luma);
          color.rgb = clamp(color.rgb + g, half(0.0), half(1.0));

          return color;
      }
  ]] },
}
