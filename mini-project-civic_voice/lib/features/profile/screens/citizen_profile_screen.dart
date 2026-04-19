import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/notification_service.dart';
import 'package:amplify_flutter/amplify_flutter.dart' hide UserProfile;
import 'package:image_picker/image_picker.dart';
import '../../../widgets/glass/glass_card.dart';
import '../../../widgets/animated/particle_background.dart';
import '../../../providers/language_provider.dart';
import '../../../core/constants/app_language.dart';
import 'user_onboarding_screen.dart';
import 'personal_information_screen.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/accessibility_provider.dart';
import 'notes_screen.dart';
import 'family_dashboard_screen.dart';
import '../../services/screens/virtual_queue_screen.dart';
import '../../gamification/screens/gamification_screen.dart';
import '../../community/screens/community_verification_screen.dart';
import '../../services/screens/emergency_screen.dart';
import '../../documents/screens/ar_guidance_screen.dart';

class CitizenProfileScreen extends StatefulWidget {
  const CitizenProfileScreen({super.key});

  @override
  State<CitizenProfileScreen> createState() => _CitizenProfileScreenState();
}

class _CitizenProfileScreenState extends State<CitizenProfileScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.deepSpaceBlue,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.pureWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          Provider.of<LanguageProvider>(context).translate('profile'),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.pureWhite,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppTheme.electricBlue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UserOnboardingScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: ParticleBackground(
              numberOfParticles: 40,
              particleColor: AppTheme.electricBlue,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profile Header
                  _buildProfileHeader(user),
                  const SizedBox(height: 32),

                  // Demographic Info (If complete)
                  if (user.isProfileComplete) ...[
                    _buildSection(langProvider.translate('demographic_info'), [
                      _buildInfoItem(Icons.cake, langProvider.translate('age'),
                          '${user.age} ${langProvider.languageCode == 'hi' ? 'वर्ष' : 'years'}'),
                      _buildInfoItem(
                          Icons.currency_rupee,
                          langProvider.translate('annual_income'),
                          '₹${user.annualIncome?.toStringAsFixed(0)}'),
                      _buildInfoItem(
                          Icons.work,
                          langProvider.translate('occupation'),
                          user.occupation ?? 'Not specified'),
                      _buildInfoItem(
                          Icons.location_on,
                          langProvider.translate('location'),
                          user.location ?? 'Not specified'),
                      _buildInfoItem(
                          Icons.landscape,
                          langProvider.translate('land_ownership'),
                          user.ownsLand ? 'Yes' : 'No'),
                    ]),
                    const SizedBox(height: 24),
                  ] else ...[
                    _buildIncompleteProfileBanner(context),
                    const SizedBox(height: 24),
                  ],

                  // Stats Cards
                  _buildStatsRow(user),
                  const SizedBox(height: 32),

                  // Settings Section
                  _buildSection(langProvider.translate('account_settings'), [
                    _buildMenuItem(
                        Icons.person, langProvider.translate('personal_info'),
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const PersonalInformationScreen()),
                      );
                    }),
                    _buildMenuItem(Icons.security,
                        langProvider.translate('security_privacy'), () {
                      _showChangePasswordDialog(context);
                    }),
                    _buildMenuItem(Icons.notifications,
                        langProvider.translate('notifications'), () async {
                      await NotificationService().showTestNotification();
                    },
                        trailing: Switch(
                          value: _notificationsEnabled,
                          onChanged: (value) =>
                              setState(() => _notificationsEnabled = value),
                          activeThumbColor: AppTheme.electricBlue,
                        )),
                    _buildMenuItem(
                        Icons.mic, langProvider.translate('voice_notes'), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NotesScreen()),
                      );
                    }),
                    _buildMenuItem(
                        Icons.people, langProvider.translate('family_members'),
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const FamilyDashboardScreen()),
                      );
                    }),
                    _buildMenuItem(Icons.confirmation_number,
                        langProvider.translate('smart_queue'), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const VirtualQueueScreen()),
                      );
                    }),
                    _buildMenuItem(Icons.emoji_events,
                        langProvider.translate('civic_progress'), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GamificationScreen()),
                      );
                    }),
                    _buildMenuItem(Icons.verified,
                        langProvider.translate('community_trust'), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const CommunityVerificationScreen()),
                      );
                    }),
                    _buildMenuItem(Icons.sos, 'Emergency Mode (Feature 6)', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EmergencyScreen()),
                      );
                    },
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: AppTheme.error, size: 16)),
                    _buildMenuItem(
                        Icons.view_in_ar, 'AR Document Guidance (F12)',
                        () async {
                      final ImagePicker picker = ImagePicker();
                      try {
                        final XFile? photo =
                            await picker.pickImage(source: ImageSource.camera);
                        if (photo != null && context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ARGuidanceScreen(imagePath: photo.path)),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Error accessing camera: $e')),
                          );
                        }
                      }
                    }),
                  ]),
                  const SizedBox(height: 24),

                  // Preferences Section
                  _buildSection(langProvider.translate('preferences'), [
                    _buildLanguageMenuItem(context, langProvider),
                    _buildMenuItem(Icons.dark_mode,
                        langProvider.translate('dark_mode'), () {},
                        trailing: Switch(
                          value: _darkModeEnabled,
                          onChanged: (value) =>
                              setState(() => _darkModeEnabled = value),
                          activeThumbColor: AppTheme.electricBlue,
                        )),
                  ]),
                  const SizedBox(height: 24),

                  // Accessibility Section (Feature 11)
                  Consumer<AccessibilityProvider>(
                    builder: (context, acc, _) => _buildSection(
                        langProvider.translate('accessibility_feature'), [
                      _buildMenuItem(Icons.contrast,
                          langProvider.translate('high_contrast'), () {},
                          trailing: Switch(
                            value: acc.isHighContrast,
                            onChanged: (value) => acc.toggleHighContrast(value),
                            activeThumbColor: AppTheme.electricBlue,
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${langProvider.translate('text_size')}: ${(acc.textScaleFactor * 100).toInt()}%',
                              style:
                                  GoogleFonts.inter(color: AppTheme.pureWhite),
                            ),
                            Slider(
                              value: acc.textScaleFactor,
                              min: 0.8,
                              max: 1.5,
                              divisions: 7,
                              activeColor: AppTheme.electricBlue,
                              inactiveColor: AppTheme.glassBorder,
                              onChanged: (val) => acc.setTextScale(val),
                            ),
                          ],
                        ),
                      ),
                      _buildMenuItem(Icons.palette,
                          langProvider.translate('color_blindness'), () {
                        _showColorBlindDialog(context, acc);
                      },
                          trailing: Text(
                            acc.colorBlindMode
                                .toString()
                                .split('.')
                                .last
                                .toUpperCase(),
                            style: GoogleFonts.inter(
                                color: AppTheme.neonCyan, fontSize: 12),
                          )),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // Support Section
                  _buildSection(langProvider.translate('support'), [
                    _buildMenuItem(
                        Icons.help, langProvider.translate('help_faq'), () {}),
                    _buildMenuItem(Icons.feedback,
                        langProvider.translate('send_feedback'), () {}),
                    _buildMenuItem(
                        Icons.info, langProvider.translate('about_cvi'), () {}),
                  ]),
                  const SizedBox(height: 32),

                  // Logout Button
                  _buildLogoutButton(context, userProvider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile user) {
    return GlassCard(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.electricBlue.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.glassBackground,
              child: Text(
                user.name
                    .substring(0, user.name.contains(' ') ? 2 : 1)
                    .toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.electricBlue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.pureWhite,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.pureWhite.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          if (user.phone.isNotEmpty) ...[
            Text(
              user.phone,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.pureWhite.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (user.isVerified ? AppTheme.success : AppTheme.warning)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  user.isVerified
                      ? Icons.verified
                      : Icons.warning_amber_rounded,
                  size: 16,
                  color: user.isVerified ? AppTheme.success : AppTheme.warning,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    user.isVerified ? 'Verified User' : 'Unverified Account',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          user.isVerified ? AppTheme.success : AppTheme.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncompleteProfileBanner(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return GlassCard(
      gradientColors: [
        AppTheme.warning.withValues(alpha: 0.1),
        AppTheme.warning.withValues(alpha: 0.05)
      ],
      child: Column(
        children: [
          const Icon(Icons.info_outline, color: AppTheme.warning, size: 32),
          const SizedBox(height: 12),
          Text(
            lang.translate('incomplete_profile'),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.pureWhite,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            lang.translate('add_details_prompt'),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.pureWhite.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UserOnboardingScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warning,
              foregroundColor: AppTheme.deepSpaceBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(lang.translate('complete_profile')),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(UserProfile user) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
              '${user.applicationsCount}', 'Applications', Icons.assignment),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
              '${user.completedCount}', 'Completed', Icons.check_circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              _buildStatCard('${user.pendingCount}', 'Pending', Icons.pending),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.electricBlue, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.pureWhite,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppTheme.pureWhite.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.pureWhite.withValues(alpha: 0.7),
            ),
          ),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap,
      {Widget? trailing}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.electricBlue, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppTheme.pureWhite,
                  ),
                ),
              ),
              trailing ??
                  const Icon(Icons.chevron_right, color: AppTheme.pureWhite),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.neonCyan, size: 20),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.pureWhite.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.pureWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageMenuItem(
      BuildContext context, LanguageProvider langProvider) {
    return _buildMenuItem(
      Icons.language,
      langProvider.translate('language'),
      () => _showLanguageDialog(context, langProvider),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            langProvider.languageName,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.neonCyan,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppTheme.pureWhite),
        ],
      ),
    );
  }

  void _showLanguageDialog(
      BuildContext context, LanguageProvider langProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.deepSpaceBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          langProvider.translate('select_language'),
          style: GoogleFonts.poppins(color: AppTheme.pureWhite),
        ),
        content: RadioGroup<AppLanguage>(
          groupValue: AppLanguage.fromCode(langProvider.currentCode),
          onChanged: (value) {
            if (value != null) {
              langProvider.setLanguageByCode(value.code);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppLanguage.values.map((lang) {
              return RadioListTile<AppLanguage>(
                title: Text(
                  _getLanguageName(lang),
                  style: GoogleFonts.inter(color: AppTheme.pureWhite),
                ),
                value: lang,
                activeColor: AppTheme.electricBlue,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  String _getLanguageName(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.hindi:
        return 'हिन्दी (Hindi)';
      case AppLanguage.marathi:
        return 'मराठी (Marathi)';
      case AppLanguage.tamil:
        return 'தமிழ் (Tamil)';
    }
  }

  Widget _buildLogoutButton(BuildContext context, UserProvider userProvider) {
    final lang = Provider.of<LanguageProvider>(context);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          userProvider.logout();
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        },
        icon: const Icon(Icons.logout, size: 20),
        label: Text(
          lang.translate('logout'),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.error,
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: AppTheme.error, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _showColorBlindDialog(BuildContext context, AccessibilityProvider acc) {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.deepSpaceBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          lang.translate('select_filter'),
          style: GoogleFonts.poppins(color: AppTheme.pureWhite),
        ),
        content: RadioGroup<ColorBlindMode>(
          groupValue: acc.colorBlindMode,
          onChanged: (val) {
            if (val != null) {
              acc.setColorBlindMode(val);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ColorBlindMode.values.map((mode) {
              final name = mode.toString().split('.').last.toUpperCase();
              return RadioListTile<ColorBlindMode>(
                title: Text(
                  name == 'NONE' ? 'None (Normal Vision)' : name,
                  style: GoogleFonts.inter(color: AppTheme.pureWhite),
                ),
                value: mode,
                activeColor: AppTheme.electricBlue,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.deepSpaceBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          langProvider.translate('change_password'),
          style: GoogleFonts.poppins(color: AppTheme.pureWhite),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                style: const TextStyle(color: AppTheme.pureWhite),
                decoration: InputDecoration(
                  labelText: langProvider.translate('current_password'),
                  labelStyle: TextStyle(
                      color: AppTheme.pureWhite.withValues(alpha: 0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.glassBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.electricBlue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                style: const TextStyle(color: AppTheme.pureWhite),
                decoration: InputDecoration(
                  labelText: langProvider.translate('new_password'),
                  labelStyle: TextStyle(
                      color: AppTheme.pureWhite.withValues(alpha: 0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.glassBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.electricBlue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: AppTheme.pureWhite),
                decoration: InputDecoration(
                  labelText: langProvider.translate('confirm_password'),
                  labelStyle: TextStyle(
                      color: AppTheme.pureWhite.withValues(alpha: 0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.glassBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.electricBlue),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(langProvider.translate('cancel'),
                style: const TextStyle(color: AppTheme.pureWhite)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.electricBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text(langProvider.translate('passwords_mismatch'))),
                );
                return;
              }
              try {
                await Amplify.Auth.updatePassword(
                  oldPassword: currentPasswordController.text,
                  newPassword: newPasswordController.text,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text(langProvider.translate('password_changed'))),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('${langProvider.translate('error')}: $e')),
                  );
                }
              }
            },
            child: Text(langProvider.translate('save'),
                style: const TextStyle(color: AppTheme.deepSpaceBlue)),
          ),
        ],
      ),
    );
  }
}
