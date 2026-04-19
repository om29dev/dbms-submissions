import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:civic_voice_interface/core/constants/app_colors.dart';
import 'package:civic_voice_interface/core/theme/app_theme.dart';
import 'package:civic_voice_interface/models/scheme_model.dart';
import 'package:civic_voice_interface/providers/user_provider.dart';
import 'package:civic_voice_interface/providers/language_provider.dart';
import 'package:civic_voice_interface/providers/voice_provider.dart';
import 'package:civic_voice_interface/models/application_model.dart';

class SchemeDetailScreen extends StatefulWidget {
  final GovernmentScheme scheme;
  const SchemeDetailScreen({super.key, required this.scheme});

  @override
  State<SchemeDetailScreen> createState() => _SchemeDetailScreenState();
}

class _SchemeDetailScreenState extends State<SchemeDetailScreen> {
  bool _isReading = false;

  void _readSchemeDetails() {
    final voiceProvider = Provider.of<VoiceProvider>(context, listen: false);
    
    // Always stop TTS first
    voiceProvider.stopSilently();
    
    // Toggle the state
    setState(() => _isReading = !_isReading);
    
    // If now ON, start speaking
    if (_isReading) {
      // Build comprehensive scheme information
      String content = "Scheme: ${widget.scheme.names['en']}. ";
      content += "Description: ${widget.scheme.description}. ";
      content += "Benefits: ${widget.scheme.benefits}. ";
      if (widget.scheme.helplineNumber != null) {
        content += "Helpline number: ${widget.scheme.helplineNumber}. ";
      }
      content += "Eligibility criteria: ";
      for (var rule in widget.scheme.eligibilityRules) {
        content += "${rule.explanation['en']}. ";
      }
      content += "Required documents: ";
      for (var doc in widget.scheme.requiredDocuments) {
        content += "${doc.name['en']}, ${doc.reason['en']}. ";
      }
      content += "Application steps: ";
      for (var step in widget.scheme.steps) {
        content += "Step ${step.number}: ${step.title['en']}. ${step.instruction['en']}. ";
      }
      
      voiceProvider.speak(content);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          widget.scheme.names['en']!,
          style: GoogleFonts.poppins(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Voice Reading Toggle Button
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: _isReading ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isReading ? AppColors.primary : AppColors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: IconButton(
                onPressed: _readSchemeDetails,
                icon: Icon(
                  _isReading ? Icons.volume_off : Icons.volume_up,
                  color: _isReading ? AppColors.error : AppColors.primary,
                  size: 24,
                ),
                tooltip: _isReading ? 'Turn Off Speaker' : 'Turn On Speaker',
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            _buildSection(
              'Description',
              Icons.info_outline,
              Text(
                widget.scheme.description,
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.8),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Benefits
            _buildSection(
              'Benefits',
              Icons.card_giftcard,
              Text(
                widget.scheme.benefits,
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.8),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Contact & Mode Info
            if (widget.scheme.helplineNumber != null || widget.scheme.applicationMode != null) ...[
              Row(
                children: [
                  if (widget.scheme.helplineNumber != null)
                    Expanded(
                      child: _buildInfoCard(
                        Icons.phone,
                        'Helpline',
                        widget.scheme.helplineNumber!,
                        AppColors.success,
                      ),
                    ),
                  if (widget.scheme.helplineNumber != null && widget.scheme.applicationMode != null)
                    const SizedBox(width: 12),
                  if (widget.scheme.applicationMode != null)
                    Expanded(
                      child: _buildInfoCard(
                        Icons.computer,
                        'Mode',
                        widget.scheme.applicationMode!,
                        AppColors.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 15),
            ],

            // Official Website
            if (widget.scheme.officialWebsite != null) ...[
              _buildInfoCard(
                Icons.language,
                'Official Website',
                widget.scheme.officialWebsite!,
                AppTheme.electricBlue,
              ),
              const SizedBox(height: 30),
            ],

            // Eligibility
            _buildSection(
              'Eligibility Criteria',
              Icons.check_circle_outline,
              Column(
                children: widget.scheme.eligibilityRules.map((rule) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check, color: AppColors.success, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            rule.explanation['en']!,
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 30),

            // Documents
            _buildSection(
              'Required Documents',
              Icons.file_copy,
              Column(
                children: widget.scheme.requiredDocuments.map((doc) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.name['en']!,
                          style: GoogleFonts.poppins(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          doc.reason['en']!,
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.5),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 30),

            // Application Steps
            _buildSection(
              'Application Steps',
              Icons.list_alt,
              Column(
                children: widget.scheme.steps.map((step) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${step.number}',
                              style: const TextStyle(
                                color: AppColors.background,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.title['en']!,
                                style: GoogleFonts.poppins(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                step.instruction['en']!,
                                style: TextStyle(
                                  color: AppColors.white.withValues(alpha: 0.6),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildApplyButton(context),
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    
    // Check if already applied
    final isApplied = userProvider.currentUser.applications.any(
      (app) => app.schemeId == widget.scheme.id
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isApplied ? null : () => _applyForScheme(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: isApplied ? Colors.grey : AppColors.primary,
          foregroundColor: AppColors.background,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
        ),
        child: Text(
          isApplied 
            ? lang.translate('already_applied') 
            : lang.translate('apply_now'),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _applyForScheme(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final lang = Provider.of<LanguageProvider>(context, listen: false);

    // 1. Create Application Model
    final newApp = UserApplication(
      id: 'app_${DateTime.now().millisecondsSinceEpoch}',
      schemeId: widget.scheme.id,
      schemeName: widget.scheme.names['en'] ?? widget.scheme.id,
      status: ApplicationStatus.submitted,
      submissionDate: DateTime.now(),
      currentStep: 'Initial Submission',
      nextStep: 'Document Verification',
      timeline: [
        ApplicationEvent(
          title: 'Submitted',
          description: 'Application successfully submitted via CVI.',
          timestamp: DateTime.now(),
        ),
      ],
    );

    // 2. Add to Provider
    userProvider.addApplication(newApp);

    // 3. Feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(lang.translate('application_submitted')),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {}); // Refresh button state
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        content,
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
