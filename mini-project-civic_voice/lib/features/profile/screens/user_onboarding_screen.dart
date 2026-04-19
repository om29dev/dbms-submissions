import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/glass/glass_card.dart';
import '../../../widgets/animated/particle_background.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/language_provider.dart';

class UserOnboardingScreen extends StatefulWidget {
  const UserOnboardingScreen({super.key});

  @override
  State<UserOnboardingScreen> createState() => _UserOnboardingScreenState();
}

class _UserOnboardingScreenState extends State<UserOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  int _age = 18;
  double _income = 0;
  String _occupation = 'student';
  String _location = 'urban';
  bool _ownsLand = false;

  final List<String> _occupations = [
    'student',
    'self_employed',
    'farmer',
    'govt_employee',
    'private_sector',
    'retired',
    'unemployed'
  ];

  final List<String> _locations = ['urban', 'semi_urban', 'rural'];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.deepSpaceBlue,
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
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      lang.translate('tell_us_about_yourself'),
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.pureWhite,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lang.translate('personalize_civic_msg'),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.pureWhite.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Age Slider
                    _buildStepTitle(lang.translate('how_old_are_you')),
                    GlassCard(
                      child: Column(
                        children: [
                          Text(
                            '$_age',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.electricBlue,
                            ),
                          ),
                          Slider(
                            value: _age.toDouble(),
                            min: 1,
                            max: 100,
                            divisions: 100,
                            activeColor: AppTheme.electricBlue,
                            inactiveColor:
                                AppTheme.electricBlue.withValues(alpha: 0.2),
                            onChanged: (value) {
                              setState(() => _age = value.toInt());
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Income Slider
                    _buildStepTitle(lang.translate('what_is_your_income')),
                    GlassCard(
                      child: Column(
                        children: [
                          Text(
                            '₹${(_income / 1000).toStringAsFixed(0)}k',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.neonCyan,
                            ),
                          ),
                          Slider(
                            value: _income,
                            min: 0,
                            max: 2000000,
                            divisions: 200,
                            activeColor: AppTheme.neonCyan,
                            inactiveColor:
                                AppTheme.neonCyan.withValues(alpha: 0.2),
                            onChanged: (value) {
                              setState(() => _income = value);
                            },
                          ),
                          Text(
                            lang.translate('slider_increment_note'),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.pureWhite.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Occupation Dropdown
                    _buildStepTitle(lang.translate('what_is_your_occupation')),
                    GlassCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _occupation,
                          isExpanded: true,
                          dropdownColor: AppTheme.deepSpaceBlue,
                          icon: const Icon(Icons.arrow_drop_down,
                              color: AppTheme.electricBlue),
                          style: GoogleFonts.inter(
                              color: AppTheme.pureWhite, fontSize: 16),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _occupation = value);
                            }
                          },
                          items: _occupations.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(lang.translate(value)),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Location
                    _buildStepTitle(lang.translate('where_do_you_live')),
                    Row(
                      children: _locations.map((loc) {
                        final isSelected = _location == loc;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _location = loc),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.electricBlue
                                        .withValues(alpha: 0.3)
                                    : AppTheme.glassBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.electricBlue
                                      : AppTheme.glassBorder,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  lang.translate(loc),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? AppTheme.pureWhite
                                        : AppTheme.pureWhite
                                            .withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Land Ownership
                    GlassCard(
                      child: Row(
                        children: [
                          const Icon(Icons.landscape, color: AppTheme.neonCyan),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang.translate('own_land_q'),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.pureWhite,
                                  ),
                                ),
                                Text(
                                  lang.translate('farmer_scheme_note'),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppTheme.pureWhite
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _ownsLand,
                            onChanged: (value) =>
                                setState(() => _ownsLand = value),
                            activeThumbColor: AppTheme.neonCyan,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          userProvider.updateProfile(
                            age: _age,
                            annualIncome: _income,
                            occupation: _occupation,
                            location: _location,
                            ownsLand: _ownsLand,
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.electricBlue,
                          foregroundColor: AppTheme.deepSpaceBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor:
                              AppTheme.electricBlue.withValues(alpha: 0.5),
                        ),
                        child: Text(
                          lang.translate('save_profile'),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
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

  Widget _buildStepTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.pureWhite,
        ),
      ),
    );
  }
}
