import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class WaveformPainter extends CustomPainter {
  final double level;
  final List<double> waves;

  WaveformPainter({required this.level, required this.waves});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.8)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final middle = size.height / 2;
    final width = size.width;
    final spacing = width / (waves.length - 1);

    for (int i = 0; i < waves.length; i++) {
      final x = i * spacing;
      final height = waves[i] * size.height * level * 0.5;
      canvas.drawLine(
        Offset(x, middle - height),
        Offset(x, middle + height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.level != level || oldDelegate.waves != waves;
  }
}
