import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../providers/language_provider.dart';
import '../../widgets/neon_button.dart';
import '../../widgets/particle_background.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  static const int _totalPages = 3;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cvi_onboarded', true);
    if (mounted) context.go(Routes.auth);
  }

  void _next() {
    if (_currentPage < _totalPages - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _totalPages - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ParticleBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar: skip button ────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Page counter
                    Text(
                      '0${_currentPage + 1} / 0$_totalPages',
                      style: const TextStyle(
                        color: AppColors.textDisabled,
                        fontFamily: 'SpaceMono',
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    if (!isLast)
                      TextButton(
                        onPressed: _finish,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontFamily: 'Rajdhani',
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Slides ─────────────────────────────────────────────────
              Expanded(
                child: PageView(
                  controller: _pageCtrl,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: const [
                    _Slide1(),
                    _Slide2(),
                    _Slide3(),
                  ],
                ),
              ),

              // ── Bottom: dots + nav ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                child: Row(
                  children: [
                    // Dot indicators
                    Row(
                      children: List.generate(_totalPages, (i) {
                        final active = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 8),
                          width: active ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.accent
                                : Colors.transparent,
                            border: Border.all(
                              color: active
                                  ? AppColors.accent
                                  : AppColors.border,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const Spacer(),
                    // Next / Get Started button
                    _NextButton(isLast: isLast, onTap: _next),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Next Button ─────────────────────────────────────────────────────────────

class _NextButton extends StatelessWidget {
  final bool isLast;
  final VoidCallback onTap;
  const _NextButton({required this.isLast, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isLast
          ? SizedBox(
              key: const ValueKey('getstarted'),
              width: 160,
              child: NeonButton(
                label: 'Get Started',
                icon: Icons.arrow_forward_rounded,
                height: 48,
                onTap: onTap,
              ),
            )
          : GestureDetector(
              key: const ValueKey('next'),
              onTap: onTap,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 20),
              ),
            ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SLIDE 1 — "Speak, Don't Search"
// ═════════════════════════════════════════════════════════════════════════════

class _Slide1 extends StatefulWidget {
  const _Slide1();

  @override
  State<_Slide1> createState() => _Slide1State();
}

class _Slide1State extends State<_Slide1> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Mic + waveform rings ─────────────────────────────────────
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 3 staggered expanding rings
                ...List.generate(3, (i) {
                  return _WaveRing(
                    controller: _pulse,
                    delay: i * 0.22,
                    maxRadius: 70.0 + i * 20,
                  );
                }),
                // Mic button
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, __) {
                    final scale = 1.0 + _pulse.value * 0.08;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent
                                  .withValues(alpha: 0.4 + _pulse.value * 0.2),
                              blurRadius: 24 + _pulse.value * 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.mic_rounded,
                            color: Colors.white, size: 36),
                      ),
                    );
                  },
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(begin: const Offset(0.8, 0.8), duration: 600.ms,
                  curve: Curves.elasticOut),

          const SizedBox(height: 40),

          // ── Title ───────────────────────────────────────────────────
          const Text(
            "Speak, Don't Search",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.3, end: 0, delay: 200.ms, duration: 400.ms,
                  curve: Curves.easeOut),

          const SizedBox(height: 16),

          // ── Body ────────────────────────────────────────────────────
          const Text(
            'Just ask. CVI understands you in\nyour language.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.65,
            ),
          )
              .animate()
              .fadeIn(delay: 350.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

// Ring that expands outward from a centre
class _WaveRing extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  final double maxRadius;

  const _WaveRing({
    required this.controller,
    required this.delay,
    required this.maxRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final raw = ((controller.value + delay) % 1.0);
        final radius = maxRadius * raw;
        final opacity = (1.0 - raw) * 0.55;
        return Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.accent.withValues(alpha: opacity),
              width: 1.5,
            ),
          ),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SLIDE 2 — "8 Services. Zero Confusion."
// ═════════════════════════════════════════════════════════════════════════════

class _Slide2 extends StatefulWidget {
  const _Slide2();

  @override
  State<_Slide2> createState() => _Slide2State();
}

class _Slide2State extends State<_Slide2> with SingleTickerProviderStateMixin {
  late final AnimationController _orbit;

  @override
  void initState() {
    super.initState();
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _orbit.dispose();
    super.dispose();
  }

  static const _icons = [
    ('🪪', 'Aadhaar'),
    ('💳', 'PAN'),
    ('📘', 'Passport'),
    ('🚗', 'DL'),
    ('🗺️', 'Land'),
    ('👶', 'Birth'),
    ('🌾', 'Ration'),
    ('👴', 'Pension'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Orbit animation ─────────────────────────────────────────
          SizedBox(
            width: 240,
            height: 240,
            child: AnimatedBuilder(
              animation: _orbit,
              builder: (_, __) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Orbit ring guide
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                    ),

                    // 8 orbiting service icons
                    ..._icons.asMap().entries.map((e) {
                      final index  = e.key;
                      final item   = e.value;
                      final angle  =
                          _orbit.value * 2 * pi +
                          (index / _icons.length) * 2 * pi;
                      const orbitR = 100.0;
                      final x = orbitR * cos(angle);
                      final y = orbitR * sin(angle);

                      return Transform.translate(
                        offset: Offset(x, y),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface,
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.35),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.12),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(item.$1,
                                style: const TextStyle(fontSize: 18)),
                          ),
                        ),
                      );
                    }),

                    // Central hub
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.8),
                            AppColors.accent.withValues(alpha: 0.6)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.35),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🏛️', style: TextStyle(fontSize: 32)),
                      ),
                    ),
                  ],
                );
              },
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.85, 0.85), duration: 600.ms,
                  curve: Curves.easeOutBack),

          const SizedBox(height: 36),

          const Text(
            '8 Services. Zero Confusion.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          )
              .animate()
              .fadeIn(delay: 250.ms, duration: 400.ms)
              .slideY(begin: 0.3, end: 0, delay: 250.ms),

          const SizedBox(height: 16),

          const Text(
            'Aadhaar to Pension —\nguidance at your fingertips.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.65,
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SLIDE 3 — "Your Language. Your India."
// ═════════════════════════════════════════════════════════════════════════════

class _Slide3 extends StatefulWidget {
  const _Slide3();

  @override
  State<_Slide3> createState() => _Slide3State();
}

class _Slide3State extends State<_Slide3> with SingleTickerProviderStateMixin {
  late final AnimationController _cycleCtrl;

  static const _greetings = ['नमस्ते', 'வணக்கம்', 'नमस्कार', 'Hello'];
  static const _langs = [
    _LangChip(code: 'en', flag: '🇬🇧', label: 'English'),
    _LangChip(code: 'hi', flag: '🇮🇳', label: 'हिन्दी'),
    _LangChip(code: 'mr', flag: '🇮🇳', label: 'मराठी'),
    _LangChip(code: 'ta', flag: '🇮🇳', label: 'தமிழ்'),
  ];

  int _greetIdx = 0;

  @override
  void initState() {
    super.initState();
    _cycleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _startCycle();
  }

  Future<void> _startCycle() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 1600));
      if (!mounted) break;
      _cycleCtrl.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) break;
      setState(() => _greetIdx = (_greetIdx + 1) % _greetings.length);
    }
  }

  @override
  void dispose() {
    _cycleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Animated greeting ──────────────────────────────────────
          SizedBox(
            height: 110,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                    CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                  ),
                  child: child,
                ),
              ),
              child: Column(
                key: ValueKey(_greetIdx),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _greetings[_greetIdx],
                    style: const TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                      shadows: [
                        Shadow(
                          color: AppColors.accent,
                          blurRadius: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms),

          const SizedBox(height: 8),

          // ── Title ──────────────────────────────────────────────────
          const Text(
            'Your Language. Your India.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.3, end: 0, delay: 200.ms),

          const SizedBox(height: 12),

          const Text(
            'CVI speaks your language.\nChoose one to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.65,
            ),
          ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

          const SizedBox(height: 32),

          // ── Language chip selector ─────────────────────────────────
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: _langs.map((lc) {
              final selected = langProvider.currentLanguage == lc.code;
              return _LanguageChip(
                chip: lc,
                isSelected: selected,
                onTap: () => langProvider.switchLanguage(lc.code),
              );
            }).toList(),
          )
              .animate()
              .fadeIn(delay: 500.ms, duration: 400.ms)
              .slideY(begin: 0.3, end: 0, delay: 500.ms),
        ],
      ),
    );
  }
}

// ─── Language chip data ────────────────────────────────────────────────────

class _LangChip {
  final String code;
  final String flag;
  final String label;
  const _LangChip({required this.code, required this.flag, required this.label});
}

class _LanguageChip extends StatelessWidget {
  final _LangChip chip;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.chip,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.25),
                    blurRadius: 12,
                    spreadRadius: -2,
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(chip.flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              chip.label,
              style: TextStyle(
                color:
                    isSelected ? AppColors.accent : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                fontFamily: 'Rajdhani',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
