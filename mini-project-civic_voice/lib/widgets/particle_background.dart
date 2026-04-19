import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// A floating particle in the background animation.
class _Particle {
  double x, y;
  double vx, vy;
  double radius;
  double opacity;
  double pulsePhase;
  Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.opacity,
    required this.pulsePhase,
    required this.color,
  });
}

/// Animated particle background using a CustomPainter.
/// 30 slowly drifting particles — reduced from 60 for performance.
/// Wrapped in RepaintBoundary for isolation from parent widget tree.
class ParticleBackground extends StatefulWidget {
  final Widget? child;

  const ParticleBackground({super.key, this.child});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  final Random _rng = Random();

  // Reduced from 60 → 30 to avoid UI thread saturation
  static const int _particleCount = 30;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _particles = [];
  }

  void _initParticles(Size size) {
    if (_particles.isNotEmpty) return;
    final colors = [
      AppColors.accent,
      AppColors.primary,
      AppColors.accentDim,
      AppColors.primaryLight,
      const Color(0xFF00B4D8),
    ];

    for (int i = 0; i < _particleCount; i++) {
      _particles.add(_Particle(
        x: _rng.nextDouble() * size.width,
        y: _rng.nextDouble() * size.height,
        vx: (_rng.nextDouble() - 0.5) * 0.4,
        vy: (_rng.nextDouble() - 0.5) * 0.4,
        radius: _rng.nextDouble() * 2.5 + 0.5,
        opacity: _rng.nextDouble() * 0.4 + 0.05,
        pulsePhase: _rng.nextDouble() * 2 * pi,
        color: colors[_rng.nextInt(colors.length)],
      ));
    }
  }

  void _updateParticles(Size size) {
    for (final p in _particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.pulsePhase += 0.02;
      if (p.x < -5) p.x = size.width + 5;
      if (p.x > size.width + 5) p.x = -5;
      if (p.y < -5) p.y = size.height + 5;
      if (p.y > size.height + 5) p.y = -5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          _initParticles(size);

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              _updateParticles(size);
              return Stack(
                children: [
                  CustomPaint(
                    size: size,
                    painter: _ParticlePainter(List.of(_particles)),
                  ),
                  if (widget.child != null)
                    SizedBox.expand(child: widget.child),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final corePaint = Paint();
    for (final p in particles) {
      final pulsedOpacity =
          (p.opacity + 0.08 * sin(p.pulsePhase)).clamp(0.02, 0.55);
      final pulsedRadius = p.radius + 0.4 * sin(p.pulsePhase + pi / 4);

      // Core dot only — no blur (MaskFilter.blur is GPU-expensive)
      corePaint.color = p.color.withValues(alpha: pulsedOpacity);
      canvas.drawCircle(Offset(p.x, p.y), pulsedRadius, corePaint);
    }
    // NOTE: Connection lines removed — O(n²) loop was a major ANR cause
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}
