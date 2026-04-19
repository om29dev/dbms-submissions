import 'dart:math';
import 'package:flutter/material.dart';
import '../../../providers/voice_provider.dart';
import '../../../core/constants/app_colors.dart';

/// Sci-fi AI core visualizer — four-state animated rings + orb.
/// Rebuilt on every frame via AnimationController; uses CustomPainter.
class AIVisualizer extends StatefulWidget {
  final VoiceState voiceState;
  final double soundLevel; // 0.0 – 1.0 (from VoiceProvider)

  const AIVisualizer({
    super.key,
    required this.voiceState,
    this.soundLevel = 0.0,
  });

  @override
  State<AIVisualizer> createState() => _AIVisualizerState();
}

class _AIVisualizerState extends State<AIVisualizer>
    with TickerProviderStateMixin {
  // Ring rotation controllers
  late final AnimationController _ring1; // CW  (dashed cyan)
  late final AnimationController _ring2; // CCW (solid blue)
  late final AnimationController _ring3; // CW  (dotted white)

  // Orb pulse
  late final AnimationController _orbPulse;

  // Processing "thinking" dot orbit
  late final AnimationController _dotOrbit;

  // Bar heights for listening/speaking waveform
  final List<double> _barHeights = List.filled(8, 0.3);
  final Random _rng = Random();

  // Sine wave phase for speaking orb surface
  double _wavePhase = 0.0;

  @override
  void initState() {
    super.initState();

    _ring1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _ring2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _ring3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 35),
    )..repeat();

    _orbPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _dotOrbit = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Periodically animate bar heights for waveform
    _startBarAnimation();
  }

  Future<void> _startBarAnimation() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) break;
      final active = widget.voiceState == VoiceState.listening ||
          widget.voiceState == VoiceState.speaking;
      if (active) {
        setState(() {
          for (int i = 0; i < _barHeights.length; i++) {
            // Bias toward soundLevel for listening
            final bias = widget.voiceState == VoiceState.listening
                ? widget.soundLevel.clamp(0.0, 1.0)
                : 0.5;
            _barHeights[i] = 0.1 + _rng.nextDouble() * (0.5 + bias * 0.5);
          }
          _wavePhase += 0.18;
        });
      }
    }
  }

  @override
  void didUpdateWidget(AIVisualizer old) {
    super.didUpdateWidget(old);
    // Adjust pulse speed per state
    final listening = widget.voiceState == VoiceState.listening;
    final processing = widget.voiceState == VoiceState.processing;

    _orbPulse.duration = Duration(milliseconds: listening ? 500 : 2000);
    if (!_orbPulse.isAnimating) _orbPulse.repeat(reverse: true);

    // Spin rings faster during processing
    _ring1.duration =
        Duration(milliseconds: (processing ? 6700 : 20000).toInt());
    _ring2.duration =
        Duration(milliseconds: (processing ? 8300 : 25000).toInt());
    _ring3.duration =
        Duration(milliseconds: (processing ? 11700 : 35000).toInt());
  }

  @override
  void dispose() {
    _ring1.dispose();
    _ring2.dispose();
    _ring3.dispose();
    _orbPulse.dispose();
    _dotOrbit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _ring1,
          _ring2,
          _ring3,
          _orbPulse,
          _dotOrbit,
        ]),
        builder: (_, __) {
          return CustomPaint(
            size: const Size(360, 360),
            painter: _VisualizerPainter(
              voiceState: widget.voiceState,
              ring1Angle: _ring1.value * 2 * pi,
              ring2Angle: -_ring2.value * 2 * pi,
              ring3Angle: _ring3.value * 2 * pi,
              orbPulse: _orbPulse.value,
              dotOrbitAngle: _dotOrbit.value * 2 * pi,
              barHeights: List.from(_barHeights),
              wavePhase: _wavePhase,
            ),
          );
        },
      ),
    );
  }
}

// ─── CustomPainter ────────────────────────────────────────────────────────────

class _VisualizerPainter extends CustomPainter {
  final VoiceState voiceState;
  final double ring1Angle;
  final double ring2Angle;
  final double ring3Angle;
  final double orbPulse; // 0.0 → 1.0
  final double dotOrbitAngle;
  final List<double> barHeights;
  final double wavePhase;

  static const _amber = Color(0xFFFFB300);

  _VisualizerPainter({
    required this.voiceState,
    required this.ring1Angle,
    required this.ring2Angle,
    required this.ring3Angle,
    required this.orbPulse,
    required this.dotOrbitAngle,
    required this.barHeights,
    required this.wavePhase,
  });

  bool get _isListening => voiceState == VoiceState.listening;
  bool get _isProcessing => voiceState == VoiceState.processing;
  bool get _isSpeaking => voiceState == VoiceState.speaking;

  // Scale factor: rings grow 20% when listening
  double get _scale => _isListening ? 1.2 : 1.0;

  // Ring radii (base)
  double get _r1 => 110 * _scale;
  double get _r2 => 140 * _scale;
  double get _r3 => 175 * _scale;
  double get _orbR => 80.0;

  // Ring colors shift to amber during processing
  Color get _ring1Color => _isProcessing
      ? _amber
      : _isListening
          ? AppColors.accent
          : AppColors.accent.withValues(alpha: 0.8);
  Color get _ring2Color =>
      _isProcessing ? _amber.withValues(alpha: 0.75) : AppColors.primary;
  Color get _ring3Color => _isProcessing
      ? _amber.withValues(alpha: 0.4)
      : Colors.white.withValues(alpha: 0.3);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);

    // ── Ring 1: dashed cyan, clockwise ─────────────────────────────────────
    _drawDashedArc(canvas, center, _r1, ring1Angle, _ring1Color, 2.0, 24);

    // ── Ring 2: solid electric blue, counter-clockwise ─────────────────────
    _drawSolidRing(canvas, center, _r2, ring2Angle, _ring2Color, 1.5);

    // ── Ring 3: dotted white, clockwise ────────────────────────────────────
    _drawDottedRing(canvas, center, _r3, ring3Angle, _ring3Color, 1.0, 48);

    // Processing: loading arc overlay on ring 3
    if (_isProcessing) {
      _drawLoadingArc(canvas, center, _r3);
      _drawOrbitingDots(canvas, center);
    }

    // ── Orb ────────────────────────────────────────────────────────────────
    _drawOrb(canvas, center);
  }

  // ── Orb ──────────────────────────────────────────────────────────────────

  void _drawOrb(Canvas canvas, Offset center) {
    final opacity = 0.7 + orbPulse * 0.30;
    final orbColor = _isProcessing ? _amber : AppColors.accent;

    // Outer glow
    final glowPaint = Paint()
      ..color = orbColor.withValues(alpha: 0.18 + orbPulse * 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawCircle(center, _orbR + 16, glowPaint);

    // Radial gradient fill
    final fillPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: opacity),
          orbColor.withValues(alpha: opacity * 0.7),
          orbColor.withValues(alpha: opacity * 0.2),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: _orbR));
    canvas.drawCircle(center, _orbR, fillPaint);

    // Listening: waveform bars inside orb
    if (_isListening) {
      _drawOrbWaveformBars(canvas, center);
    }

    // Speaking: sine wave surface
    if (_isSpeaking) {
      _drawSpeakingWave(canvas, center);
    }
  }

  void _drawOrbWaveformBars(Canvas canvas, Offset center) {
    final barPaint = Paint()
      ..color = AppColors.background.withValues(alpha: 0.7)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const barCount = 8;
    const spacing = 10.0;
    const totalW = (barCount - 1) * spacing;
    final startX = center.dx - totalW / 2;
    final maxH = _orbR * 0.7;

    for (int i = 0; i < barCount; i++) {
      final x = startX + i * spacing;
      final h = maxH * barHeights[i];
      canvas.drawLine(
        Offset(x, center.dy + h / 2),
        Offset(x, center.dy - h / 2),
        barPaint,
      );
    }
  }

  void _drawSpeakingWave(Canvas canvas, Offset center) {
    final path = Path();
    final paint = Paint()
      ..color = AppColors.background.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const pts = 60;
    for (int i = 0; i <= pts; i++) {
      final t = i / pts;
      final x = center.dx - _orbR + t * _orbR * 2;
      final y = center.dy +
          sin(t * pi * 4 + wavePhase) *
              (_orbR * 0.22) *
              sin(t * pi); // envelope
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  // ── Ring drawing helpers ──────────────────────────────────────────────────

  void _drawSolidRing(Canvas canvas, Offset center, double radius,
      double rotation, Color color, double width) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.drawCircle(Offset.zero, radius, paint);
    canvas.restore();
  }

  void _drawDashedArc(Canvas canvas, Offset center, double radius,
      double rotation, Color color, double width, int dashCount) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    final dashAngle = (2 * pi) / dashCount;
    final gapAngle = dashAngle * 0.4;
    final arcAngle = dashAngle - gapAngle;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: radius),
        startAngle,
        arcAngle,
        false,
        paint,
      );
    }
    canvas.restore();
  }

  void _drawDottedRing(Canvas canvas, Offset center, double radius,
      double rotation, Color color, double width, int dotCount) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    for (int i = 0; i < dotCount; i++) {
      final angle = (i / dotCount) * 2 * pi;
      final dx = radius * cos(angle);
      final dy = radius * sin(angle);
      canvas.drawCircle(Offset(dx, dy), width, paint);
    }
    canvas.restore();
  }

  void _drawLoadingArc(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = _amber.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // A spinning 120° arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      ring1Angle, // reuse ring1 rotation for continuous spin
      2 * pi / 3,
      false,
      paint,
    );
  }

  void _drawOrbitingDots(Canvas canvas, Offset center) {
    final dotPaint = Paint()..color = _amber.withValues(alpha: 0.9);
    const count = 4;
    const dotR = 4.0;
    const orbitR = 95.0;

    for (int i = 0; i < count; i++) {
      final angle = dotOrbitAngle + (i / count) * 2 * pi;
      final dx = center.dx + orbitR * cos(angle);
      final dy = center.dy + orbitR * sin(angle);
      canvas.drawCircle(
          Offset(dx, dy), dotR * (0.7 + 0.3 * sin(angle)), dotPaint);
    }
  }

  @override
  bool shouldRepaint(_VisualizerPainter old) => true;
}
