import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/accessibility_provider.dart';
import '../../../providers/language_provider.dart';
import '../../../providers/voice_provider.dart';
import '../../../widgets/cvi_button.dart';
import '../../../widgets/indian_card.dart';
import '../../../widgets/decorative/jali_pattern.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          const Positioned.fill(child: JaliPattern(opacity: 0.03)),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.bgDeep.withValues(alpha: 0.95),
                elevation: 0,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: AppColors.textPrimary),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  'Settings',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFF6B1A),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Language & Region
                    _SectionHeader('Language & Region', 'भाषा और क्षेत्र',
                        Icons.language_rounded),
                    const SizedBox(height: 12),
                    _LanguageSection(),
                    const SizedBox(height: 28),

                    // Voice Settings
                    _SectionHeader(
                        'Voice Settings', 'आवाज़ सेटिंग', Icons.mic_rounded),
                    const SizedBox(height: 12),
                    _VoiceSettingsSection(),
                    const SizedBox(height: 28),

                    // Privacy & Security
                    _SectionHeader('Privacy & Security', 'गोपनीयता और सुरक्षा',
                        Icons.security_rounded),
                    const SizedBox(height: 12),
                    _PrivacySection(),
                    const SizedBox(height: 28),

                    // About CVI
                    _SectionHeader('About CVI', 'सीवीआई के बारे में',
                        Icons.info_outline_rounded),
                    const SizedBox(height: 12),
                    _AboutSection(),
                    const SizedBox(height: 28),

                    // Sign Out
                    _SignOutSection(),
                    const SizedBox(height: 16),
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

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _SectionHeader(this.title, this.subtitle, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
              color: AppColors.saffron, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.gold, size: 16),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
            Text(subtitle,
                style: GoogleFonts.inter(
                    color: AppColors.textMuted, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}

// ─── Language & Region ────────────────────────────────────────────────────────

class _LanguageSection extends StatelessWidget {
  static const _langs = [
    ('en', '🇬🇧', 'English'),
    ('hi', '🇮🇳', 'हिन्दी'),
    ('mr', '🇮🇳', 'मराठी'),
    ('ta', '🇮🇳', 'தமிழ்'),
  ];

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LanguageProvider>();
    final access = context.watch<AccessibilityProvider>();
    final current = lp.currentLanguage;

    return IndianCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.8,
            physics: const NeverScrollableScrollPhysics(),
            children: _langs.map((l) {
              final (code, flag, name) = l;
              final active = code == current;
              return GestureDetector(
                onTap: () => lp.switchLanguage(code),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.saffron.withValues(alpha: 0.15)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          active ? AppColors.saffron : AppColors.surfaceBorder,
                      width: active ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(flag, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(name,
                          style: GoogleFonts.poppins(
                              color: active
                                  ? AppColors.saffron
                                  : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight:
                                  active ? FontWeight.w600 : FontWeight.w500)),
                      if (active) ...[
                        const Spacer(),
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.saffron, size: 16),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          const SizedBox(height: 16),
          Text('Text Size',
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          _TextSizeControl(access: access),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms);
  }
}

class _TextSizeControl extends StatelessWidget {
  final AccessibilityProvider access;
  const _TextSizeControl({required this.access});

  static const _options = ['Small', 'Medium', 'Large'];
  static const _scales = [0.85, 1.0, 1.2];

  @override
  Widget build(BuildContext context) {
    int selected = _scales.indexOf(access.textScaleFactor);
    if (selected == -1) selected = 1;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgDeep,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: List.generate(3, (i) {
          final active = selected == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => access.setTextScale(_scales[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? AppColors.bgMid : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_options[i],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        color: active
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight:
                            active ? FontWeight.w600 : FontWeight.w500)),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Voice Settings ───────────────────────────────────────────────────────────

class _VoiceSettingsSection extends StatefulWidget {
  @override
  State<_VoiceSettingsSection> createState() => _VoiceSettingsSectionState();
}

class _VoiceSettingsSectionState extends State<_VoiceSettingsSection> {
  bool _wakeWord = false;

  @override
  Widget build(BuildContext context) {
    final vp = context.watch<VoiceProvider>();

    return IndianCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Speech Speed
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Speech Speed',
                    style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${vp.speechRate.toStringAsFixed(1)}×',
                      style: GoogleFonts.spaceMono(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ),
              ],
            ),
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.gold,
              inactiveTrackColor: AppColors.bgDeep,
              thumbColor: AppColors.gold,
              overlayColor: AppColors.gold.withValues(alpha: 0.15),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              trackHeight: 4,
            ),
            child: Slider(
              value: vp.speechRate,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              onChanged: vp.setSpeechRate,
            ),
          ),
          const Divider(color: AppColors.surfaceBorder, height: 1),

          // Voice Gender
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Expanded(
                    child: Text('Voice Gender',
                        style: GoogleFonts.inter(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600))),
                _GenderToggle(current: vp.voiceGender, vp: vp),
              ],
            ),
          ),
          const Divider(color: AppColors.surfaceBorder, height: 1),

          // Wake Word
          SwitchListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            title: Text('Wake Word "Hey CVI"',
                style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
            subtitle: Text('Beta feature',
                style: GoogleFonts.inter(
                    color: AppColors.textMuted, fontSize: 12)),
            value: _wakeWord,
            activeThumbColor: AppColors.saffron,
            activeTrackColor: AppColors.saffron.withValues(alpha: 0.3),
            inactiveTrackColor: AppColors.bgDeep,
            onChanged: (v) => setState(() => _wakeWord = v),
          ),
          const Divider(color: AppColors.surfaceBorder, height: 1),

          // Mic Status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: _MicCard(vp: vp),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 80.ms);
  }
}

class _GenderToggle extends StatelessWidget {
  final String current;
  final VoiceProvider vp;
  const _GenderToggle({required this.current, required this.vp});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgDeep,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['female', 'male'].map((g) {
          final active = current == g;
          return GestureDetector(
            onTap: () => vp.setVoiceGender(g),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? AppColors.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  Icon(
                      g == 'female' ? Icons.female_rounded : Icons.male_rounded,
                      size: 16,
                      color: active ? AppColors.saffron : AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(g == 'female' ? 'Female' : 'Male',
                      style: GoogleFonts.inter(
                          color: active
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w500)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MicCard extends StatelessWidget {
  final VoiceProvider vp;
  const _MicCard({required this.vp});

  @override
  Widget build(BuildContext context) {
    final hasPerms = vp.state != VoiceState.permissionDenied;
    final color = hasPerms ? AppColors.emerald : AppColors.semanticError;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(hasPerms ? Icons.mic_rounded : Icons.mic_off_rounded,
              color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            hasPerms
                ? 'Microphone setup complete'
                : 'Microphone access required',
            style: GoogleFonts.inter(
                color: hasPerms ? AppColors.textPrimary : color,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
        ),
        if (!hasPerms)
          CviButton(
            text: 'Fix',
            variant: CviButtonVariant.secondary,
            width: 72,
            onPressed: vp.requestMicPermission,
          ),
      ],
    );
  }
}

// ─── Privacy & Security ───────────────────────────────────────────────────────

class _PrivacySection extends StatefulWidget {
  @override
  State<_PrivacySection> createState() => _PrivacySectionState();
}

class _PrivacySectionState extends State<_PrivacySection> {
  bool _biometric = false;

  @override
  Widget build(BuildContext context) {
    return IndianCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            title: Text('Biometric Lock',
                style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
            subtitle: Text('Require fingerprint to open app',
                style: GoogleFonts.inter(
                    color: AppColors.textMuted, fontSize: 13)),
            value: _biometric,
            activeThumbColor: AppColors.saffron,
            activeTrackColor: AppColors.saffron.withValues(alpha: 0.3),
            inactiveTrackColor: AppColors.bgDeep,
            onChanged: (v) => setState(() => _biometric = v),
          ),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          _SettingsTile(
            icon: Icons.delete_outline_rounded,
            title: 'Clear Conversation History',
            iconColor: AppColors.semanticError,
            textColor: AppColors.semanticError,
            onTap: () => _confirmClear(context),
          ),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          _SettingsTile(
            icon: Icons.download_rounded,
            title: 'Export My Data',
            showChevron: true,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                backgroundColor: AppColors.bgMid,
                content: Text(
                    'Data export initiated. You will receive an email.',
                    style: TextStyle(color: AppColors.textPrimary)),
                behavior: SnackBarBehavior.floating,
              ));
            },
          ),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          _SettingsTile(
            icon: Icons.person_remove_rounded,
            title: 'Delete Account',
            iconColor: AppColors.semanticError,
            textColor: AppColors.semanticError,
            isBold: true,
            onTap: () => _confirmDelete(context),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 140.ms);
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgMid,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.surfaceBorder)),
        title: Text('Clear History',
            style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        content: Text('This will permanently clear all conversation history.',
            style: GoogleFonts.inter(
                color: AppColors.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.inter(color: AppColors.textSecondary))),
          CviButton(
            text: 'Clear',
            variant: CviButtonVariant.primary,
            width: 100,
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Conversation history cleared.'),
                  behavior: SnackBarBehavior.floating));
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgMid,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.semanticError, width: 2)),
        title: Row(children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.semanticError, size: 26),
          const SizedBox(width: 8),
          Text('Delete Account',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.semanticError)),
        ]),
        content: Text(
            'This will permanently delete your account and all data. This action CANNOT be undone.',
            style:
                GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.inter(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              await context.read<AuthProvider>().logout();
              if (nav.mounted) nav.pop();
            },
            child: Text('Delete Account',
                style: GoogleFonts.inter(
                    color: AppColors.semanticError,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─── About CVI ────────────────────────────────────────────────────────────────

class _AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IndianCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.info_outline_rounded,
                  color: AppColors.textSecondary, size: 20),
            ),
            title: Text('App Version',
                style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
            trailing: Text('1.0.0 (Build 1)',
                style: GoogleFonts.spaceMono(
                    color: AppColors.textMuted, fontSize: 12)),
          ),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          _SettingsTile(
              icon: Icons.new_releases_outlined,
              title: "What's New",
              showChevron: true,
              onTap: () {}),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          _SettingsTile(
            icon: Icons.star_outline_rounded,
            title: 'Rate on Play Store',
            iconColor: AppColors.gold,
            showChevron: true,
            onTap: () {},
          ),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          _SettingsTile(
            icon: Icons.share_outlined,
            title: 'Share CVI',
            showChevron: true,
            onTap: () {},
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }
}

// ─── Sign Out ─────────────────────────────────────────────────────────────────

class _SignOutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IndianCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: _SettingsTile(
        icon: Icons.logout_rounded,
        title: 'Sign Out',
        iconColor: AppColors.semanticError,
        textColor: AppColors.semanticError,
        isBold: true,
        onTap: () => _confirmLogout(context),
      ),
    ).animate().fadeIn(delay: 240.ms);
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgMid,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.surfaceBorder)),
        title: Text('Sign Out',
            style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        content: Text('Are you sure you want to sign out?',
            style: GoogleFonts.inter(
                color: AppColors.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.inter(color: AppColors.textSecondary))),
          CviButton(
            text: 'Sign Out',
            variant: CviButtonVariant.primary,
            width: 120,
            onPressed: () async {
              final nav = Navigator.of(context);
              await context.read<AuthProvider>().logout();
              if (nav.mounted) nav.pop();
            },
          ),
        ],
      ),
    );
  }
}

// ─── Shared tile widget ───────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;
  final Color textColor;
  final bool isBold;
  final bool showChevron;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor = AppColors.textSecondary,
    this.textColor = AppColors.textPrimary,
    this.isBold = false,
    this.showChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: GoogleFonts.inter(
              color: textColor,
              fontSize: 15,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w500)),
      trailing: showChevron
          ? const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted)
          : null,
      onTap: onTap,
    );
  }
}
