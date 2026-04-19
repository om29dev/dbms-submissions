import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// CustomPainter that draws a Mughal-inspired Jali (lattice) pattern.
/// A repeating diamond-octagon grid — purely geometric, culturally iconic.
class JaliPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double offset;

  static const double _cellSize = 28.0;

  const JaliPatternPainter({
    this.color = AppColors.gold,
    this.opacity = 0.04,
    this.offset = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cols = (size.width / _cellSize).ceil() + 2;
    final rows = (size.height / _cellSize).ceil() + 2;

    final dx = offset % (_cellSize * 2);

    for (int row = -1; row <= rows; row++) {
      for (int col = -1; col <= cols; col++) {
        final cx = col * _cellSize + dx;
        final cy = row * _cellSize + (col.isOdd ? _cellSize / 2 : 0);

        _drawOctagonCell(canvas, paint, cx, cy, _cellSize * 0.42);
      }
    }
  }

  void _drawOctagonCell(Canvas canvas, Paint paint, double cx, double cy, double r) {
    // draw the diamond centre cross
    final path = Path();
    // Octagon
    final vertices = <Offset>[];
    for (int i = 0; i < 8; i++) {
      final angle = math.pi / 8 + i * math.pi / 4;
      vertices.add(Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)));
    }
    path.moveTo(vertices[0].dx, vertices[0].dy);
    for (var v in vertices) {
      path.lineTo(v.dx, v.dy);
    }
    path.close();
    canvas.drawPath(path, paint);

    // Inner cross / diamond
    final innerR = r * 0.45;
    final diamondPath = Path()
      ..moveTo(cx, cy - innerR)
      ..lineTo(cx + innerR, cy)
      ..lineTo(cx, cy + innerR)
      ..lineTo(cx - innerR, cy)
      ..close();
    canvas.drawPath(diamondPath, paint);
  }

  @override
  bool shouldRepaint(JaliPatternPainter oldDelegate) =>
      oldDelegate.offset != offset || oldDelegate.opacity != opacity;
}

/// Animated widget that slowly drifts the jali pattern.
class JaliPattern extends StatefulWidget {
  final double opacity;
  final Color color;
  final bool animate;

  const JaliPattern({
    super.key,
    this.opacity = 0.04,
    this.color = AppColors.gold,
    this.animate = true,
  });

  @override
  State<JaliPattern> createState() => _JaliPatternState();
}

class _JaliPatternState extends State<JaliPattern>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    _anim = Tween<double>(begin: 0, end: 56).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return CustomPaint(
        painter: JaliPatternPainter(
          color: widget.color,
          opacity: widget.opacity,
        ),
        child: const SizedBox.expand(),
      );
    }
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        painter: JaliPatternPainter(
          color: widget.color,
          opacity: widget.opacity,
          offset: _anim.value,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
