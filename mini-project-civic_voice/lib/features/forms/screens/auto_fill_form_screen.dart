// AUTO FILL FORM SCREEN — AWS-backed AI auto-filled government forms

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/document_vault_service.dart';
import '../../../core/services/form_filler_service.dart';
import '../../../models/service_model.dart';
import '../../../core/router/app_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/language_provider.dart';

class AutoFillFormScreen extends StatefulWidget {
  final String serviceId;
  final ServiceModel? service;

  const AutoFillFormScreen({
    super.key,
    required this.serviceId,
    this.service,
  });

  @override
  State<AutoFillFormScreen> createState() => _AutoFillFormScreenState();
}

class _AutoFillFormScreenState extends State<AutoFillFormScreen> {
  bool _isLoading = true;
  bool _showReview = false;

  GovernmentFormDef? _formDef;
  Map<String, String?> _filledValues = {};
  List<String> _emptyFields = [];
  int _filledCount = 0;
  int _totalCount = 0;

  // Controllers for manual edits
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadFormData() async {
    final result = await FormFillerService.autoFillFromAws(
      serviceId: widget.serviceId,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _formDef = result['form'] as GovernmentFormDef?;
        _filledValues =
            Map<String, String?>.from(result['filledValues'] as Map);
        _emptyFields = List<String>.from(result['emptyFields'] as List);
        _filledCount = result['filledCount'] as int;
        _totalCount = result['totalCount'] as int;

        // Create controllers for all fields
        if (_formDef != null) {
          for (final field in _formDef!.fields) {
            _controllers[field.id] = TextEditingController(
              text: _filledValues[field.id] ?? '',
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingScreen();
    if (_showReview) return _buildReviewScreen();
    if (_formDef == null) return _buildNoFormScreen();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B07),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 8),
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildAutoFillStats(),
                      const SizedBox(height: 16),
                      if (_emptyFields.isNotEmpty &&
                          _filledCount < _totalCount ~/ 2)
                        _buildMissingDocsAlert(),
                      const SizedBox(height: 12),
                      _buildFormBody(),
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ─── Loading Screen ───────────────────────────────────────────────────────

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0B07),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                color: Color(0xFFFF6B1A),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '✨ AI is preparing your form...',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Matching your documents to form fields',
              style: GoogleFonts.outfit(
                color: const Color(0xFFB8A898),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── No Form Available ────────────────────────────────────────────────────

  Widget _buildNoFormScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0B07),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0B07),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
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
                'No form definition yet',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'AI auto-fill is not yet available for this service. You can apply directly on the official website.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: const Color(0xFFB8A898),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              if (widget.service?.officialLink != null)
                ElevatedButton.icon(
                  onPressed: () => _launch(widget.service!.officialLink),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: Text('Open Official Website',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B1A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0D0B07),
      pinned: true,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        '✨ AI Auto-Fill',
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final sName = widget.service?.name['en'] ?? _formDef!.formName;
    final sNameHindi = widget.service?.name['hi'] ?? _formDef!.formNameHindi;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sName,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          sNameHindi,
          style: GoogleFonts.outfit(
            color: const Color(0xFFD4930A),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formDef!.submitInstructions,
          style: GoogleFonts.outfit(
            color: const Color(0xFFB8A898),
            fontSize: 12,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  // ─── Auto Fill Stats ──────────────────────────────────────────────────────

  Widget _buildAutoFillStats() {
    final pct = _totalCount > 0 ? _filledCount / _totalCount : 0.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            pct >= 0.8 ? const Color(0xFF0A1A0A) : const Color(0xFF1A1208),
            const Color(0xFF0D0B07),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: pct >= 0.8
              ? const Color(0xFF2E7D32).withValues(alpha: 0.4)
              : const Color(0xFFD4930A).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '✨ AI Auto-filled $_filledCount of $_totalCount fields',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(pct * 100).round()}%',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFD4930A),
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
              backgroundColor: const Color(0xFF2A1F10),
              valueColor: AlwaysStoppedAnimation<Color>(
                pct >= 0.8 ? const Color(0xFF4CAF50) : const Color(0xFFFF6B1A),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms);
  }

  // ─── Missing Docs Alert ───────────────────────────────────────────────────

  Widget _buildMissingDocsAlert() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1208),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFE65100).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFFF6B1A), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Upload more documents to fill more fields',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFF6B1A),
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
            children: _emptyFields.take(5).map((f) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A1F10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  f,
                  style:
                      GoogleFonts.outfit(color: Colors.white60, fontSize: 11),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => context.push('/document-vault'),
            child: Text(
              'Go to Document Vault →',
              style: GoogleFonts.outfit(
                color: const Color(0xFFD4930A),
                fontWeight: FontWeight.w600,
                fontSize: 13,
                decoration: TextDecoration.underline,
                decorationColor: const Color(0xFFD4930A),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  // ─── Form Body ────────────────────────────────────────────────────────────

  Widget _buildFormBody() {
    if (_formDef == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Form Fields',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ..._formDef!.fields.asMap().entries.map((entry) {
          final idx = entry.key;
          final field = entry.value;
          final value = _filledValues[field.id];
          final hasValue = value != null && value.isNotEmpty;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _FormFieldCard(
              field: field,
              value: value,
              hasValue: hasValue,
              controller: _controllers[field.id]!,
              onChanged: (newVal) {
                setState(() {
                  _filledValues[field.id] = newVal;
                  _recalculateStats();
                });
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

  void _recalculateStats() {
    int filled = 0;
    final empty = <String>[];
    for (final field in _formDef!.fields) {
      final val = _controllers[field.id]?.text ?? '';
      if (val.isNotEmpty) {
        filled++;
      } else {
        empty.add(field.label);
      }
    }
    setState(() {
      _filledCount = filled;
      _emptyFields = empty;
    });
  }

  // ─── Bottom Bar ───────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    final allRequired = _formDef?.fields
            .where((f) => f.isRequired)
            .every((f) => (_controllers[f.id]?.text ?? '').isNotEmpty) ??
        false;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1208),
        border: Border(top: BorderSide(color: Color(0xFF2A1F10))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Text(
                '$_filledCount/$_totalCount fields filled',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  color: const Color(0xFFB8A898),
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: ElevatedButton(
                onPressed: () {
                  // Update filled values from controllers
                  for (final field in _formDef!.fields) {
                    _filledValues[field.id] = _controllers[field.id]?.text;
                  }
                  setState(() => _showReview = true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: allRequired
                      ? const Color(0xFFFF6B1A)
                      : const Color(0xFF555555),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  allRequired
                      ? 'Review & Submit →'
                      : '$_filledCount fields need input',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Review Screen ────────────────────────────────────────────────────────

  Widget _buildReviewScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0B07),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0B07),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => setState(() => _showReview = false),
        ),
        title: Text(
          '📋 Review Application',
          style: GoogleFonts.outfit(
            color: Colors.white,
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
                // Service header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1208),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✓ Ready to submit',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF4CAF50),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formDef!.formName,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // All fields summary
                ..._formDef!.fields.map((field) {
                  final value = _filledValues[field.id];
                  final hasValue = value != null && value.isNotEmpty;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          hasValue
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked,
                          color: hasValue
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF666666),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                field.label,
                                style: GoogleFonts.outfit(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                hasValue ? value : '—',
                                style: GoogleFonts.outfit(
                                  color: hasValue
                                      ? Colors.white
                                      : const Color(0xFF666666),
                                  fontSize: 14,
                                  fontWeight: hasValue
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1208),
              border: Border(top: BorderSide(color: Color(0xFF2A1F10))),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submitApplication,
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: Text(
                        'Open Official Website',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B1A),
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
                      onPressed: () => setState(() => _showReview = false),
                      child: Text(
                        'Edit Form',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFD4930A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Submit ───────────────────────────────────────────────────────────────

  Future<void> _submitApplication() async {
    // Save form fill history to AWS Amplify
    final filledData = <String, dynamic>{};
    for (final field in _formDef!.fields) {
      filledData[field.label] = _filledValues[field.id] ?? '';
    }

    await DocumentVaultService.saveFormFillHistory(
      serviceId: widget.serviceId,
      serviceName: _formDef!.formName,
      fieldsTotal: _totalCount,
      fieldsAutoFilled: _filledCount,
      filledData: filledData,
      status: 'submitted',
    );

    // Prepare data for Smart Browser
    final autoFillMap = <String, String>{};
    for (final field in _formDef!.fields) {
      final val = _filledValues[field.id];
      if (val != null && val.isNotEmpty) {
        autoFillMap[field.dataKey] = val;
      }
    }

    if (mounted) {
      _showLanguageChoiceDialog(autoFillMap);
    }
  }

  void _openSmartBrowser(Map<String, String> autoFillMap,
      {bool initialTranslate = true, String? languageCode}) {
    context.push(
      Routes.smartBrowser,
      extra: {
        'url': _formDef!.officialUrl,
        'title': _formDef!.formName,
        'formData': autoFillMap,
        'initialTranslate': initialTranslate,
        'languageCode': languageCode,
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✓ Application saved! Opening Smart Browser...',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }

  void _showLanguageChoiceDialog(Map<String, String> autoFillMap) {
    final langProvider = context.read<LanguageProvider>();
    final currentLangName = langProvider.languageName;
    final isEnglish = langProvider.languageCode == 'en';

    // Default to Hindi if app is in English, otherwise use current regional language
    final regionalLangName = isEnglish ? 'हिन्दी (Hindi)' : currentLangName;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bContext) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF121212),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Preferred Language',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'How would you like to view the official government website?',
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(bContext);
                _openSmartBrowser(autoFillMap, initialTranslate: false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E2E2E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('View in English',
                  style: GoogleFonts.outfit(color: Colors.white)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(bContext);
                // If app is in English but user clicked "View in Hindi", pass 'hi'
                final code = isEnglish ? 'hi' : langProvider.languageCode;
                _openSmartBrowser(autoFillMap,
                    initialTranslate: true, languageCode: code);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B1A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'View in $regionalLangName',
                style: GoogleFonts.outfit(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FORM FIELD CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _FormFieldCard extends StatelessWidget {
  final FormFieldDef field;
  final String? value;
  final bool hasValue;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _FormFieldCard({
    required this.field,
    required this.value,
    required this.hasValue,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1208),
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(
            color: hasValue ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      field.label,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      field.labelHindi,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFB8A898),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasValue)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'AI ✓',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF4CAF50),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (!hasValue && !field.isRequired)
                Text(
                  'Optional',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF666666),
                    fontSize: 10,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Input field or dropdown
          if (field.fieldType == 'dropdown' && field.options != null)
            _buildDropdown(context)
          else
            TextField(
              controller: controller,
              onChanged: onChanged,
              style: GoogleFonts.outfit(
                color: hasValue ? const Color(0xFFD4930A) : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hasValue ? null : 'Enter manually',
                hintStyle: GoogleFonts.outfit(color: const Color(0xFF555555)),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                filled: true,
                fillColor: const Color(0xFF0D0B07),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2A1F10)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2A1F10)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFD4930A)),
                ),
              ),
            ),

          if (!hasValue && field.isRequired) ...[
            const SizedBox(height: 4),
            Text(
              'Not found in documents — enter manually',
              style: GoogleFonts.outfit(
                color: const Color(0xFFE65100),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0B07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A1F10)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value:
              field.options!.contains(controller.text) ? controller.text : null,
          isExpanded: true,
          hint: Text(
            'Select ${field.label}',
            style: GoogleFonts.outfit(color: const Color(0xFF555555)),
          ),
          dropdownColor: const Color(0xFF1A1208),
          style: GoogleFonts.outfit(
            color: const Color(0xFFD4930A),
            fontSize: 14,
          ),
          items: field.options!
              .map((opt) => DropdownMenuItem(
                    value: opt,
                    child: Text(opt),
                  ))
              .toList(),
          onChanged: (val) {
            if (val != null) {
              controller.text = val;
              onChanged(val);
            }
          },
        ),
      ),
    );
  }
}
