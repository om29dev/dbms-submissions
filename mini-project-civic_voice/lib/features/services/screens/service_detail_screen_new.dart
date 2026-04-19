import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:civic_voice_interface/core/theme/app_theme.dart';
import 'package:civic_voice_interface/widgets/glass/glass_card.dart';
import 'package:civic_voice_interface/widgets/animated/particle_background.dart';
import 'package:civic_voice_interface/providers/language_provider.dart';
import 'package:civic_voice_interface/models/service_model_new.dart';
import 'package:civic_voice_interface/models/scheme_model.dart';
import 'package:civic_voice_interface/providers/user_provider.dart';
import 'package:civic_voice_interface/core/services/scheme_knowledge_base.dart';

class ServiceDetailScreen extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetailScreen({super.key, required this.service});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);
    final user = userProvider.currentUser;
    
    final scheme = SchemeKnowledgeBase.getSchemeById(service.id);
    
    // Check eligibility for service
    bool isEligible = scheme?.isEligible(user) ?? false;
    // Fallback for services not in KnowledgeBase yet
    if (scheme == null && user.isProfileComplete) {
      if (service.id == 'pension' && (user.age ?? 0) >= 60) isEligible = true;
      if (service.id == 'ration' && (user.annualIncome ?? 0) <= 100000) isEligible = true;
      if (service.id == 'land' && (user.ownsLand || user.occupation == 'Farmer')) isEligible = true;
      if (service.id == 'driving' && (user.age ?? 0) >= 18) isEligible = true;
      if (service.id == 'aadhaar' || service.id == 'pan' || service.id == 'passport' || service.id == 'birth') isEligible = true;
    }

    // Translate title and description
    String serviceKey = service.title.toLowerCase().replaceAll(' ', '_');
    String translatedTitle = lang.translate(serviceKey);
    String translatedDesc = lang.translate('${serviceKey}_desc');
    if (translatedDesc == '${serviceKey}_desc') translatedDesc = service.description;

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
          translatedTitle,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.pureWhite,
          ),
        ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Section
                  _buildHeroSection(isEligible, translatedTitle, lang),
                  const SizedBox(height: 32),
                  
                  // Official Website Button
                  _buildOfficialWebsiteButton(lang),
                  const SizedBox(height: 32),
                  
                  // Description
                  _buildSection(
                    lang.translate('about_service'),
                    Text(
                      translatedDesc,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppTheme.pureWhite.withValues(alpha: 0.8),
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Processing Time
                  _buildInfoCard(
                    lang.translate('processing_time'),
                    service.processingTime,
                    Icons.access_time,
                    AppTheme.electricBlue,
                  ),
                  const SizedBox(height: 16),
                  
                  // Online Availability
                  _buildInfoCard(
                    lang.translate('online_application'),
                    service.isOnlineAvailable ? lang.translate('available') : lang.translate('not_available'),
                    Icons.computer,
                    service.isOnlineAvailable ? AppTheme.success : AppTheme.error,
                  ),
                  const SizedBox(height: 32),
                  
                  // Process Map (New Section)
                  if (scheme != null && scheme.steps.isNotEmpty) ...[
                    _buildSection(
                      lang.translate('interactive_process_map'),
                      _buildProcessMap(context, scheme.steps, lang),
                    ),
                    const SizedBox(height: 32),
                  ],
                  
                  // Required Documents
                  _buildSection(
                    lang.translate('required_documents'),
                    Column(
                      children: service.requiredDocuments
                          .map((doc) => _buildListItemByText(doc, Icons.description, lang))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Eligibility Criteria
                  _buildSection(
                    lang.translate('eligibility_criteria'),
                    Column(
                      children: service.eligibilityCriteria
                          .map((criteria) => _buildListItemByText(criteria, Icons.check_circle, lang))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  _buildActionButtons(context, lang),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isEligible, String title, LanguageProvider lang) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  service.color.withValues(alpha: 0.3),
                  service.color.withValues(alpha: 0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              service.icon,
              size: 48,
              color: service.color,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.pureWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: service.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        lang.translate(service.category.toLowerCase()),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: service.color,
                        ),
                      ),
                    ),
                    if (isEligible) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          lang.translate('eligible'),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.success,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficialWebsiteButton(LanguageProvider lang) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _launchURL(service.officialWebsite),
        icon: const Icon(Icons.open_in_new, size: 20),
        label: Text(
          lang.translate('visit_official_website'),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.electricBlue,
          foregroundColor: AppTheme.deepSpaceBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.pureWhite,
          ),
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.pureWhite.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.pureWhite,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessMap(BuildContext context, List<SchemeStep> steps, LanguageProvider lang) {
    final languageCode = lang.languageCode;
    return Column(
      children: steps.map((step) {
        final isLast = step == steps.last;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline line
              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.electricBlue.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.electricBlue, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '${step.number}',
                        style: GoogleFonts.poppins(
                          color: AppTheme.electricBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: AppTheme.electricBlue.withValues(alpha: 0.3),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Step Details
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title[languageCode] ?? step.title['en'] ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.pureWhite,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.instruction[languageCode] ?? step.instruction['en'] ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.pureWhite.withValues(alpha: 0.7),
                        ),
                      ),
                      if (step.estimatedTime != null || step.location != null) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (step.estimatedTime != null)
                              _buildStepTag(Icons.timer_outlined, step.estimatedTime![languageCode] ?? step.estimatedTime!['en']!),
                            if (step.location != null)
                              _buildStepTag(Icons.location_on_outlined, step.location![languageCode] ?? step.location!['en']!),
                            if (step.officeHours != null)
                              _buildStepTag(Icons.access_time, step.officeHours![languageCode] ?? step.officeHours!['en']!),
                          ],
                        ),
                      ],
                      if (step.prerequisites != null && step.prerequisites!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.link, size: 14, color: AppTheme.warning.withValues(alpha: 0.7)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${lang.translate('requires')}: ${step.prerequisites!.join(", ")}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppTheme.warning.withValues(alpha: 0.7),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (step.formUrl != null) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => _launchURL(step.formUrl!),
                          icon: const Icon(Icons.file_download_outlined, size: 16),
                          label: Text(lang.translate('download_official_form')),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.neonCyan,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.electricBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.electricBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.electricBlue),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.electricBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItemByText(String text, IconData icon, LanguageProvider lang) {
    // Attempt to translate the text if it's a known key
    String translatedText = lang.translate(text.toLowerCase().replaceAll(' ', '_'));
    if (translatedText == text.toLowerCase().replaceAll(' ', '_')) {
      translatedText = text;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.electricBlue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              translatedText,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppTheme.pureWhite.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, LanguageProvider lang) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Navigate to application form or external link
              _launchURL(service.officialWebsite);
            },
            icon: const Icon(Icons.assignment, size: 20),
            label: Text(
              lang.translate('apply_now'),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: service.color,
              foregroundColor: AppTheme.pureWhite,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Track application or check status
            },
            icon: const Icon(Icons.track_changes, size: 20),
            label: Text(
              lang.translate('track_application'),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.electricBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppTheme.electricBlue, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
