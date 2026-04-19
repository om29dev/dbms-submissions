import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/language_provider.dart';
import '../../../providers/analytics_provider.dart';
import '../../../widgets/particle_background.dart';
import 'package:screenshot/screenshot.dart';
import '../../voice/widgets/form_help_fab.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// COMPLETE PROFILE SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen>
    with AutomaticKeepAliveClientMixin {
  // Mock User Data (in a real app, bind this to UserProvider)
  String _userName = 'Citizen';
  final String _userEmail = 'citizen@digitalindia.gov.in';
  String _userAge = '28';
  final String _userState = 'Maharashtra';
  final String _userDistrict = 'Mumbai';

  bool _notifAppUpdates = true;
  bool _notifGovSchemes = true;
  bool _notifNewServices = false;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          const Positioned.fill(
            child: ParticleBackground(),
          ),
          SafeArea(
            bottom: false,
            child: Screenshot(
              controller: _screenshotController,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    backgroundColor: AppColors.bgDeep.withValues(alpha: 0.9),
                    elevation: 0,
                    pinned: true,
                    title: Text(
                      lang.t('profile_title'),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.saffron,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.settings_rounded,
                            color: AppColors.textSecondary),
                        onPressed: () => context.push(Routes.profile),
                      ),
                    ],
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildProfileHeader(),
                        const SizedBox(height: 32),
                        _buildSectionTitle(lang.t('profile_personal_info')),
                        _buildPersonalInfo(lang),
                        const SizedBox(height: 32),
                        _buildSectionTitle(lang.t('profile_my_services')),
                        _buildMyServices(),
                        const SizedBox(height: 32),
                        _buildSectionTitle(lang.t('profile_language')),
                        _buildLanguageSettings(),
                        const SizedBox(height: 32),
                        _buildSectionTitle(lang.t('profile_notifications')),
                        _buildNotifications(lang),
                        const SizedBox(height: 32),
                        _buildSectionTitle(lang.t('profile_about_support')),
                        _buildSupportLinks(lang),
                        const SizedBox(height: 48),
                        _buildLogoutButton(lang),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FormHelpFab(
        screenshotController: _screenshotController,
        formContext: 'complete profile form',
      ),
    );
  }

  // ─── UTILS ──────────────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.05, end: 0);
  }

  // ─── 1. HEADER ──────────────────────────────────────────────────────────────
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgMid,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.saffron, AppColors.gold],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.saffron.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Center(
                  child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : 'C',
                    style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName,
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userEmail,
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.bgDark,
                    border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text('Civic Score',
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: AppColors.textMuted)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.gold, size: 16),
                          const SizedBox(width: 4),
                          Text('850',
                              style: GoogleFonts.jetBrainsMono(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showEditProfileSheet(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: AppColors.saffron.withValues(alpha: 0.1),
                      border: Border.all(color: AppColors.saffron),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Edit Profile',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.saffron),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  // ─── 2. PERSONAL INFO ───────────────────────────────────────────────────────
  Widget _buildPersonalInfo(LanguageProvider lang) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgMid,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          _buildInfoTile(lang.t('profile_info_name'), _userName,
              Icons.person_outline_rounded),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          _buildInfoTile(lang.t('profile_info_age'), '$_userAge years',
              Icons.cake_outlined),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          _buildInfoTile(
              lang.t('profile_info_state'), _userState, Icons.map_outlined),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          _buildInfoTile(lang.t('profile_info_district'), _userDistrict,
              Icons.location_city_rounded),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 16),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.textSecondary)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  void _showEditProfileSheet() {
    final lang = context.read<LanguageProvider>();
    final nameCtrl = TextEditingController(text: _userName);
    final ageCtrl = TextEditingController(text: _userAge);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.bgDeep,
            border: Border(top: BorderSide(color: AppColors.saffron, width: 2)),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lang.t('profile_edit'),
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 24),
              _buildTextField(lang.t('profile_info_name'), nameCtrl),
              const SizedBox(height: 16),
              _buildTextField(lang.t('profile_info_age'), ageCtrl,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _userName = nameCtrl.text;
                      _userAge = ageCtrl.text;
                    });
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.saffron,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(lang.t('profile_save_changes'),
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl,
      {TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.surfaceBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.saffron, width: 2)),
        filled: true,
        fillColor: AppColors.bgMid,
      ),
    );
  }

  // ─── 3. MY SERVICES ─────────────────────────────────────────────────────────
  Widget _buildMyServices() {
    return Consumer<AnalyticsProvider>(
      builder: (context, analytics, child) {
        final lang = context.read<LanguageProvider>();
        final count = analytics.servicesExploredCount;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accentBlue.withValues(alpha: 0.1),
                AppColors.bgDeep
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: AppColors.accentBlue.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang.t('profile_services_explored'),
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('$count',
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accentBlue)),
                      const SizedBox(width: 8),
                      Text(lang.t('profile_total'),
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(lang.t('profile_view_history'),
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentBlue)),
              )
            ],
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  // ─── 4. LANGUAGE SETTINGS ───────────────────────────────────────────────────
  Widget _buildLanguageSettings() {
    return Consumer<LanguageProvider>(builder: (context, lang, child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lang.isTranslating)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.saffron),
                  ),
                  const SizedBox(width: 10),
                  Text('Translating via Google...',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
          if (lang.translationError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Translation failed — showing English',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.semanticError)),
            ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildLangCard('English', 'en', lang.languageCode == 'en',
                  lang.isTranslating, () => lang.switchLanguage('en')),
              _buildLangCard('हिंदी', 'hi', lang.languageCode == 'hi',
                  lang.isTranslating, () => lang.switchLanguage('hi')),
              _buildLangCard('मराठी', 'mr', lang.languageCode == 'mr',
                  lang.isTranslating, () => lang.switchLanguage('mr')),
              _buildLangCard('தமிழ்', 'ta', lang.languageCode == 'ta',
                  lang.isTranslating, () => lang.switchLanguage('ta')),
            ],
          ),
        ],
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
    });
  }

  Widget _buildLangCard(String label, String code, bool isSelected,
      bool isLoading, VoidCallback onTap) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: (MediaQuery.of(context).size.width - 56) / 2,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.saffron.withValues(alpha: 0.15)
              : AppColors.bgMid,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.saffron : AppColors.surfaceBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppColors.saffron.withValues(alpha: 0.2),
                      blurRadius: 10)
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AppColors.saffron
                  : isLoading
                      ? AppColors.textMuted
                      : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ─── 5. NOTIFICATIONS ───────────────────────────────────────────────────────
  Widget _buildNotifications(LanguageProvider lang) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgMid,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          _buildSwitchTile(lang.t('profile_notif_updates'), _notifAppUpdates,
              (val) => setState(() => _notifAppUpdates = val)),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          _buildSwitchTile(lang.t('profile_notif_schemes'), _notifGovSchemes,
              (val) => setState(() => _notifGovSchemes = val)),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          _buildSwitchTile(lang.t('profile_notif_new'), _notifNewServices,
              (val) => setState(() => _notifNewServices = val)),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSwitchTile(
      String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(label,
          style:
              GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.saffron,
      activeTrackColor: AppColors.saffron.withValues(alpha: 0.3),
      inactiveTrackColor: AppColors.bgDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  // ─── 6. ABOUT & SUPPORT ─────────────────────────────────────────────────────
  Widget _buildSupportLinks(LanguageProvider lang) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgMid,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          _buildLinkTile('App Version', 'v2.0.0 (Bharat Silicon)',
              Icons.info_outline_rounded, null),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          _buildLinkTile(
              lang.t('profile_privacy'), '', Icons.privacy_tip_outlined,
              () async {
            final uri =
                Uri.parse('https://www.digitalindia.gov.in/privacy-policy');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          _buildLinkTile(
              lang.t('profile_report_issue'), '', Icons.bug_report_outlined,
              () async {
            final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: 'support@civicvoice.in',
                queryParameters: {'subject': 'Bug Report — CVI App'});
            if (await canLaunchUrl(emailLaunchUri)) {
              await launchUrl(emailLaunchUri);
            }
          }),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          _buildLinkTile(
              lang.t('profile_rate_app'), '', Icons.star_border_rounded, () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'App store listing coming soon! Thank you for your support 🙏'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildLinkTile(
      String label, String trailing, IconData icon, VoidCallback? onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(label,
          style:
              GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary)),
      trailing: trailing.isNotEmpty
          ? Text(trailing,
              style:
                  GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted))
          : const Icon(Icons.arrow_forward_ios_rounded,
              color: AppColors.textMuted, size: 14),
    );
  }

  // ─── 7. LOGOUT ──────────────────────────────────────────────────────────────
  Widget _buildLogoutButton(LanguageProvider lang) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.logout_rounded, color: AppColors.semanticError),
        label: Text(
          lang.t('profile_sign_out'),
          style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.semanticError),
        ),
        style: OutlinedButton.styleFrom(
          side:
              BorderSide(color: AppColors.semanticError.withValues(alpha: 0.5)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: AppColors.semanticError.withValues(alpha: 0.05),
        ),
        onPressed: () => _showLogoutDialog(lang),
      ),
    ).animate().fadeIn(delay: 700.ms);
  }

  void _showLogoutDialog(LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(lang.t('profile_sign_out'),
            style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        content: Text(lang.t('profile_sign_out_q'),
            style: GoogleFonts.poppins(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(lang.t('cancel'),
                style: GoogleFonts.poppins(
                    color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final auth = context.read<AuthProvider>();
              await auth.logout();
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) context.go(Routes.auth);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.semanticError,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(lang.t('profile_sign_out'),
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
