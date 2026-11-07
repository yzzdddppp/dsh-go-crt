// 550C CRT 覆盖层：扫描线、滚动刷新带、暗角、微闪。
// 纯 Flutter 绘制，无第三方依赖，不拦截触摸。
import 'dart:math' as math;
import 'package:flutter/material.dart';

class CrtOverlay extends StatefulWidget {
  const CrtOverlay({
    super.key,
    this.child,
    this.enabled = true,
    this.scanlineAlpha = 46,
    this.lineSpacing = 3.0,
    this.vignetteStrength = 0.55,
    this.rollDuration = const Duration(seconds: 7),
    this.flicker = true,
    this.tint = const Color(0xFFE8A020),
  });

  final Widget? child;
  final bool enabled;
  final int scanlineAlpha;
  final double lineSpacing;
  final double vignetteStrength;
  final Duration rollDuration;
  final bool flicker;
  final Color tint;

  @override
  State<CrtOverlay> createState() => _CrtOverlayState();
}

class _CrtOverlayState extends State<CrtOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.rollDuration)..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child ?? const SizedBox.shrink();
    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.child != null) widget.child!,
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => CustomPaint(
              painter: _CrtPainter(
                progress: _c.value,
                scanlineAlpha: widget.scanlineAlpha,
                spacing: widget.lineSpacing,
                vignette: widget.vignetteStrength,
                flicker: widget.flicker,
                tint: widget.tint,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CrtPainter extends CustomPainter {
  _CrtPainter({
    required this.progress,
    required this.scanlineAlpha,
    required this.spacing,
    required this.vignette,
    required this.flicker,
    required this.tint,
  });

  final double progress;
  final int scanlineAlpha;
  final double spacing;
  final double vignette;
  final bool flicker;
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 扫描线
    final line = Paint()..color = Colors.black.withAlpha(scanlineAlpha);
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), line);
    }

    // 2. 滚动刷新带（一条自上而下移动的微亮带）
    final bandH = size.height * 0.18;
    final bandTop = (progress * (size.height + bandH)) - bandH;
    final band = Rect.fromLTWH(0, bandTop, size.width, bandH);
    canvas.drawRect(
      band,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            tint.withAlpha(0),
            tint.withAlpha(14),
            tint.withAlpha(0),
          ],
        ).createShader(band),
    );

    // 3. 暗角
    final rect = Offset.zero & size;
    final radius = math.max(size.width, size.height) * 0.75;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.9,
          colors: [
            Colors.transparent,
            Colors.black.withAlpha((vignette * 180).round().clamp(0, 255)),
          ],
          stops: const [0.55, 1.0],
        ).createShader(Rect.fromCircle(center: rect.center, radius: radius)),
    );

    // 4. 微闪：极轻的整体亮度呼吸
    if (flicker) {
      final f = (math.sin(progress * math.pi * 2 * 12) + 1) / 2;
      canvas.drawRect(
        rect,
        Paint()..color = Colors.black.withAlpha((f * 6).round()),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CrtPainter old) =>
      old.progress != progress ||
      old.scanlineAlpha != scanlineAlpha ||
      old.spacing != spacing ||
      old.vignette != vignette ||
      old.flicker != flicker ||
      old.tint != tint;
}
