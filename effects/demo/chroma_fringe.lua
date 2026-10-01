-- @name     色差紫边
-- @author   vii3
-- @desc     R/B 横向错开（必须读邻居像素的那一类）
-- @version  1.0
-- @builtin  no
-- @needs    none
-- @oneshot  no

-- 色差（紫边）：R 往右、B 往左各错开一点 —— "必须读邻居像素"的那一类
return {
  { look = { contrast = 1.05 } },
  { shader = [[
      uniform shader src;
      uniform float2 uSrcOrigin;
      uniform float2 uSrcScale;
      uniform float2 uDstOrigin;

      half4 main(float2 p) {
          float2 imgPx = uSrcOrigin + (p - uDstOrigin + 0.5) * uSrcScale;
          half4 color = src.eval(imgPx);

          float d = 1.0 + 1.5 * 0.7;                       // 错开量（源图像素）
          half r = src.eval(imgPx + float2(d, 0.0)).r;
          half b = src.eval(imgPx - float2(d, 0.0)).b;
          return half4(r, color.g, b, color.a);
      }
  ]] },
}
