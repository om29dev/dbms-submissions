import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ParticleBackground extends StatefulWidget {
  final int numberOfParticles;
  final Color particleColor;
  final double minSpeed;
  final double maxSpeed;
  // connectParticles disabled by default — O(n²) loop causes ANR
  final bool connectParticles;

  const ParticleBackground({
    super.key,
    this.numberOfParticles = 30,
    this.particleColor = AppTheme.electricBlue,
    this.minSpeed = 0.5,
    this.maxSpeed = 2.0,
    this.connectParticles = false,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> particles;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    particles = List.generate(
      widget.numberOfParticles,
      (index) => Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        vx: (random.nextDouble() - 0.5) * (widget.maxSpeed - widget.minSpeed) +
            widget.minSpeed,
        vy: (random.nextDouble() - 0.5) * (widget.maxSpeed - widget.minSpeed) +
            widget.minSpeed,
        size: random.nextDouble() * 3 + 1,
      ),
    );
    // NOTE: Removed _controller.addListener(setState) — was calling setState
    // 60x/sec causing full widget-tree rebuilds on every frame (main ANR cause).
    // AnimatedBuilder in build() handles repaints efficiently without setState.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          for (var particle in particles) {
            particle.update();
          }
          return CustomPaint(
            painter: ParticlePainter(
              particles: List.of(particles),
              particleColor: widget.particleColor,
              connectParticles: widget.connectParticles,
            ),
            child: Container(),
          );
        },
      ),
    );
  }
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
  });

  void update() {
    x += vx * 0.001;
    y += vy * 0.001;

    if (x < 0 || x > 1) vx *= -1;
    if (y < 0 || y > 1) vy *= -1;

    x = x.clamp(0.0, 1.0);
    y = y.clamp(0.0, 1.0);
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Color particleColor;
  final bool connectParticles;

  ParticlePainter({
    required this.particles,
    required this.particleColor,
    required this.connectParticles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = particleColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // connectParticles disabled by default — O(n²) loop caused ANR
    // Each frame: n*(n-1)/2 = 435 sqrt() calls at 30 particles → main thread stall
    if (connectParticles) {
      final linePaint = Paint()
        ..color = particleColor.withValues(alpha: 0.1)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      for (int i = 0; i < particles.length; i++) {
        for (int j = i + 1; j < particles.length; j++) {
          final p1 = particles[i];
          final p2 = particles[j];
          final dx = (p1.x - p2.x) * size.width;
          final dy = (p1.y - p2.y) * size.height;
          final distance = sqrt(dx * dx + dy * dy);
          if (distance < 150) {
            final opacity = (1 - distance / 150) * 0.3;
            linePaint.color = particleColor.withValues(alpha: opacity);
            canvas.drawLine(
              Offset(p1.x * size.width, p1.y * size.height),
              Offset(p2.x * size.width, p2.y * size.height),
              linePaint,
            );
          }
        }
      }
    }

    // Draw particles — no blur (MaskFilter.blur is GPU-expensive)
    for (var particle in particles) {
      final center = Offset(particle.x * size.width, particle.y * size.height);
      canvas.drawCircle(center, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

class AnimatedGradientBackground extends StatefulWidget {
  final List<Color> colors;
  final Duration duration;

  const AnimatedGradientBackground({
    super.key,
    this.colors = const [
      AppTheme.deepSpaceBlue,
      Color(0xFF1A2F4F),
      AppTheme.deepSpaceBlue,
    ],
    this.duration = const Duration(seconds: 10),
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.colors,
              stops: [
                0.0,
                _controller.value,
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}
