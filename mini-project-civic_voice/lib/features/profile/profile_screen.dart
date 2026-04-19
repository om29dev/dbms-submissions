import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../models/citizen_profile_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/citizen_profile_provider.dart';
import '../../widgets/indian_card.dart';
import '../../widgets/cvi_button.dart';
import '../../widgets/decorative/jali_pattern.dart';

// ═════════════════════════════════════════════════════════════════════════════
// PROFILE SCREEN  — Cloud-synced citizen identity card
// ═════════════════════════════════════════════════════════════════════════════

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger a cloud fetch on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CitizenProfileProvider>();
      if (provider.profile == null && !provider.isLoading) {
        provider.fetchProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<CitizenProfileProvider>();
    final auth = context.watch<AuthProvider>();
    final profile = profileProvider.profile;
    final isLoading = profileProvider.isLoading;
    final isGuest = auth.isGuest;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          const Positioned.fill(child: JaliPattern(opacity: 0.03)),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── App Bar ──────────────────────────────────────────────────
              SliverAppBar(
                backgroundColor: AppColors.bgDeep.withValues(alpha: 0.9),
                elevation: 0,
                pinned: true,
                centerTitle: true,
                title: Text(
                  'My Profile',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFF6B1A),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined,
                        color: AppColors.textSecondary, size: 24),
                    tooltip: 'Settings',
                    onPressed: () => context.push(Routes.settings),
                  ),
                  const SizedBox(width: 4),
                ],
              ),

              if (isLoading && profile == null)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.saffron),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Hero Header ─────────────────────────────────────
                      _ProfileHero(
                        profile: profile,
                        isGuest: isGuest,
                        onEditTap: () => context.push(Routes.profileEdit),
                      ),
                      const SizedBox(height: 20),

                      // ── Completion Banner ────────────────────────────────
                      if (profile != null && profile.isProfileIncomplete)
                        _CompletionBanner(
                          percent: profile.profileCompletionPercent,
                          onTap: () => context.push(Routes.profileEdit),
                        ),
                      if (profile != null && profile.isProfileIncomplete)
                        const SizedBox(height: 20),

                      // ── Quick Actions ────────────────────────────────────
                      _QuickActions(),
                      const SizedBox(height: 28),

                      // ── Personal Details ─────────────────────────────────
                      if (profile != null) ...[
                        _CardSectionHeader(
                            'Personal Details', Icons.person_outline_rounded),
                        const SizedBox(height: 12),
                        _PersonalCard(profile: profile),
                        const SizedBox(height: 20),

                        // ── Location ───────────────────────────────────────
                        _CardSectionHeader(
                            'Location', Icons.location_on_outlined),
                        const SizedBox(height: 12),
                        _LocationCard(profile: profile),
                        const SizedBox(height: 20),

                        // ── Financial & Social ─────────────────────────────
                        _CardSectionHeader(
                            'Financial & Social', Icons.currency_rupee_rounded),
                        const SizedBox(height: 12),
                        _FinancialCard(profile: profile),
                        const SizedBox(height: 20),

                        // ── Document IDs ───────────────────────────────────
                        _CardSectionHeader(
                            'Government Documents', Icons.credit_card_rounded),
                        const SizedBox(height: 12),
                        _DocumentsCard(profile: profile),
                        const SizedBox(height: 20),

                        // ── Disability (conditional) ───────────────────────
                        if (profile.isDisabled) ...[
                          _CardSectionHeader(
                              'Disability Info', Icons.accessible_rounded),
                          const SizedBox(height: 12),
                          _DisabilityCard(profile: profile),
                          const SizedBox(height: 20),
                        ],
                      ],

                      // ── Guest CTA ────────────────────────────────────────
                      if (isGuest) ...[
                        _GuestCta(),
                        const SizedBox(height: 20),
                      ],
                    ]),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// HERO HEADER
// ═════════════════════════════════════════════════════════════════════════════

class _ProfileHero extends StatelessWidget {
  final CitizenProfileModel? profile;
  final bool isGuest;
  final VoidCallback onEditTap;

  const _ProfileHero({
    required this.profile,
    required this.isGuest,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = profile?.fullName ?? 'Guest User';
    final email = profile?.email ?? '';
    final mobile = profile?.mobile ?? '';
    final pct = profile?.profileCompletionPercent ?? 0;
    final initials = name.trim().isNotEmpty
        ? name
            .trim()
            .split(' ')
            .where((p) => p.isNotEmpty)
            .take(2)
            .map((p) => p[0].toUpperCase())
            .join()
        : 'G';

    return IndianCard(
      isPremium: true,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar + completion ring
          Stack(
            alignment: Alignment.center,
            children: [
              // Completion ring
              SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: _RingPainter(percent: pct / 100),
                ),
              ),
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B1A), Color(0xFFE8510A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: const Color(0xFFD4930A), width: 2),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x66FF6B1A),
                        blurRadius: 20,
                        spreadRadius: 2),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // Edit badge
              if (!isGuest)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: GestureDetector(
                    onTap: onEditTap,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.bgDeep,
                        border: Border.all(color: AppColors.gold, width: 1.5),
                      ),
                      child: const Icon(Icons.edit_rounded,
                          color: AppColors.gold, size: 14),
                    ),
                  ),
                ),
            ],
          ).animate().scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.elasticOut),
          const SizedBox(height: 16),

          // Name
          Text(name,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),

          // Contact chips
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              if (mobile.isNotEmpty) _contactChip(Icons.phone, mobile),
              if (email.isNotEmpty) _contactChip(Icons.email, email),
            ],
          ),
          const SizedBox(height: 12),

          // Completion bar text
          if (!isGuest)
            Text(
              '$pct% profile complete',
              style: GoogleFonts.spaceMono(
                  color: pct >= 70 ? AppColors.emerald : AppColors.saffron,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),

          // Verified badges
          if (!isGuest && profile != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                if (mobile.isNotEmpty)
                  _badge('Mobile Verified', AppColors.emerald),
                if (email.isNotEmpty)
                  _badge('Email Verified', AppColors.emerald),
                if (profile!.isKycVerified)
                  _badge('KYC Verified', AppColors.gold),
              ],
            ),
          ],

          if (isGuest) ...[
            const SizedBox(height: 16),
            CviButton(
              text: 'Create Account',
              variant: CviButtonVariant.gold,
              onPressed: () => context.go(Routes.auth),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.06, end: 0);
  }

  Widget _contactChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 5),
          Text(label,
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, color: color, size: 13),
          const SizedBox(width: 5),
          Text(label,
              style: GoogleFonts.inter(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── Ring Painter ─────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double percent;
  const _RingPainter({required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final stroke = 4.0;

    final bgPaint = Paint()
      ..color = AppColors.surfaceBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    final fgPaint = Paint()
      ..color = percent >= 0.7 ? AppColors.emerald : AppColors.saffron
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * percent,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.percent != percent;
}

// ═════════════════════════════════════════════════════════════════════════════
// COMPLETION BANNER
// ═════════════════════════════════════════════════════════════════════════════

class _CompletionBanner extends StatelessWidget {
  final int percent;
  final VoidCallback onTap;
  const _CompletionBanner({required this.percent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IndianCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.saffron.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.info_outline_rounded,
                color: AppColors.saffron, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Complete your profile',
                    style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                Text(
                  'Only $percent% done. A complete profile helps you find the right schemes.',
                  style: GoogleFonts.inter(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.saffron,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Fill',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.05, end: 0);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// QUICK ACTIONS
// ═════════════════════════════════════════════════════════════════════════════

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            emoji: '✏️',
            label: 'Edit Profile',
            onTap: () => context.push(Routes.profileEdit),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionTile(
            emoji: '⚙️',
            label: 'Settings',
            onTap: () => context.push(Routes.settings),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionTile(
            emoji: '📋',
            label: 'My Applications',
            onTap: () => context.push(Routes.myApplications),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 150.ms);
  }
}

class _ActionTile extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;
  const _ActionTile(
      {required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IndianCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SECTION HEADER
// ═════════════════════════════════════════════════════════════════════════════

class _CardSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _CardSectionHeader(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
              color: AppColors.saffron, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, color: AppColors.gold, size: 15),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15)),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// DETAILS CARDS
// ═════════════════════════════════════════════════════════════════════════════

class _PersonalCard extends StatelessWidget {
  final CitizenProfileModel profile;
  const _PersonalCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final age = profile.computedAge;
    return IndianCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _row('Full Name', profile.fullName, Icons.person_outline_rounded),
          if (profile.dateOfBirth != null) ...[
            _divider(),
            _row(
              'Date of Birth',
              '${profile.dateOfBirth!.day}/${profile.dateOfBirth!.month}/${profile.dateOfBirth!.year}',
              Icons.cake_outlined,
            ),
            _divider(),
            _row('Age', '$age years', Icons.timelapse_rounded),
          ],
          if (profile.gender != null) ...[
            _divider(),
            _row('Gender', profile.gender!, Icons.wc_rounded),
          ],
          if (profile.maritalStatus != null) ...[
            _divider(),
            _row('Marital Status', profile.maritalStatus!,
                Icons.favorite_border_rounded),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }
}

class _LocationCard extends StatelessWidget {
  final CitizenProfileModel profile;
  const _LocationCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return IndianCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (profile.state.isNotEmpty && profile.state != 'Not Set')
            _row('State / UT', profile.state, Icons.map_outlined),
          if (profile.district != null) ...[
            _divider(),
            _row('District', profile.district!, Icons.location_city_outlined),
          ],
          if (profile.pincode != null) ...[
            _divider(),
            _row('Pincode', profile.pincode!, Icons.pin_drop_outlined),
          ],
          if (profile.state.isEmpty || profile.state == 'Not Set')
            _emptyState('Location not set'),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms);
  }
}

class _FinancialCard extends StatelessWidget {
  final CitizenProfileModel profile;
  const _FinancialCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final hasData = profile.occupation != null ||
        profile.annualIncomeRange != null ||
        profile.casteCategory != null;

    return IndianCard(
      padding: const EdgeInsets.all(20),
      child: hasData
          ? Column(
              children: [
                if (profile.occupation != null)
                  _row('Occupation', profile.occupation!,
                      Icons.work_outline_rounded),
                if (profile.annualIncomeRange != null) ...[
                  _divider(),
                  _row('Annual Income', profile.annualIncomeRange!,
                      Icons.currency_rupee_rounded),
                ],
                if (profile.casteCategory != null) ...[
                  _divider(),
                  _row('Caste Category', profile.casteCategory!,
                      Icons.groups_outlined),
                ],
              ],
            )
          : _emptyState('Financial details not set'),
    ).animate().fadeIn(delay: 200.ms);
  }
}

class _DocumentsCard extends StatelessWidget {
  final CitizenProfileModel profile;
  const _DocumentsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final hasData = profile.aadhaarLastFour != null ||
        profile.panMasked != null ||
        profile.rationCardNumber != null;

    return IndianCard(
      padding: const EdgeInsets.all(20),
      child: hasData
          ? Column(
              children: [
                if (profile.aadhaarLastFour != null)
                  _row('Aadhaar', 'XXXX XXXX ${profile.aadhaarLastFour}',
                      Icons.fingerprint_rounded),
                if (profile.panMasked != null) ...[
                  _divider(),
                  _row('PAN', profile.panMasked!, Icons.credit_card_rounded),
                ],
                if (profile.rationCardNumber != null) ...[
                  _divider(),
                  _row('Ration Card', profile.rationCardNumber!,
                      Icons.article_outlined),
                ],
              ],
            )
          : _emptyState('No documents linked'),
    ).animate().fadeIn(delay: 250.ms);
  }
}

class _DisabilityCard extends StatelessWidget {
  final CitizenProfileModel profile;
  const _DisabilityCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return IndianCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _row('PwD Status', 'Registered', Icons.accessible_rounded,
              valueColor: AppColors.saffron),
          if (profile.disabilityType != null) ...[
            _divider(),
            _row('Disability Type', profile.disabilityType!,
                Icons.medical_information_outlined),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
}

// ─── Guest CTA ────────────────────────────────────────────────────────────────

class _GuestCta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IndianCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.person_add_outlined,
              color: AppColors.saffron, size: 40),
          const SizedBox(height: 12),
          Text('Sign in to access your profile',
              style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Your demographic details help us show you relevant schemes.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 18),
          CviButton(
            text: 'Create Account',
            variant: CviButtonVariant.gold,
            onPressed: () => context.go(Routes.auth),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

Widget _row(String label, String value, IconData icon, {Color? valueColor}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 18, color: AppColors.textMuted),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value,
                style: GoogleFonts.inter(
                    color: valueColor ?? AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    ],
  );
}

Widget _divider() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 12),
    child: Divider(color: AppColors.surfaceBorder, height: 1));

Widget _emptyState(String message) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.add_circle_outline_rounded,
              color: AppColors.textMuted, size: 18),
          const SizedBox(width: 10),
          Text(message,
              style:
                  GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13)),
        ],
      ),
    );
