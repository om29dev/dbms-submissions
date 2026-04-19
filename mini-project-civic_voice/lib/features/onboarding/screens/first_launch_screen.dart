import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/language_provider.dart';
import '../../../providers/services_provider.dart';
import '../../../widgets/particle_background.dart';
import '../../../widgets/t_text.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// FIRST LAUNCH ONBOARDING SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class FirstLaunchScreen extends StatefulWidget {
  const FirstLaunchScreen({super.key});

  @override
  State<FirstLaunchScreen> createState() => _FirstLaunchScreenState();
}

class _FirstLaunchScreenState extends State<FirstLaunchScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn);
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cvi_onboarded', true);
    if (!mounted) return;
    // Keep the in-memory seenOnboard cache in sync so the router redirect
    // doesn't need a full cold-start to pick up the new value.
    context.read<AuthProvider>().markOnboarded();
    context.go(Routes.auth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          // Ambient Particle Background
          const Positioned.fill(
            child: ParticleBackground(),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageCtrl,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildStep1(),
                      _buildStep2(),
                      _buildStep3(),
                    ],
                  ),
                ),
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── BOTTOM CONTROLS ────────────────────────────────────────────────────────

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Indicator Dots
          Row(
            children: List.generate(
              3,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 8),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.saffron
                      : AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          // Next / Get Started Button
          GestureDetector(
            onTap: _nextPage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.saffron, AppColors.gold],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.saffron.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  TText(
                    _currentPage == 2 ? 'Get Started' : 'Next',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 20),
                ],
              ),
            ),
          ).animate(target: _currentPage == 2 ? 1 : 0).scale(duration: 200.ms),
        ],
      ),
    );
  }

  // ─── STEP 1: VOICE FIRST ────────────────────────────────────────────────────

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Mic
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.saffron.withValues(alpha: 0.1),
              border: Border.all(
                  color: AppColors.saffron.withValues(alpha: 0.3), width: 2),
              boxShadow: [
                BoxShadow(
                    color: AppColors.saffron.withValues(alpha: 0.2),
                    blurRadius: 40),
              ],
            ),
            child: const Center(
              child:
                  Icon(Icons.mic_rounded, size: 56, color: AppColors.saffron),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
              begin: const Offset(1, 1),
              end: const Offset(1.1, 1.1),
              duration: 2.seconds),
          const SizedBox(height: 48),

          const TText(
            'Voice-First for Bharat',
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.saffron,
                height: 1.1),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          const SizedBox(height: 16),

          const TText(
            'Just speak naturally in your language. CVI understands you instantly.',
            style: TextStyle(
                fontSize: 16, color: AppColors.textSecondary, height: 1.5),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 48),

          // Language Selector
          const TText(
            'SELECT LANGUAGE',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                letterSpacing: 2),
          ).animate().fadeIn(delay: 600.ms),
          const SizedBox(height: 16),

          Consumer<LanguageProvider>(
            builder: (context, lang, child) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _LangChip('English', 'en', lang.languageCode == 'en',
                      () => lang.setLanguageByCode('en')),
                  _LangChip('हिंदी', 'hi', lang.languageCode == 'hi',
                      () => lang.setLanguageByCode('hi')),
                  _LangChip('मराठी', 'mr', lang.languageCode == 'mr',
                      () => lang.setLanguageByCode('mr')),
                  _LangChip('தமிழ்', 'ta', lang.languageCode == 'ta',
                      () => lang.setLanguageByCode('ta')),
                ],
              );
            },
          ).animate().fadeIn(delay: 800.ms),
        ],
      ),
    );
  }

  // ─── STEP 2: SERVICES GRID ──────────────────────────────────────────────────

  Widget _buildStep2() {
    final services =
        context.watch<ServicesProvider>().allServices.take(6).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 240,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: services.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgMid,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.accentBlue.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.accentBlue.withValues(alpha: 0.1),
                          blurRadius: 10),
                    ],
                  ),
                  child: Center(
                    child: Text(services[index].iconEmoji,
                        style: const TextStyle(fontSize: 32)),
                  ),
                )
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: 200 + index * 100))
                    .scale();
              },
            ),
          ),
          const SizedBox(height: 24),
          const TText(
            '16 Govt Services',
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.accentBlue,
                height: 1.1),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
          const SizedBox(height: 16),
          const TText(
            'Aadhaar, PAN, Passport, Certificates and more — all in one place.',
            style: TextStyle(
                fontSize: 16, color: AppColors.textSecondary, height: 1.5),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 1000.ms),
        ],
      ),
    );
  }

  // ─── STEP 3: PRIVACY & SECURITY ─────────────────────────────────────────────

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.emerald.withValues(alpha: 0.1),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.2, 1.2),
                  duration: 2.seconds),
              const Icon(Icons.shield_rounded,
                      size: 80, color: AppColors.emerald)
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .scale(curve: Curves.elasticOut, duration: 800.ms),
              Positioned(
                top: 20,
                right: 10,
                child: const Icon(Icons.check_circle_rounded,
                        color: Colors.white, size: 24)
                    .animate()
                    .fadeIn(delay: 800.ms)
                    .scale(),
              ),
            ],
          ),
          const SizedBox(height: 48),
          const TText(
            'Your Data Stays Safe',
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.emeraldLight,
                height: 1.1),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2),
          const SizedBox(height: 16),
          const TText(
            'End-to-end encrypted. No data is shared with third parties without your explicit consent.',
            style: TextStyle(
                fontSize: 16, color: AppColors.textSecondary, height: 1.5),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 1200.ms),
        ],
      ),
    );
  }
}

// ─── WIDGETS ────────────────────────────────────────────────────────────────

class _LangChip extends StatelessWidget {
  final String label;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangChip(this.label, this.code, this.isSelected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.saffron.withValues(alpha: 0.2)
              : AppColors.bgMid,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.saffron : AppColors.surfaceBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppColors.saffron.withValues(alpha: 0.2),
                      blurRadius: 8)
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.saffron : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
