import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/neon_button.dart';
import '../../widgets/particle_background.dart';

// ═════════════════════════════════════════════════════════════════════════════
// ROOT SCREEN
// ═════════════════════════════════════════════════════════════════════════════

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ParticleBackground(
        child: Column(
          children: [
            // ── Header logo area ──────────────────────────────────────────
            const SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: _AuthHeader(),
              ),
            ),

            // ── Glass card panel ──────────────────────────────────────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0x14FFFFFF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border(
                    top: BorderSide(color: Color(0x1A00F5FF), width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    // Drag handle
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Tab bar
                    _AnimatedTabBar(controller: _tabCtrl),

                    // Tab content
                    Expanded(
                      child: TabBarView(
                        controller: _tabCtrl,
                        children: const [_LoginTab(), _RegisterTab()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _AuthHeader extends StatelessWidget {
  const _AuthHeader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glow icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(Icons.record_voice_over_rounded,
                color: AppColors.accent, size: 28),
          ).animate().fadeIn(duration: 500.ms).scale(
              begin: const Offset(0.8, 0.8),
              duration: 600.ms,
              curve: Curves.elasticOut),
          const SizedBox(height: 12),
          const Text(
            'CIVIC VOICE',
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 4,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          const Text(
            'Your gateway to government services',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

// ─── Animated Tab Bar ────────────────────────────────────────────────────────

class _AnimatedTabBar extends StatelessWidget {
  final TabController controller;
  const _AnimatedTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: TabBar(
          controller: controller,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 12,
                spreadRadius: -4,
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          tabs: const [Tab(text: 'Login'), Tab(text: 'Register')],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// LOGIN TAB
// ═════════════════════════════════════════════════════════════════════════════

class _LoginTab extends StatefulWidget {
  const _LoginTab();

  @override
  State<_LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<_LoginTab> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _passVisible = false;
  bool _showOTP = false;
  bool _otpSent = false;
  final List<TextEditingController> _otpCtrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  final _mobileCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _mobileCtrl.dispose();
    for (final c in _otpCtrls) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) {
      _shake();
      return;
    }
    final auth = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>(); // Cache before await

    final success =
        await auth.loginWithEmail(_emailCtrl.text.trim(), _passCtrl.text);

    if (success && auth.userId != null) {
      userProvider.fetchUserProfile(auth.userId!);
    }

    if (!mounted) return;

    // Do NOT call context.go() here — AuthProvider.notifyListeners() already
    // triggers the GoRouter redirect which navigates away automatically.
    // Calling context.go() on top causes a double-navigation that crashes
    // with '_elements.contains(element) is not true'.
    if (!success && auth.error != null) {
      _showError(auth.error!);
    }
  }

  Future<void> _loginGoogle() async {
    final auth = context.read<AuthProvider>();
    await auth.loginWithGoogle();
    if (!mounted) return;
    if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _sendOTP() async {
    final mobile = _mobileCtrl.text.trim();
    if (mobile.length != 10) {
      _showError('Enter a valid 10-digit mobile number.');
      return;
    }
    // Mock: always succeeds for now; replace with auth.sendOTP('+91$mobile')
    setState(() => _otpSent = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OTP sent to +91 $mobile (mock: use any 6 digits)'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Future.delayed(50.ms, () {
      if (mounted) _otpFocusNodes[0].requestFocus();
    });
  }

  Future<void> _verifyOTP() async {
    final otp = _otpCtrls.map((c) => c.text).join();
    if (otp.length < 6) {
      _showError('Enter all 6 OTP digits.');
      return;
    }
    // Mock: Any 6-digit OTP creates/logs in as guest for demo
    await context.read<AuthProvider>().continueAsGuest();
    // Navigation handled automatically by GoRouter redirect via notifyListeners()
  }

  void _shake() {
    // Trigger red shimmer error — handled by Form validators
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showForgotDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.backgroundLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Password',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'Rajdhani',
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email and we\'ll send a reset link.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _NeonTextField(
              controller: ctrl,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reset link sent to ${ctrl.text}'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Send Link',
                style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Google button ────────────────────────────────────────
            _GoogleButton(onTap: _loginGoogle, isLoading: auth.isLoading),

            const SizedBox(height: 20),
            const _Divider(label: '— or login with email —'),
            const SizedBox(height: 16),

            // ── Email ────────────────────────────────────────────────
            _NeonTextField(
              controller: _emailCtrl,
              label: 'Email address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!isValidEmail(v)) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // ── Password ─────────────────────────────────────────────
            _NeonTextField(
              controller: _passCtrl,
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              obscure: !_passVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _passVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () => setState(() => _passVisible = !_passVisible),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                return null;
              },
            ),

            // ── Forgot password ───────────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showForgotDialog,
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 13,
                      fontFamily: 'Rajdhani'),
                ),
              ),
            ),

            // ── Login Button ──────────────────────────────────────────
            NeonButton(
              label: 'Login',
              icon: Icons.login_rounded,
              isLoading: auth.isLoading,
              onTap: auth.isLoading ? null : _loginWithEmail,
            ),

            const SizedBox(height: 20),
            const _Divider(label: '— or use mobile OTP —'),
            const SizedBox(height: 12),

            // ── OTP Section ───────────────────────────────────────────
            _OTPSection(
              showOTP: _showOTP,
              otpSent: _otpSent,
              mobileCtrl: _mobileCtrl,
              otpCtrls: _otpCtrls,
              otpFocusNodes: _otpFocusNodes,
              onToggle: () => setState(() {
                _showOTP = !_showOTP;
                if (!_showOTP) {
                  _otpSent = false;
                  _mobileCtrl.clear();
                  for (final c in _otpCtrls) {
                    c.clear();
                  }
                }
              }),
              onSendOTP: _sendOTP,
              onVerifyOTP: _verifyOTP,
              isLoading: auth.isLoading,
            ),

            const SizedBox(height: 24),

            // ── Guest ─────────────────────────────────────────────────
            _GuestSection(
              onGuest: () async {
                await context.read<AuthProvider>().continueAsGuest();
                // Navigation handled automatically by GoRouter redirect via notifyListeners()
              },
              isLoading: auth.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Google Button ────────────────────────────────────────────────────────────

class _GoogleButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;
  const _GoogleButton({required this.onTap, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: isLoading ? null : onTap,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      backgroundColor: Colors.white.withValues(alpha: 0.06),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Google G icon via colored text
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              children: [
                TextSpan(text: 'G', style: TextStyle(color: Color(0xFF4285F4))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Continue with Google',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Rajdhani',
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── OTP Section ─────────────────────────────────────────────────────────────

class _OTPSection extends StatelessWidget {
  final bool showOTP;
  final bool otpSent;
  final TextEditingController mobileCtrl;
  final List<TextEditingController> otpCtrls;
  final List<FocusNode> otpFocusNodes;
  final VoidCallback onToggle;
  final VoidCallback onSendOTP;
  final VoidCallback onVerifyOTP;
  final bool isLoading;

  const _OTPSection({
    required this.showOTP,
    required this.otpSent,
    required this.mobileCtrl,
    required this.otpCtrls,
    required this.otpFocusNodes,
    required this.onToggle,
    required this.onSendOTP,
    required this.onVerifyOTP,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Toggle button
        TextButton.icon(
          onPressed: onToggle,
          icon: Icon(
            showOTP ? Icons.keyboard_arrow_up : Icons.phone_android_rounded,
            color: AppColors.accent,
            size: 18,
          ),
          label: Text(
            showOTP ? 'Hide OTP Login' : 'Login with Mobile OTP',
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 14,
              fontFamily: 'Rajdhani',
              fontWeight: FontWeight.w600,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),

        // Expandable OTP region
        AnimatedSize(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          child: showOTP
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    // Mobile field
                    _NeonTextField(
                      controller: mobileCtrl,
                      label: 'Mobile Number',
                      icon: Icons.phone_android_rounded,
                      keyboardType: TextInputType.phone,
                      prefixText: '+91 ',
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 12),
                    if (!otpSent)
                      NeonButton(
                        label: 'Send OTP',
                        icon: Icons.send_rounded,
                        height: 46,
                        isLoading: isLoading,
                        onTap: onSendOTP,
                      ),

                    // OTP boxes
                    if (otpSent) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Enter 6-digit OTP',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontFamily: 'Rajdhani'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      _OTPBoxes(
                          controllers: otpCtrls, focusNodes: otpFocusNodes),
                      const SizedBox(height: 16),
                      NeonButton(
                        label: 'Verify OTP',
                        icon: Icons.verified_outlined,
                        height: 46,
                        isLoading: isLoading,
                        onTap: onVerifyOTP,
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ─── 6-box OTP Input ──────────────────────────────────────────────────────────

class _OTPBoxes extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;

  const _OTPBoxes({required this.controllers, required this.focusNodes});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        return SizedBox(
          width: 44,
          height: 52,
          child: TextField(
            controller: controllers[i],
            focusNode: focusNodes[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'SpaceMono',
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppColors.surface.withValues(alpha: 0.6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.accent, width: 1.5),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (val) {
              if (val.isNotEmpty && i < 5) {
                focusNodes[i + 1].requestFocus();
              } else if (val.isEmpty && i > 0) {
                focusNodes[i - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }
}

// ─── Guest Section ────────────────────────────────────────────────────────────

class _GuestSection extends StatelessWidget {
  final VoidCallback onGuest;
  final bool isLoading;
  const _GuestSection({required this.onGuest, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: AppColors.border, thickness: 1),
        const SizedBox(height: 12),
        NeonButton.outlined(
          label: 'Continue as Guest  →',
          icon: Icons.person_outline_rounded,
          onTap: isLoading ? null : onGuest,
          height: 48,
        ),
        const SizedBox(height: 8),
        const Text(
          'Limited features · No data saved',
          style: TextStyle(
              color: AppColors.textDisabled, fontSize: 11, letterSpacing: 0.3),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// REGISTER TAB
// ═════════════════════════════════════════════════════════════════════════════

class _RegisterTab extends StatefulWidget {
  const _RegisterTab();

  @override
  State<_RegisterTab> createState() => _RegisterTabState();
}

class _RegisterTabState extends State<_RegisterTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _passVisible = false;
  bool _confirmVisible = false;
  String _selectedLang = 'en';
  IndianState? _selectedState;

  @override
  void initState() {
    super.initState();
    // Mirror LanguageProvider selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _selectedLang = context.read<LanguageProvider>().currentLanguage;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      // Shake the form
      return;
    }
    final auth = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>(); // Cache before await

    final success = await auth.signup(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passCtrl.text,
      phone: _mobileCtrl.text.trim(),
      language: _selectedLang,
    );

    if (success && auth.userId != null) {
      userProvider.login(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _mobileCtrl.text.trim(),
      );
      // Also try fetching if there's a DB trigger that creates the profile
      userProvider.fetchUserProfile(auth.userId!);
    }

    if (!mounted) return;

    if (success) {
      // Navigation handled automatically by GoRouter redirect via notifyListeners()
      // Do NOT call context.go() — causes double-navigation crash.
    } else {
      if (auth.error == 'CONFIRM_SIGNUP_REQUIRED') {
        _showOTPVerificationDialog(
            _emailCtrl.text.trim(), _passCtrl.text, auth, userProvider);
      } else if (auth.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.error!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _showOTPVerificationDialog(String email, String password,
      AuthProvider auth, UserProvider userProvider) {
    final otpCtrl = TextEditingController();
    bool isVerifying = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.backgroundLight,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Verify Email',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'Rajdhani',
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'We sent a verification code to your email. Please enter it below:',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                _NeonTextField(
                  controller: otpCtrl,
                  label: 'Verification Code',
                  icon: Icons.password_rounded,
                  keyboardType: TextInputType.number,
                ),
                if (isVerifying) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(color: AppColors.accent),
                ]
              ],
            ),
            actions: [
              TextButton(
                onPressed:
                    isVerifying ? null : () => Navigator.pop(dialogContext),
                child: const Text('Cancel',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              TextButton(
                onPressed: isVerifying
                    ? null
                    : () async {
                        final code = otpCtrl.text.trim();
                        if (code.isEmpty) return;

                        setDialogState(() => isVerifying = true);

                        final success = await auth.confirmSignUp(email, code);

                        if (!mounted) return;

                        if (success) {
                          // Dismiss dialog safely BEFORE triggering any router redirects
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }

                          // Auto login
                          final loginSuccess =
                              await auth.loginWithEmail(email, password);

                          if (loginSuccess && auth.userId != null) {
                            userProvider.fetchUserProfile(auth.userId!);
                          }

                          if (!mounted) return;

                          if (loginSuccess) {
                            // Navigation handled automatically by GoRouter redirect via notifyListeners()
                            // Do NOT call context.go() — causes double-navigation crash.
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Verified! Please log in.'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              // Switch to login tab
                              // ignore: use_build_context_synchronously
                              context
                                  .findAncestorStateOfType<_AuthScreenState>()
                                  ?.setState(() {});
                            }
                          }
                        } else {
                          setDialogState(() => isVerifying = false);
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content:
                                    Text(auth.error ?? 'Verification failed'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                child: const Text('Verify & Login',
                    style: TextStyle(color: AppColors.accent)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Full Name
            _NeonTextField(
              controller: _nameCtrl,
              label: 'Full Name',
              icon: Icons.person_outline_rounded,
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 14),

            // Email
            _NeonTextField(
              controller: _emailCtrl,
              label: 'Email address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!isValidEmail(v)) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Mobile
            _NeonTextField(
              controller: _mobileCtrl,
              label: 'Mobile Number',
              icon: Icons.phone_android_rounded,
              prefixText: '+91 ',
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Mobile number is required';
                if (!isValidIndianPhone(v) && v.length != 10) {
                  return 'Enter a valid 10-digit number';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Password
            _NeonTextField(
              controller: _passCtrl,
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              obscure: !_passVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _passVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () => setState(() => _passVisible = !_passVisible),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Confirm Password
            _NeonTextField(
              controller: _confirmPassCtrl,
              label: 'Confirm Password',
              icon: Icons.lock_outline_rounded,
              obscure: !_confirmVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _confirmVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _confirmVisible = !_confirmVisible),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Please confirm your password';
                }
                if (v != _passCtrl.text) return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Language
            const Text(
              'Preferred Language',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontFamily: 'Rajdhani',
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            _LangChipSelector(
              selected: _selectedLang,
              onChanged: (l) {
                setState(() => _selectedLang = l);
                context.read<LanguageProvider>().switchLanguage(l);
              },
            ),
            const SizedBox(height: 20),

            // State dropdown
            _StateDropdown(
              selected: _selectedState,
              onChanged: (s) => setState(() => _selectedState = s),
            ),
            const SizedBox(height: 24),

            // Register button
            NeonButton(
              label: 'Create Account',
              icon: Icons.app_registration_rounded,
              isLoading: auth.isLoading,
              onTap: auth.isLoading ? null : _register,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Language chip selector ───────────────────────────────────────────────────

class _LangChipSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  static const _langs = [
    ('en', '🇬🇧', 'EN'),
    ('hi', '🇮🇳', 'HI'),
    ('mr', '🇮🇳', 'MR'),
    ('ta', '🇮🇳', 'TA'),
  ];

  const _LangChipSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _langs.map((l) {
        final (code, flag, label) = l;
        final isSelected = selected == code;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(code),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(flag, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Rajdhani',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── State Dropdown ───────────────────────────────────────────────────────────

class _StateDropdown extends StatelessWidget {
  final IndianState? selected;
  final ValueChanged<IndianState?> onChanged;

  const _StateDropdown({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<IndianState>(
          value: selected,
          hint: const Text(
            'Select your state / UT',
            style: TextStyle(color: AppColors.textDisabled, fontSize: 14),
          ),
          isExpanded: true,
          dropdownColor: AppColors.backgroundLight,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary),
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontFamily: 'Rajdhani'),
          items: IndianState.values.map((s) {
            return DropdownMenuItem<IndianState>(
              value: s,
              child: Text(
                s.label,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SHARED COMPONENTS
// ═════════════════════════════════════════════════════════════════════════════

/// Neon-glow text field that animates its border on focus.
class _NeonTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final String? prefixText;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  const _NeonTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
    this.suffixIcon,
    this.validator,
    this.prefixText,
    this.maxLength,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<_NeonTextField> createState() => _NeonTextFieldState();
}

class _NeonTextFieldState extends State<_NeonTextField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _glowAnim = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeOut);
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!mounted) return;
    if (_focusNode.hasFocus) {
      _glowCtrl.forward();
    } else {
      _glowCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _glowCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.15 * _glowAnim.value),
              blurRadius: 12 * _glowAnim.value,
              spreadRadius: -2,
            ),
          ],
        ),
        child: child,
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscure,
        maxLength: widget.maxLength,
        inputFormatters: widget.inputFormatters,
        textCapitalization: widget.textCapitalization,
        style: const TextStyle(
            color: AppColors.textPrimary, fontSize: 15, fontFamily: 'Rajdhani'),
        validator: widget.validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: const TextStyle(
              color: AppColors.textSecondary, fontFamily: 'Rajdhani'),
          counterText: '',
          prefixIcon: Icon(widget.icon, color: AppColors.accent, size: 20),
          prefixText: widget.prefixText,
          prefixStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'SpaceMono',
              fontSize: 13),
          suffixIcon: widget.suffixIcon,
          filled: true,
          fillColor: AppColors.surface.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          errorStyle: const TextStyle(color: AppColors.error, fontSize: 11),
        ),
      ),
    );
  }
}

// ─── Divider with label ───────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  final String label;
  const _Divider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: const TextStyle(
                color: AppColors.textDisabled,
                fontSize: 11,
                letterSpacing: 0.3),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }
}
