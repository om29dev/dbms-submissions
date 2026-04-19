// ═══════════════════════════════════════════════════════════════════════════════
// SMART FORM SCREEN — AI Auto-Fill with Animated Visualization
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../models/service_model.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/language_provider.dart';
import '../../../providers/voice_provider.dart';
import '../../../providers/citizen_profile_provider.dart';
import '../models/auto_form_model.dart';
import '../providers/auto_form_provider.dart';

class SmartFormScreen extends StatefulWidget {
  final String serviceId;
  final ServiceModel? service;

  const SmartFormScreen({
    super.key,
    required this.serviceId,
    this.service,
  });

  @override
  State<SmartFormScreen> createState() => _SmartFormScreenState();
}

class _SmartFormScreenState extends State<SmartFormScreen>
    with TickerProviderStateMixin {
  final Map<String, TextEditingController> _controllers = {};
  bool _hasStartedAnimation = false;

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  Future<void> _loadForm() async {
    final provider = context.read<AutoFormProvider>();
    await provider.loadTemplate(widget.serviceId);
    await provider.autoFillFromVault();

    // Also fill from user profile (age, phone, email, etc.)
    if (mounted) {
      final userProvider = context.read<UserProvider>();
      final citizenProvider = context.read<CitizenProfileProvider>();
      provider.autoFillFromProfile(
        userProvider: userProvider,
        citizenProvider: citizenProvider,
      );
    }

    // Create controllers for all fields
    if (provider.template != null) {
      for (final field in provider.template!.fields) {
        _controllers[field.id] = TextEditingController(
          text: provider.filledValues[field.id] ?? '',
        );
      }
    }

    // Start animated fill after a brief delay
    if (mounted && provider.template != null && !_hasStartedAnimation) {
      _hasStartedAnimation = true;
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        await provider.startAnimatedFill(delayMs: 250);
        // Sync controllers with final values
        if (mounted) _syncControllers();
      }
    }
  }

  void _syncControllers() {
    final provider = context.read<AutoFormProvider>();
    for (final field in provider.template?.fields ?? <SmartFormField>[]) {
      final val = provider.filledValues[field.id] ?? '';
      if (_controllers[field.id] != null &&
          _controllers[field.id]!.text != val) {
        _controllers[field.id]!.text = val;
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AutoFormProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return _buildLoadingScreen();
        if (provider.template == null) {
          return _buildNoFormScreen(provider.errorMessage);
        }

        final langCode = context.watch<LanguageProvider>().languageCode;

        return Scaffold(
          backgroundColor: AppColors.bgDeep,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    _buildAppBar(provider, langCode),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: 8),
                          _buildHeader(provider, langCode),
                          const SizedBox(height: 16),
                          _buildAutoFillStats(provider),
                          const SizedBox(height: 16),
                          if (provider.emptyFieldIds.isNotEmpty &&
                              provider.fillPercentage < 0.5)
                            _buildMissingDocsAlert(provider, langCode),
                          const SizedBox(height: 12),
                          _buildFormBody(provider, langCode),
                          const SizedBox(height: 100),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              _buildBottomBar(provider, langCode),
            ],
          ),
        );
      },
    );
  }

  // ─── Loading Screen ─────────────────────────────────────────────────────────

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                color: AppColors.saffron,
                strokeWidth: 3,
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Text(
              '✨ AI is preparing your form...',
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            Text(
              'Matching your documents to form fields',
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  // ─── No Form Available ──────────────────────────────────────────────────────

  Widget _buildNoFormScreen(String? errorMsg) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📋', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'No form template yet',
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMsg ??
                    'AI auto-fill is not available for this service yet.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── App Bar ────────────────────────────────────────────────────────────────

  SliverAppBar _buildAppBar(AutoFormProvider provider, String langCode) {
    return SliverAppBar(
      backgroundColor: AppColors.bgDeep,
      pinned: true,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary, size: 20),
        onPressed: () {
          provider.reset();
          Navigator.pop(context);
        },
      ),
      title: Text(
        '✨ Smart AI Form',
        style: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      actions: [
        if (provider.isAnimating)
          TextButton(
            onPressed: provider.skipAnimation,
            child: Text(
              'Skip →',
              style: GoogleFonts.poppins(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(AutoFormProvider provider, String langCode) {
    final title = provider.template!.getTitle(langCode);
    final titleHi = provider.template!.getTitle('hi');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (langCode != 'hi')
          Text(
            titleHi,
            style: GoogleFonts.poppins(
              color: AppColors.gold,
              fontSize: 15,
            ),
          ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.language_rounded,
                color: AppColors.textMuted, size: 14),
            const SizedBox(width: 4),
            Text(
              provider.template!.portalName,
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  // ─── Auto-Fill Stats Card ───────────────────────────────────────────────────

  Widget _buildAutoFillStats(AutoFormProvider provider) {
    final pct = provider.fillPercentage;
    final isGood = pct >= 0.8;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isGood ? const Color(0xFF0A1A0A) : AppColors.bgDark,
            AppColors.bgDeep,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGood
              ? AppColors.emeraldLight.withValues(alpha: 0.4)
              : AppColors.gold.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '✨ AI Auto-filled ${provider.filledCount} of ${provider.totalCount} fields',
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(pct * 100).round()}%',
                style: GoogleFonts.poppins(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppColors.bgLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                isGood ? AppColors.emeraldLight : AppColors.saffron,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms);
  }

  // ─── Missing Docs Alert ─────────────────────────────────────────────────────

  Widget _buildMissingDocsAlert(AutoFormProvider provider, String langCode) {
    final template = provider.template!;
    final missingLabels = provider.emptyFieldIds.take(5).map((id) {
      final field = template.fields.firstWhere(
        (f) => f.id == id,
        orElse: () => template.fields.first,
      );
      return field.getLabel(langCode);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.saffron.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.saffron, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Upload more documents to fill more fields',
                  style: GoogleFonts.poppins(
                    color: AppColors.saffron,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: missingLabels.map((label) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgMid,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style:
                      GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => context.push(Routes.documentVault),
            child: Text(
              'Go to Document Vault →',
              style: GoogleFonts.poppins(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.gold,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  // ─── Form Body ──────────────────────────────────────────────────────────────

  Widget _buildFormBody(AutoFormProvider provider, String langCode) {
    final template = provider.template!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Form Fields',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ...template.fields.asMap().entries.map((entry) {
          final idx = entry.key;
          final field = entry.value;
          final value = provider.filledValues[field.id];
          final hasValue = value != null && value.isNotEmpty;
          final isAnimating =
              provider.isAnimating && provider.animatedFieldIndex == idx;
          final isExplaining =
              provider.isExplaining && provider.currentExplainIndex == idx;
          final source = provider.getSourceLabel(field.id);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SmartFieldCard(
              field: field,
              value: value,
              hasValue: hasValue,
              isHighlighted: isAnimating || isExplaining,
              sourceLabel: hasValue ? source : null,
              langCode: langCode,
              controller: _controllers[field.id],
              onChanged: (newVal) {
                provider.updateField(field.id, newVal);
              },
            ),
          ).animate().fadeIn(
                duration: 300.ms,
                delay: Duration(milliseconds: 30 * idx),
              );
        }),
      ],
    );
  }

  // ─── Bottom Bar ─────────────────────────────────────────────────────────────

  Widget _buildBottomBar(AutoFormProvider provider, String langCode) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Voice Explain Button — opens language chooser
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: provider.isAnimating
                    ? null
                    : () {
                        final voiceProvider = context.read<VoiceProvider>();
                        if (provider.isExplaining) {
                          provider.stopVoiceExplanation(voiceProvider);
                        } else {
                          _showExplainLanguageChooser(context, provider);
                        }
                      },
                icon: Icon(
                  provider.isExplaining
                      ? Icons.stop_circle_rounded
                      : Icons.record_voice_over_rounded,
                  size: 20,
                ),
                label: Text(
                  provider.isExplaining
                      ? 'Stop Explanation'
                      : '🔊 Explain Form',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Review Button
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${provider.filledCount}/${provider.totalCount} filled',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: ElevatedButton(
                    onPressed: provider.isAnimating
                        ? null
                        : () {
                            // Sync controller values before review
                            for (final f in provider.template?.fields ??
                                <SmartFormField>[]) {
                              final val = _controllers[f.id]?.text ?? '';
                              provider.updateField(f.id, val);
                            }
                            context.push(
                              Routes.formReview,
                              extra: widget.service,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.saffron,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'Review & Submit →',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a language chooser for voice explanation of form info + required fields.
  void _showExplainLanguageChooser(
      BuildContext context, AutoFormProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '🔊 Choose Language',
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'AI will explain this form and required fields',
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              _LanguageOption(
                flag: '🇮🇳',
                name: 'English',
                nativeName: 'English',
                langCode: 'en',
                onTap: () {
                  Navigator.pop(ctx);
                  _startFormExplanation(provider, 'en');
                },
              ),
              const SizedBox(height: 10),
              _LanguageOption(
                flag: '🇮🇳',
                name: 'Hindi',
                nativeName: 'हिंदी',
                langCode: 'hi',
                onTap: () {
                  Navigator.pop(ctx);
                  _startFormExplanation(provider, 'hi');
                },
              ),
              const SizedBox(height: 10),
              _LanguageOption(
                flag: '🇮🇳',
                name: 'Tamil',
                nativeName: 'தமிழ்',
                langCode: 'ta',
                onTap: () {
                  Navigator.pop(ctx);
                  _startFormExplanation(provider, 'ta');
                },
              ),
              const SizedBox(height: 10),
              _LanguageOption(
                flag: '🇮🇳',
                name: 'Marathi',
                nativeName: 'मराठी',
                langCode: 'mr',
                onTap: () {
                  Navigator.pop(ctx);
                  _startFormExplanation(provider, 'mr');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _startFormExplanation(AutoFormProvider provider, String langCode) {
    final voiceProvider = context.read<VoiceProvider>();
    provider.startVoiceExplanation(
      langCode: langCode,
      voiceProvider: voiceProvider,
    );
  }

  // ─── Document Scanner Integration ──────────────────────────────────────────
}

// ═══════════════════════════════════════════════════════════════════════════════
// SMART FIELD CARD — Individual form field with source transparency
// ═══════════════════════════════════════════════════════════════════════════════

class _SmartFieldCard extends StatelessWidget {
  final SmartFormField field;
  final String? value;
  final bool hasValue;
  final bool isHighlighted;
  final String? sourceLabel;
  final String langCode;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const _SmartFieldCard({
    required this.field,
    required this.value,
    required this.hasValue,
    required this.isHighlighted,
    required this.langCode,
    this.sourceLabel,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final label = field.getLabel(langCode);
    final labelHi = langCode != 'hi' ? field.getLabel('hi') : null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.saffron.withOpacity(0.08)
            : AppColors.bgDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHighlighted
              ? AppColors.saffron.withOpacity(0.5)
              : hasValue
                  ? AppColors.emeraldLight.withOpacity(0.3)
                  : AppColors.surfaceBorder,
          width: isHighlighted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row with source badge
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (hasValue)
                          const Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.emeraldLight,
                              size: 14,
                            ),
                          ),
                        Flexible(
                          child: Text(
                            label,
                            style: GoogleFonts.poppins(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (field.required)
                          const Text(' *',
                              style: TextStyle(
                                  color: AppColors.accentRed, fontSize: 14)),
                      ],
                    ),
                    if (labelHi != null)
                      Text(
                        labelHi,
                        style: GoogleFonts.poppins(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              // Data source badge
              if (sourceLabel != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.saffron.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    sourceLabel!,
                    style: GoogleFonts.poppins(
                      color: AppColors.saffron,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Input field
          if (field.fieldType == 'dropdown') _buildDropdown(context),
          if (field.fieldType != 'dropdown')
            TextField(
              controller: controller,
              onChanged: onChanged,
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Enter ${label.toLowerCase()}',
                hintStyle: GoogleFonts.poppins(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: AppColors.bgMid,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.saffron, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: field.options?.contains(value) == true ? value : null,
      items: field.options?.map((opt) {
        return DropdownMenuItem(
          value: opt,
          child: Text(opt,
              style: GoogleFonts.poppins(
                  color: AppColors.textPrimary, fontSize: 13)),
        );
      }).toList(),
      onChanged: (val) => onChanged?.call(val ?? ''),
      dropdownColor: AppColors.bgMid,
      decoration: InputDecoration(
        hintText: 'Select',
        hintStyle:
            GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        filled: true,
        fillColor: AppColors.bgMid,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LANGUAGE OPTION — Language chooser item for voice readout
// ═══════════════════════════════════════════════════════════════════════════════

class _LanguageOption extends StatelessWidget {
  final String flag;
  final String name;
  final String nativeName;
  final String langCode;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.flag,
    required this.name,
    required this.nativeName,
    required this.langCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bgMid,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    nativeName,
                    style: GoogleFonts.poppins(
                      color: AppColors.gold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.play_circle_rounded,
                color: AppColors.saffron, size: 28),
          ],
        ),
      ),
    );
  }
}
