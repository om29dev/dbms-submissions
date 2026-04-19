// ═══════════════════════════════════════════════════════════════════════════════
// FORM REVIEW SCREEN — Review filled form data before submission
// With 4-language voice readout of all filled data
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/document_vault_service.dart';
import '../../../models/service_model.dart';
import '../../../providers/language_provider.dart';
import '../../../providers/voice_provider.dart';
import '../providers/auto_form_provider.dart';

class FormReviewScreen extends StatefulWidget {
  final ServiceModel? service;

  const FormReviewScreen({super.key, this.service});

  @override
  State<FormReviewScreen> createState() => _FormReviewScreenState();
}

class _FormReviewScreenState extends State<FormReviewScreen> {
  bool _isSpeaking = false;
  int _currentFieldIdx = -1;
  String? _selectedLang;

  @override
  void dispose() {
    // Stop TTS if playing
    final voiceProvider = context.read<VoiceProvider>();
    voiceProvider.stopSpeaking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AutoFormProvider>(
      builder: (context, provider, _) {
        if (provider.template == null) {
          return const Scaffold(
            backgroundColor: AppColors.bgDeep,
            body: Center(child: Text('No form data')),
          );
        }

        final langCode = context.watch<LanguageProvider>().languageCode;

        return Scaffold(
          backgroundColor: AppColors.bgDeep,
          appBar: AppBar(
            backgroundColor: AppColors.bgDeep,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary, size: 20),
              onPressed: () {
                _stopVoice();
                Navigator.pop(context);
              },
            ),
            title: Text(
              '📋 Review Application',
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildReadyCard(provider),
                    const SizedBox(height: 16),
                    ...provider.template!.fields.asMap().entries.map((e) {
                      final idx = e.key;
                      final field = e.value;
                      final value = provider.filledValues[field.id];
                      final hasValue = value != null && value.isNotEmpty;
                      final src = provider.getSourceLabel(field.id);
                      final isHighlighted =
                          _isSpeaking && _currentFieldIdx == idx;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildFieldRow(
                          context,
                          label: field.getLabel(langCode),
                          value: hasValue ? value : '—',
                          hasValue: hasValue,
                          source: hasValue ? src : null,
                          isSensitive: field.sensitive,
                          isHighlighted: isHighlighted,
                        ),
                      ).animate().fadeIn(
                          duration: 200.ms,
                          delay: Duration(milliseconds: 20 * idx));
                    }),
                  ],
                ),
              ),
              _buildVoiceSection(context, provider, langCode),
              _buildBottomButtons(context, provider, langCode),
            ],
          ),
        );
      },
    );
  }

  // ─── Ready Card ─────────────────────────────────────────────────────────────

  Widget _buildReadyCard(AutoFormProvider provider) {
    final pct = provider.fillPercentage;
    final isComplete = pct >= 0.8;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete
              ? AppColors.emeraldLight.withValues(alpha: 0.4)
              : AppColors.gold.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isComplete
                    ? Icons.check_circle_rounded
                    : Icons.info_outline_rounded,
                color: isComplete ? AppColors.emeraldLight : AppColors.gold,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isComplete ? '✓ Ready to submit' : 'Review your data',
                  style: GoogleFonts.poppins(
                    color: isComplete ? AppColors.emeraldLight : AppColors.gold,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            provider.template!.getTitle('en'),
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${provider.filledCount}/${provider.totalCount} fields filled (${(pct * 100).round()}%)',
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ─── Field Row ──────────────────────────────────────────────────────────────

  Widget _buildFieldRow(
    BuildContext context, {
    required String label,
    required String value,
    required bool hasValue,
    String? source,
    bool isSensitive = false,
    bool isHighlighted = false,
  }) {
    // Mask sensitive data (show last 4 chars)
    final displayValue = isSensitive && hasValue && value.length > 4
        ? '${'•' * (value.length - 4)}${value.substring(value.length - 4)}'
        : value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.saffron.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isHighlighted
            ? Border.all(color: AppColors.saffron.withValues(alpha: 0.4))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            hasValue
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked,
            color: hasValue ? AppColors.emeraldLight : AppColors.textMuted,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (source != null)
                      Text(
                        source,
                        style: GoogleFonts.poppins(
                          color: AppColors.saffron.withValues(alpha: 0.7),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                Text(
                  displayValue,
                  style: GoogleFonts.poppins(
                    color:
                        hasValue ? AppColors.textPrimary : AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (isHighlighted)
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(Icons.volume_up_rounded,
                  color: AppColors.saffron, size: 16),
            ),
        ],
      ),
    );
  }

  // ─── Voice Explanation Section ──────────────────────────────────────────────

  Widget _buildVoiceSection(
    BuildContext context,
    AutoFormProvider provider,
    String langCode,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status indicator when speaking
          if (_isSpeaking)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: AppColors.saffron,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '🔊 Reading your application data...',
                      style: GoogleFonts.poppins(
                        color: AppColors.saffron,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _stopVoice,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accentRed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Stop',
                        style: GoogleFonts.poppins(
                          color: AppColors.accentRed,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Language buttons row
          if (!_isSpeaking)
            Column(
              children: [
                Text(
                  '🔊 Listen to your application data',
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildLangButton(
                      label: 'English',
                      langCode: 'en',
                      provider: provider,
                    ),
                    const SizedBox(width: 8),
                    _buildLangButton(
                      label: 'हिंदी',
                      langCode: 'hi',
                      provider: provider,
                    ),
                    const SizedBox(width: 8),
                    _buildLangButton(
                      label: 'தமிழ்',
                      langCode: 'ta',
                      provider: provider,
                    ),
                    const SizedBox(width: 8),
                    _buildLangButton(
                      label: 'मराठी',
                      langCode: 'mr',
                      provider: provider,
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLangButton({
    required String label,
    required String langCode,
    required AutoFormProvider provider,
  }) {
    final isSelected = _selectedLang == langCode && _isSpeaking;

    return Expanded(
      child: GestureDetector(
        onTap: () => _startVoiceReadout(provider, langCode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.saffron : AppColors.bgMid,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.saffron : AppColors.surfaceBorder,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.volume_up_rounded,
                size: 18,
                color: isSelected ? Colors.white : AppColors.gold,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Voice Readout Logic ────────────────────────────────────────────────────

  Future<void> _startVoiceReadout(
    AutoFormProvider provider,
    String langCode,
  ) async {
    if (_isSpeaking) {
      _stopVoice();
      return;
    }

    final voiceProvider = context.read<VoiceProvider>();
    final template = provider.template;
    if (template == null) return;

    setState(() {
      _isSpeaking = true;
      _selectedLang = langCode;
      _currentFieldIdx = -1;
    });

    await voiceProvider.setLanguage(langCode);

    // Step 1: Introduce the form
    final formName = template.getTitle(langCode);
    final introMap = {
      'en': 'This is $formName form. Following information is filled.',
      'hi': 'यह $formName फॉर्म है। निम्नलिखित जानकारी भरी गई है।',
      'ta': 'இது $formName படிவம். பின்வரும் தகவல்கள் நிரப்பப்பட்டுள்ளன.',
      'mr': 'हा $formName फॉर्म आहे. खालील माहिती भरली गेली आहे.',
    };
    await voiceProvider.speakAndWait(introMap[langCode] ?? introMap['en']!);
    await Future.delayed(const Duration(milliseconds: 400));

    if (!_isSpeaking) return;

    // Step 2: Read each field (ALL fields, not just filled ones)
    for (int i = 0; i < template.fields.length; i++) {
      if (!_isSpeaking) break;

      final field = template.fields[i];
      final value = provider.filledValues[field.id];
      final hasValue = value != null && value.isNotEmpty;

      setState(() => _currentFieldIdx = i);

      final label = field.getLabel(langCode);

      String speech;
      if (hasValue) {
        // Mask sensitive values in voice
        final displayVal = field.sensitive && value.length > 4
            ? _getSensitiveVoice(value, langCode)
            : value;
        final speechMap = {
          'en': '$label is $displayVal.',
          'hi': '$label है $displayVal.',
          'ta': '$label $displayVal.',
          'mr': '$label आहे $displayVal.',
        };
        speech = speechMap[langCode] ?? speechMap['en']!;
      } else {
        final emptyMap = {
          'en': '$label is not filled yet.',
          'hi': '$label अभी भरा नहीं है।',
          'ta': '$label இன்னும் நிரப்பப்படவில்லை.',
          'mr': '$label अजून भरलेले नाही.',
        };
        speech = emptyMap[langCode] ?? emptyMap['en']!;
      }

      await voiceProvider.speakAndWait(speech);
      // Smooth pause between fields
      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (!_isSpeaking) return;

    // Step 3: Summary
    final filled = provider.filledCount;
    final total = provider.totalCount;
    final empty = provider.emptyFieldIds.length;

    final summaryMap = {
      'en':
          'Total $filled out of $total fields are filled. $empty fields are empty and need your input.',
      'hi':
          'कुल $total में से $filled फ़ील्ड भरे हैं। $empty फ़ील्ड खाली हैं और आपका इनपुट चाहिए।',
      'ta':
          'மொத்தம் $total புலங்களில் $filled நிரப்பப்பட்டுள்ளன. $empty புலங்கள் காலியாக உள்ளன.',
      'mr':
          'एकूण $total पैकी $filled फील्ड भरले आहेत. $empty फील्ड रिकामे आहेत.',
    };
    await voiceProvider.speakAndWait(summaryMap[langCode] ?? summaryMap['en']!);

    // Done
    if (mounted) {
      setState(() {
        _isSpeaking = false;
        _currentFieldIdx = -1;
        _selectedLang = null;
      });
    }
  }

  String _getSensitiveVoice(String value, String langCode) {
    final last4 = value.substring(value.length - 4);
    final map = {
      'en': 'ending in $last4',
      'hi': '$last4 पर समाप्त',
      'ta': '$last4 இல் முடிவடையும்',
      'mr': '$last4 वर संपणारा',
    };
    return map[langCode] ?? map['en']!;
  }

  void _stopVoice() {
    final voiceProvider = context.read<VoiceProvider>();
    voiceProvider.stopSpeaking();
    if (mounted) {
      setState(() {
        _isSpeaking = false;
        _currentFieldIdx = -1;
        _selectedLang = null;
      });
    }
  }

  // ─── Bottom Buttons ─────────────────────────────────────────────────────────

  Widget _buildBottomButtons(
    BuildContext context,
    AutoFormProvider provider,
    String langCode,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSpeaking
                    ? null
                    : () => _submitApplication(context, provider, langCode),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: Text(
                  'Submit on Official Portal',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.saffron,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  _stopVoice();
                  Navigator.pop(context);
                },
                child: Text(
                  'Edit Form',
                  style: GoogleFonts.poppins(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitApplication(
    BuildContext context,
    AutoFormProvider provider,
    String langCode,
  ) async {
    // Save form fill history
    final filledLabels = provider.getFilledDataByLabel(langCode);
    await DocumentVaultService.saveFormFillHistory(
      serviceId: provider.template!.serviceId,
      serviceName: provider.template!.getTitle('en'),
      fieldsTotal: provider.totalCount,
      fieldsAutoFilled: provider.filledCount,
      filledData: filledLabels,
      status: 'submitted',
    );

    if (!context.mounted) return;

    // Navigate to guided submission
    context.push(
      Routes.guidedSubmit,
      extra: {
        'url': provider.template!.officialUrl,
        'title': provider.template!.getTitle(langCode),
        'formData': provider.getFilledDataByDataKey(),
        'submitSteps': provider.template!.submitSteps,
        'portalName': provider.template!.portalName,
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✓ Application saved! Opening guided portal...',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: AppColors.emeraldLight,
      ),
    );
  }
}
