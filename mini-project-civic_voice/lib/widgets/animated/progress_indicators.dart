import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class CircularProgressCard extends StatefulWidget {
  final double progress;
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  const CircularProgressCard({
    super.key,
    required this.progress,
    required this.title,
    this.subtitle = '',
    this.color = AppTheme.electricBlue,
    this.icon = Icons.check_circle,
  });

  @override
  State<CircularProgressCard> createState() => _CircularProgressCardState();
}

class _CircularProgressCardState extends State<CircularProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _progressAnimation =
        Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    if (widget.progress >= 1.0) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _controller.repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.glassBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    widget.color.withValues(alpha: 0.3 * _glowAnimation.value),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  children: [
                    // Background circle
                    CustomPaint(
                      size: const Size(120, 120),
                      painter: _CircularProgressPainter(
                        progress: 1.0,
                        color: widget.color.withValues(alpha: 0.2),
                        strokeWidth: 12,
                      ),
                    ),

                    // Progress circle
                    CustomPaint(
                      size: const Size(120, 120),
                      painter: _CircularProgressPainter(
                        progress: _progressAnimation.value,
                        color: widget.color,
                        strokeWidth: 12,
                      ),
                    ),

                    // Center content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.icon,
                            color: widget.color,
                            size: 32,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(_progressAnimation.value * 100).toInt()}%',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.pureWhite,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Celebration particles when complete
                    if (_progressAnimation.value >= 0.99)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _CelebrationParticlesPainter(
                            animation: _controller,
                            color: widget.color,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.pureWhite,
                ),
              ),
              if (widget.subtitle.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.pureWhite.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _CelebrationParticlesPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _CelebrationParticlesPainter({
    required this.animation,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * pi / 180;
      final distance = 60 * animation.value;
      final x = center.dx + cos(angle) * distance;
      final y = center.dy + sin(angle) * distance;

      final paint = Paint()
        ..color = color.withValues(alpha: 1 - animation.value)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x, y),
        3 * (1 - animation.value),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_CelebrationParticlesPainter oldDelegate) => true;
}

class LinearProgressCard extends StatefulWidget {
  final double progress;
  final String title;
  final String label;
  final Color color;

  const LinearProgressCard({
    super.key,
    required this.progress,
    required this.title,
    this.label = '',
    this.color = AppTheme.electricBlue,
  });

  @override
  State<LinearProgressCard> createState() => _LinearProgressCardState();
}

class _LinearProgressCardState extends State<LinearProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _progressAnimation =
        Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.glassBorder,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.pureWhite,
                    ),
                  ),
                  Text(
                    '${(_progressAnimation.value * 100).toInt()}%',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: _progressAnimation.value,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.color,
                              widget.color.withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.label.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.pureWhite.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
