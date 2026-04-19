import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:civic_voice_interface/core/theme/app_theme.dart';
import 'package:civic_voice_interface/widgets/glass/glass_card.dart';
import 'package:civic_voice_interface/widgets/animated/particle_background.dart';
import 'package:civic_voice_interface/providers/language_provider.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _particleController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _glowAnimation;

  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoRotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _logoController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _particleController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepSpaceBlue,
      body: Stack(
        children: [
          // Animated gradient background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.deepSpaceBlue,
                    Color(0xFF1A2F4F),
                    AppTheme.deepSpaceBlue,
                  ],
                ),
              ),
            ),
          ),

          // Particle field
          const Positioned.fill(
            child: ParticleBackground(
              numberOfParticles: 80,
              particleColor: AppTheme.electricBlue,
              connectParticles: true,
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // Animated Logo
                    _buildAnimatedLogo(),

                    const SizedBox(height: 60),

                    // Auth Card
                    _buildAuthCard(),

                    const SizedBox(height: 30),

                    // Language Selector
                    _buildLanguageSelector(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: Transform.rotate(
            angle: _logoRotateAnimation.value * 0.5,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.electricBlue.withValues(alpha: 0.8),
                    AppTheme.neonCyan.withValues(alpha: 0.6),
                    AppTheme.gradientStart.withValues(alpha: 0.4),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.electricBlue
                        .withValues(alpha: 0.6 * _glowAnimation.value),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Rotating particles
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _LogoParticlesPainter(
                        animation: _particleController,
                      ),
                    ),
                  ),

                  // Center icon
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.account_balance,
                          size: 50,
                          color: AppTheme.pureWhite,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'CVI',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.pureWhite,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuthCard() {
    return AnimatedGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.accentGradient.createShader(bounds),
            child: Text(
              'Welcome to CVI',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.pureWhite,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Your AI-powered civic assistant',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.pureWhite.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 40),

          // Phone Input
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.glassGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.glassBorder,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.inter(
                    color: AppTheme.pureWhite,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your phone number',
                    hintStyle: GoogleFonts.inter(
                      color: AppTheme.pureWhite.withValues(alpha: 0.5),
                    ),
                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                      color: AppTheme.electricBlue,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // OTP Button
          _buildGlowingButton(),

          const SizedBox(height: 20),

          // Terms
          Text(
            'By continuing, you agree to our Terms & Privacy Policy',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.pureWhite.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowingButton() {
    return _GlowingButton(
      onPressed: () {
        setState(() => _isLoading = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _isLoading = false);
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        });
      },
      isLoading: _isLoading,
      child: Text(
        _isLoading ? 'Sending OTP...' : 'Get OTP',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.deepSpaceBlue,
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    final langProvider = Provider.of<LanguageProvider>(context);

    final languages = [
      {'name': 'English', 'flag': '🇬🇧', 'lang': 'en'},
      {'name': 'हिंदी', 'flag': '🇮🇳', 'lang': 'hi'},
      {'name': 'मराठी', 'flag': '🇮🇳', 'lang': 'mr'},
      {'name': 'தமிழ்', 'flag': '🇮🇳', 'lang': 'ta'},
    ];

    return Column(
      children: [
        Text(
          'Select Language',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.pureWhite.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: languages.map((lang) {
            final isSelected = langProvider.currentLanguage == lang['lang'];
            return _LanguageChip(
              flag: lang['flag']!,
              name: lang['name']!,
              isSelected: isSelected,
              onTap: () {
                langProvider.switchLanguage(lang['lang']!);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _GlowingButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final bool isLoading;

  const _GlowingButton({
    required this.onPressed,
    required this.child,
    this.isLoading = false,
  });

  @override
  State<_GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<_GlowingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.electricBlue
                    .withValues(alpha: 0.5 * _glowAnimation.value),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.electricBlue,
              foregroundColor: AppTheme.deepSpaceBlue,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation(AppTheme.deepSpaceBlue),
                    ),
                  )
                : widget.child,
          ),
        );
      },
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String flag;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.flag,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? AppTheme.accentGradient
              : const LinearGradient(
                  colors: [
                    AppTheme.glassBackground,
                    AppTheme.glassBackground,
                  ],
                ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppTheme.electricBlue : AppTheme.glassBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.electricBlue.withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: AppTheme.pureWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoParticlesPainter extends CustomPainter {
  final Animation<double> animation;

  _LogoParticlesPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 8; i++) {
      final x = center.dx + radius * 0.8 * (i / 8) * (i.isEven ? 1 : -1) * 0.5;
      final y = center.dy + radius * 0.8 * (i / 8) * (i.isEven ? -1 : 1) * 0.5;

      final paint = Paint()
        ..color = AppTheme.pureWhite.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  @override
  bool shouldRepaint(_LogoParticlesPainter oldDelegate) => true;
}
