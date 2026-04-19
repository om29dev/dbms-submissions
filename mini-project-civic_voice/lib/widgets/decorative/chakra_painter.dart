import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// CustomPainter that draws the Ashoka Chakra — 24-spoke wheel.
/// Used as a watermark overlay on splash and voice screens.
class ChakraPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double rotationAngle;

  const ChakraPainter({
    this.color = AppColors.gold,
    this.opacity = 0.06,
    this.rotationAngle = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);

    // Outer rim
    canvas.drawCircle(Offset.zero, radius * 0.96, paint);

    // Inner rim
    canvas.drawCircle(Offset.zero, radius * 0.72, paint);

    // Hub circle
    canvas.drawCircle(Offset.zero, radius * 0.10, paint);

    // 24 Spokes
    const spokeCount = 24;
    for (int i = 0; i < spokeCount; i++) {
      final angle = (i * 2 * math.pi) / spokeCount;
      final innerR = radius * 0.10;
      final outerR = radius * 0.96;

      final innerPt =
          Offset(innerR * math.cos(angle), innerR * math.sin(angle));
      final outerPt =
          Offset(outerR * math.cos(angle), outerR * math.sin(angle));

      // Spoke line
      canvas.drawLine(innerPt, outerPt, paint);

      // Small decorative dot at inner rim junction

      // Every 3rd spoke (major spokes) — slightly thicker
      if (i % 3 == 0) {
        final thickPaint = Paint()
          ..color = color.withValues(alpha: opacity * 1.4)
          ..strokeWidth = 1.6
          ..style = PaintingStyle.stroke;
        canvas.drawLine(innerPt, outerPt, thickPaint);
      }

      // Teardrop petal between every pair of spokes (inner rim area)
      if (i % 2 == 0) {
        final petalAngle = angle + math.pi / spokeCount;
        final petalR = radius * 0.40;
        final petalOuter = radius * 0.70;
        final petalInner = radius * 0.20;

        final path = Path()
          ..moveTo(petalInner * math.cos(angle), petalInner * math.sin(angle))
          ..quadraticBezierTo(
            petalR * 1.3 * math.cos(petalAngle),
            petalR * 1.3 * math.sin(petalAngle),
            petalOuter * math.cos(angle + 2 * math.pi / spokeCount),
            petalOuter * math.sin(angle + 2 * math.pi / spokeCount),
          )
          ..quadraticBezierTo(
            petalR * 0.85 * math.cos(petalAngle),
            petalR * 0.85 * math.sin(petalAngle),
            petalInner * math.cos(angle),
            petalInner * math.sin(angle),
          );

        final petalPaint = Paint()
          ..color = color.withValues(alpha: opacity * 0.6)
          ..strokeWidth = 0.7
          ..style = PaintingStyle.stroke;
        canvas.drawPath(path, petalPaint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(ChakraPainter oldDelegate) =>
      oldDelegate.rotationAngle != rotationAngle ||
      oldDelegate.opacity != opacity;
}

/// Animated rotating Ashoka Chakra widget.
class ChakraPainterWidget extends StatefulWidget {
  final double size;
  final double opacity;
  final Color color;
  final bool rotate;

  /// Seconds for one full rotation. Default 8 seconds (slow, majestic).
  final int rotationSeconds;

  const ChakraPainterWidget({
    super.key,
    required this.size,
    this.opacity = 0.06,
    this.color = AppColors.gold,
    this.rotate = true,
    this.rotationSeconds = 8,
  });

  @override
  State<ChakraPainterWidget> createState() => _ChakraPainterWidgetState();
}

class _ChakraPainterWidgetState extends State<ChakraPainterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.rotationSeconds),
    );
    if (widget.rotate) _ctrl.repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.rotate) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: ChakraPainter(
              color: widget.color,
              opacity: widget.opacity,
            ),
          ),
        ),
      );
    }
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: ChakraPainter(
            color: widget.color,
            opacity: widget.opacity,
            rotationAngle: _ctrl.value * 2 * math.pi,
          ),
        ),
      ),
    );
  }
}
