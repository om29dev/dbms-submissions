import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../core/theme/app_theme.dart';
import '../../providers/language_provider.dart';
import '../../providers/voice_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedHeroGreeting extends StatefulWidget {
  const AnimatedHeroGreeting({super.key});

  @override
  State<AnimatedHeroGreeting> createState() => _AnimatedHeroGreetingState();
}

class _AnimatedHeroGreetingState extends State<AnimatedHeroGreeting>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _bounceController;
  late AnimationController _glowController;
  late AnimationController _textController;

  late Animation<double> _bounceAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Wave animation for hand
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Bounce animation for avatar
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // Glow animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Text animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Start animations
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _textController.forward();
        _startWaveSequence();
      }
    });
  }

  void _startWaveSequence() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        await _waveController.forward();
        await _waveController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _bounceController.dispose();
    _glowController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 200),
      margin: const EdgeInsets.all(24),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _bounceController,
          _glowController,
          _waveController,
          _textController,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // Glow effect background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: RadialGradient(
                      center: Alignment.topLeft,
                      radius: 1.5,
                      colors: [
                        AppTheme.electricBlue
                            .withValues(alpha: 0.1 * _glowAnimation.value),
                        AppTheme.neonCyan
                            .withValues(alpha: 0.05 * _glowAnimation.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    // Animated Avatar
                    Expanded(
                      flex: 2,
                      child: Transform.translate(
                        offset: Offset(0, _bounceAnimation.value),
                        child: _buildAnimatedAvatar(),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Greeting Text
                    Expanded(
                      flex: 3,
                      child: SlideTransition(
                        position: _textSlideAnimation,
                        child: FadeTransition(
                          opacity: _textFadeAnimation,
                          child: _buildGreetingText(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Floating particles
              ..._buildFloatingParticles(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedAvatar() {
    return GestureDetector(
      onTap: () {
        final voiceProvider =
            Provider.of<VoiceProvider>(context, listen: false);
        voiceProvider.speak("How can I help you?");
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.electricBlue
                      .withValues(alpha: 0.4 * _glowAnimation.value),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),

          // Mascot Image with border
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.pureWhite.withValues(alpha: 0.3),
                width: 3,
              ),
              image: const DecorationImage(
                image: AssetImage('assets/images/assistant_waving.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Interactive speech bubble hint
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.electricBlue,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 5,
                  )
                ],
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 12),
            )
                .animate(
                    onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                    duration: 1.seconds),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingText() {
    final lang = Provider.of<LanguageProvider>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Animated "Hi!" text
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              AppTheme.electricBlue,
              AppTheme.neonCyan,
            ],
          ).createShader(bounds),
          child: Text(
            lang.translate('hi_greeting'),
            style: GoogleFonts.poppins(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: AppTheme.pureWhite,
              height: 1.0,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          lang.translate('how_can_help'),
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppTheme.pureWhite.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 12),

        // Voice visualization bars
        Row(
          children: List.generate(5, (index) {
            return Container(
              width: 4,
              height:
                  20 + math.sin((index + _glowAnimation.value) * math.pi) * 15,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.electricBlue,
                    AppTheme.neonCyan,
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  List<Widget> _buildFloatingParticles() {
    return List.generate(8, (index) {
      final angle = (index / 8) * 2 * math.pi;
      final radius = 60 + math.sin(_glowAnimation.value * math.pi) * 10;
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;

      return Positioned(
        left: 100 + x,
        top: 100 + y,
        child: Opacity(
          opacity: 0.3 + (_glowAnimation.value * 0.4),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: index % 2 == 0 ? AppTheme.electricBlue : AppTheme.neonCyan,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (index % 2 == 0
                          ? AppTheme.electricBlue
                          : AppTheme.neonCyan)
                      .withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class SmilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, 5)
      ..quadraticBezierTo(size.width / 2, size.height, size.width, 5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
