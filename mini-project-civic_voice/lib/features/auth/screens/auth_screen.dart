import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:civic_voice_interface/core/constants/app_colors.dart';
import 'package:civic_voice_interface/providers/language_provider.dart';
import 'package:civic_voice_interface/core/theme/app_theme.dart';
import 'package:civic_voice_interface/widgets/t_text.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  void _handlePhoneSubmit() async {
    setState(() => _isLoading = true);
    // Simulation of premium OTP flow
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Animated Particle Background (Simulation via CustomPainter)
          const Positioned.fill(child: _ParticleBackground()),

          // 2. Animated Gradient Mesh (Blur Background)
          const _MeshGradient(),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 3. Glowing Civic Emblem (Hero)
                  FadeInDown(
                    duration: const Duration(seconds: 1),
                    child: _buildGlowingLogo(),
                  ),
                  const SizedBox(height: 50),

                  // 4. Staggered Glassmorphism Card
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: _buildAuthCard(),
                  ),

                  const SizedBox(height: 40),

                  // 5. Language Selector (Premium Animated Flags)
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    child: const _PremiumLanguageSelector(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowingLogo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.5),
            blurRadius: 40,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(
        Icons.account_balance_rounded,
        size: 80,
        color: AppColors.white,
      ),
    );
  }

  Widget _buildAuthCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TText(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 8),
              const TText(
                'Enter your mobile number to continue',
                style: TextStyle(
                  color: Color(0x99FFFFFF),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),
              _buildModernTextField(
                controller: _phoneController,
                hint: 'Phone Number',
                icon: Icons.phone_iphone_rounded,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handlePhoneSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 15,
                    shadowColor: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.background)
                      : const TText(
                          'GET OTP',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, letterSpacing: 2),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.05),
        ),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppColors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.white.withValues(alpha: 0.3)),
          prefixIcon:
              Icon(icon, color: AppColors.primary.withValues(alpha: 0.7)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }
}

class _MeshGradient extends StatelessWidget {
  const _MeshGradient();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -100,
          child: _BlurredBlob(
              color: AppColors.primary.withValues(alpha: 0.2), size: 400),
        ),
        Positioned(
          bottom: -150,
          right: -100,
          child: _BlurredBlob(
              color: AppTheme.gradientEnd.withValues(alpha: 0.2), size: 500),
        ),
      ],
    );
  }
}

class _BlurredBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _BlurredBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

class _ParticleBackground extends StatefulWidget {
  const _ParticleBackground();

  @override
  State<_ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<_ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
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
        return CustomPaint(
          painter: _ParticlePainter(_controller.value),
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.white.withValues(alpha: 0.1);
    for (int i = 0; i < 50; i++) {
      double x = (i * 137.5) % size.width;
      double y = (i * 137.5 + progress * 500) % size.height;
      canvas.drawCircle(Offset(x, y), 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _PremiumLanguageSelector extends StatelessWidget {
  const _PremiumLanguageSelector();

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    return Wrap(
      spacing: 15,
      children: [
        _LangToggle(
            code: 'EN',
            name: 'English',
            isSelected: langProvider.currentLanguage == 'en'),
        _LangToggle(
            code: 'HI',
            name: 'हिन्दी',
            isSelected: langProvider.currentLanguage == 'hi'),
        _LangToggle(
            code: 'MR',
            name: 'मराठी',
            isSelected: langProvider.currentLanguage == 'mr'),
        _LangToggle(
            code: 'TA',
            name: 'தமிழ்',
            isSelected: langProvider.currentLanguage == 'ta'),
      ],
    );
  }
}

class _LangToggle extends StatelessWidget {
  final String code;
  final String name;
  final bool isSelected;
  const _LangToggle(
      {required this.code, required this.name, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final langProvider =
            Provider.of<LanguageProvider>(context, listen: false);
        String newLang;
        switch (code) {
          case 'HI':
            newLang = 'hi';
            break;
          case 'MR':
            newLang = 'mr';
            break;
          case 'TA':
            newLang = 'ta';
            break;
          case 'EN':
          default:
            newLang = 'en';
            break;
        }
        langProvider.setLanguageByCode(newLang);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : AppColors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          code,
          style: TextStyle(
            color: isSelected ? AppColors.background : AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
