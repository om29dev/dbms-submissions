import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class VoiceWaveform extends StatefulWidget {
  final bool isListening;
  final double size;
  final Color color;
  final int numberOfBars;

  const VoiceWaveform({
    super.key,
    this.isListening = false,
    this.size = 200,
    this.color = AppTheme.electricBlue,
    this.numberOfBars = 40,
  });

  @override
  State<VoiceWaveform> createState() => _VoiceWaveformState();
}

class _VoiceWaveformState extends State<VoiceWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random random = Random();
  late List<double> barHeights;

  @override
  void initState() {
    super.initState();
    barHeights = List.generate(widget.numberOfBars, (_) => 0.1);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    // NOTE: Removed addListener(setState) — was calling setState 10x/sec
    // causing full widget-tree rebuilds. AnimatedBuilder handles this efficiently.

    if (widget.isListening) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(VoiceWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _controller.repeat();
      } else {
        _controller.stop();
        barHeights = List.generate(widget.numberOfBars, (_) => 0.1);
      }
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
        if (widget.isListening) {
          barHeights = List.generate(
            widget.numberOfBars,
            (_) => Random().nextDouble() * 0.8 + 0.2,
          );
        }
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: WaveformPainter(
            barHeights: List.of(barHeights),
            color: widget.color,
            isListening: widget.isListening,
          ),
        );
      },
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> barHeights;
  final Color color;
  final bool isListening;

  WaveformPainter({
    required this.barHeights,
    required this.color,
    required this.isListening,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final barWidth = (2 * pi * radius) / barHeights.length;

    for (int i = 0; i < barHeights.length; i++) {
      final angle = (2 * pi / barHeights.length) * i;
      final barHeight = barHeights[i] * radius * 0.4;

      final startX = center.dx + cos(angle) * (radius - barHeight);
      final startY = center.dy + sin(angle) * (radius - barHeight);
      final endX = center.dx + cos(angle) * radius;
      final endY = center.dy + sin(angle) * radius;

      final gradient = LinearGradient(
        colors: [
          color.withValues(alpha: 0.3),
          color,
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromPoints(
            Offset(startX, startY),
            Offset(endX, endY),
          ),
        )
        ..strokeWidth = barWidth * 0.8
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );

      // Glow effect when listening — no MaskFilter.blur (GPU-expensive)
      if (isListening) {
        final glowPaint = Paint()
          ..color = color.withValues(alpha: 0.25)
          ..strokeWidth = barWidth * 1.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(startX, startY),
          Offset(endX, endY),
          glowPaint,
        );
      }
    }

    // Center circle
    final centerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.8),
          color.withValues(alpha: 0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.3));

    canvas.drawCircle(center, radius * 0.3, centerPaint);
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) => true;
}

class CircularWaveform extends StatefulWidget {
  final bool isActive;
  final double size;
  final Color color;

  const CircularWaveform({
    super.key,
    this.isActive = false,
    this.size = 300,
    this.color = AppTheme.electricBlue,
  });

  @override
  State<CircularWaveform> createState() => _CircularWaveformState();
}

class _CircularWaveformState extends State<CircularWaveform>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late Animation<double> _waveAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _waveAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.linear),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isActive) {
      _waveController.repeat();
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(CircularWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _waveController.repeat();
        _pulseController.repeat(reverse: true);
      } else {
        _waveController.stop();
        _pulseController.stop();
      }
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_waveController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: CircularWavePainter(
                progress: _waveAnimation.value,
                color: widget.color,
                isActive: widget.isActive,
              ),
            ),
          ),
        );
      },
    );
  }
}

class CircularWavePainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isActive;

  CircularWavePainter({
    required this.progress,
    required this.color,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Draw expanding waves
    for (int i = 0; i < 3; i++) {
      final waveProgress = (progress + (i * 0.33)) % 1.0;
      final radius = maxRadius * waveProgress;
      final opacity = (1 - waveProgress) * 0.5;

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawCircle(center, radius, paint);
    }

    // Draw center glow
    if (isActive) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.8),
            color.withValues(alpha: 0.4),
            Colors.transparent,
          ],
        ).createShader(
            Rect.fromCircle(center: center, radius: maxRadius * 0.4));

      canvas.drawCircle(center, maxRadius * 0.4, glowPaint);
    }
  }

  @override
  bool shouldRepaint(CircularWavePainter oldDelegate) => true;
}
