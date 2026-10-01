-- @name     放大镜
-- @author   vii3
-- @desc     指针处一圈放大（透镜跟随指针；画布缩得越小，透镜越强）
-- @version  1.0
-- @builtin  no
-- @needs    pointer, zoom
-- @oneshot  yes
-- @param    radius 0.18 0.05 0.45 透镜半径（按原图短边归一）
--
-- 参数：效果自己声明可调项，外部（快捷方式 / 用户脚本消息 / 以后的设置界面）喂值 ——
--   "设置特效" 命令：半径一点一点放大/缩小就写 "magnifier radius +0.02" / "magnifier radius -0.02"。
--   引擎把 radius 填成 uniform uRadius（u + 首字母大写）；没设置过时它是 0，
--   所以程序里用 "> 0 ? uRadius : 默认" 兜底（默认值与上面 @param 的默认值保持一致）。
--
-- 这是"指针类效果"的示范脚本，与 focus_blur.lua 对照看：
--   focus_blur 用 uFocus + uPointer（虚化焦点跟指针）
--   本脚本再用上 uZoom（画布缩放也进公式）—— 声明在头部 @needs 里，"引擎据此在调用那一刻快照"
--
-- uniform 由引擎填，脚本只声明（写得出来词就说明引擎认，见 api.md「运行期 uniform」）：
--   uFocus   指针位置（图像归一化 0..1；没指针时是 0）
--   uPointer 有没有指针（1 / 0）—— 用 mix 决定"跟指针"还是"落回默认焦点"
--   uZoom    画布缩放倍率（0.1~10）—— 缩得越小，同一块屏幕像素对应的原图细节越多，越需要放大
--
-- 为什么是 SkSL 而不是 magnifier 这个 token：
--   token 版的 magnifier 是 SKImageFilter.CreateMagnifier，x/y/w/h/zoom 全都是**编译期数字**，
--   位置固定不动（跟随指针得把"静态成品 + 绘制期注入"拆开，那一步还没做）。
--   透镜跟随指针这件事用 shader 更直接：会读坐标就会做。
--
-- 代价：每像素多 1 次采样（镜内）⇒ 与整图一样是 O(像素)，没有额外循环。
return {
  { shader = string.format([[
      uniform shader src;
      uniform float2 uImageSize, uSrcOrigin, uSrcScale, uDstOrigin;
      uniform float2 uFocus;      // 引擎填：调用那一刻的指针位置（图像归一化）
      uniform float  uPointer;    // 引擎填：1 = 有指针，0 = 落回默认焦点
      uniform float  uZoom;       // 引擎填：画布缩放倍率
      uniform float  uRadius;     // 引擎填：外部设置过的半径（0 = 没设置过 ⇒ 用脚本默认 kRadius）

      const float kRadius   = %f;   // 透镜半径（按原图短边归一）
      const float kBaseZoom = %f;   // 基准放大倍数（屏幕 1:1 时）
      const float kMinZoom  = 1.2;  // 放大倍数下限（画布已经放得很大时，透镜别倒缩）
      const float kMaxZoom  = 4.0;  // 放大倍数上限（画布缩得很小时，别把采样拉爆）

      half4 main(float2 p) {
          float2 imgPx = uSrcOrigin + (p - uDstOrigin + 0.5) * uSrcScale;

          // 焦点：有指针就跟指针，没有就居中（默认焦点写在这里，引擎不猜）
          float2 focus  = mix(float2(0.5, 0.5), uFocus, uPointer) * uImageSize;
          float  radius = (uRadius > 0.0 ? uRadius : kRadius) * min(uImageSize.x, uImageSize.y);

          float2 d    = imgPx - focus;
          float  dist = length(d);

          // 镜外原样：透镜是"局部效果"，不动别处（天然适合按瓦片烘）
          if (dist > radius) return src.eval(imgPx);

          // 放大 = 把"离焦点的距离"按倍率缩短；画布缩得越小放得越大
          float  mag    = clamp(kBaseZoom / max(uZoom, 0.35), kMinZoom, kMaxZoom);
          float2 sample = clamp(focus + d / mag, float2(0.0), uImageSize - float2(1.0));

          half4 c = src.eval(sample);

          // 镜框：外圈提亮一点，边界看得出"玻璃"
          half edge = half(smoothstep(radius * 0.82, radius, dist));
          return half4(mix(c.rgb, c.rgb * half(1.18), edge * half(0.6)), c.a);
      }
  ]], 0.18, 2.5) },
}
