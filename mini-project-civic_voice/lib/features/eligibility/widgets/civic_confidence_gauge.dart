import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Eligibility confidence gauge — pure Flutter, no third-party gauge lib needed.
class CivicConfidenceGauge extends StatelessWidget {
  final double score; // 0.0 to 100.0
  const CivicConfidenceGauge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Civic Confidence Score',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: CustomPaint(
              painter: _GaugePainter(score: score),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      score.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      'Ready',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double score;
  const _GaugePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.7;
    final radius = math.min(cx, cy) * 0.85;
    const startAngle = math.pi;
    const sweepFull = math.pi;

    // Background arc
    final bgPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.4)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle, sweepFull, false, bgPaint,
    );

    // Filled arc
    final fgPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepFull,
        colors: [AppColors.accent, AppColors.primary],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius))
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle, sweepFull * (score / 100), false, fgPaint,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.score != score;
}
