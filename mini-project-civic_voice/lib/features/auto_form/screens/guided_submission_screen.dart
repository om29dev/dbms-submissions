// ═══════════════════════════════════════════════════════════════════════════════
// GUIDED SUBMISSION SCREEN — WebView with step-by-step guided portal assistant
// ═══════════════════════════════════════════════════════════════════════════════

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:screenshot/screenshot.dart';

import '../../../core/constants/app_colors.dart';
import '../models/auto_form_model.dart';
import '../../voice/widgets/form_help_fab.dart';
import '../../documents/widgets/vault_document_picker.dart';
import '../../../models/cvi_document_model.dart';

// Future AWS Translate integration for portal page translation

class GuidedSubmissionScreen extends StatefulWidget {
  final String url;
  final String title;
  final Map<String, String> formData;
  final List<SubmitStep> submitSteps;
  final String portalName;

  const GuidedSubmissionScreen({
    super.key,
    required this.url,
    required this.title,
    required this.formData,
    this.submitSteps = const [],
    this.portalName = '',
  });

  @override
  State<GuidedSubmissionScreen> createState() => _GuidedSubmissionScreenState();
}

class _GuidedSubmissionScreenState extends State<GuidedSubmissionScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isPanelExpanded = true;
  int _currentStep = 0;
  bool _showDataPanel = false;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) {
            setState(() => _isLoading = false);
            // Inject Google Translate script when page finishes loading
            _injectGoogleTranslate();
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Screenshot(
        controller: _screenshotController,
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              if (_isPanelExpanded) _buildGuidedPanel(),
              if (_showDataPanel) _buildDataPanel(),
              // Loading indicator
              if (_isLoading)
                const LinearProgressIndicator(
                  color: AppColors.saffron,
                  backgroundColor: AppColors.bgDark,
                  minHeight: 3,
                ),
              // WebView
              Expanded(
                child: WebViewWidget(controller: _controller),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FormHelpFab(
        screenshotController: _screenshotController,
        formContext: 'guided generic form webview step \${_currentStep + 1}',
      ),
    );
  }

  // ─── Injection & Auto-Fill Methods ─────────────────────────────────────────

  void _injectGoogleTranslate() {
    // Inject the Google Translate Element script and add a container for it if missing.
    const script = '''
      (function() {
        if (document.getElementById('google_translate_element')) return; // Already exists
        
        // Create an invisible container for the Google Translate widget
        var gtContainer = document.createElement('div');
        gtContainer.id = 'google_translate_element';
        
        // Hide it visually but keep it "rendered" so Google script doesn't abort
        // Positioning it explicitly at 0,0 but invisible guarantees it isn't skipped by Intersection Observers
        gtContainer.style.position = 'fixed';
        gtContainer.style.top = '0px';
        gtContainer.style.left = '0px';
        gtContainer.style.width = '1px';
        gtContainer.style.height = '1px';
        gtContainer.style.opacity = '0.00001';
        gtContainer.style.pointerEvents = 'none';
        gtContainer.style.zIndex = '-9999';

        document.documentElement.appendChild(gtContainer);

        // Define init function
        window.googleTranslateElementInit = function() {
          new google.translate.TranslateElement({
            pageLanguage: 'en', 
            layout: google.translate.TranslateElement.InlineLayout.SIMPLE
          }, 'google_translate_element');
        };

        // Load translate script
        var gtScript = document.createElement('script');
        gtScript.type = 'text/javascript';
        gtScript.src = 'https://translate.google.com/translate_a/element.js?cb=googleTranslateElementInit';
        document.documentElement.appendChild(gtScript);
      })();
    ''';
    _controller.runJavaScript(script);
  }

  void _translateWebPage(String langCode) {
    // robust method to trigger translation, handling async loading of the combo box
    // and ensuring the framework registers the change
    final script = '''
      function triggerTranslation() {
        var selectElement = document.querySelector('.goog-te-combo');
        if (selectElement) {
           selectElement.value = '$langCode';
           if (typeof document.createEvent === 'function') {
               var evt = document.createEvent('HTMLEvents');
               evt.initEvent('change', true, true);
               selectElement.dispatchEvent(evt);
           } else {
               selectElement.dispatchEvent(new Event('change', { bubbles: true }));
           }
        } else {
           // If the combo box hasn't loaded yet, try again in a bit
           setTimeout(triggerTranslation, 500);
        }
      }
      triggerTranslation();
    ''';
    _controller.runJavaScript(script);
  }

  Future<void> _autoFillForm() async {
    // Check if form data is empty
    if (widget.formData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No profile data available to auto-fill.')),
      );
      return;
    }

    // Convert map to JSON string securely
    final jsonDataString = jsonEncode(widget.formData);

    final jsPayload = '''
      (function(dataJsonString) {
        var userData = JSON.parse(dataJsonString);
        var inputs = document.querySelectorAll('input, select, textarea');
        var fillCount = 0;

          // Heuristics to map user profile fields to HTML names/IDs
        for (var i = 0; i < inputs.length; i++) {
          var input = inputs[i];
          // Skip hidden or non-editable fields
          if (input.type === 'hidden' || input.type === 'submit' || input.type === 'button' || input.disabled) continue;

          var identifier = (input.name + ' ' + input.id + ' ' + input.placeholder + ' ' + input.className).toLowerCase();
          
          var hasFilled = false;
          var valToFill = "";

          // Intelligent Heuristics 
          if ((identifier.includes('firstname') || identifier.includes('fname') || identifier.includes('first name') || identifier.match(/\\bf_name\\b/)) && userData['firstname']) { 
             valToFill = userData['firstname']; hasFilled = true; 
          }
          else if ((identifier.includes('lastname') || identifier.includes('lname') || identifier.includes('last name') || identifier.includes('surname') || identifier.match(/\\bl_name\\b/)) && userData['lastname']) { 
             valToFill = userData['lastname']; hasFilled = true; 
          }
          else if ((identifier.includes('fullname') || identifier.includes('full name') || identifier.match(/\\bname\\b/)) && userData['full_name']) {
             valToFill = userData['full_name']; hasFilled = true;
          }
          else if ((identifier.includes('phone') || identifier.includes('mobile') || identifier.includes('contact') || identifier.includes('tel') || identifier.includes('cell')) && userData['mobile_number']) { 
             valToFill = userData['mobile_number']; hasFilled = true; 
          }
          else if ((identifier.includes('mail') || identifier.includes('email') || identifier.includes('e-mail')) && userData['email']) { 
             valToFill = userData['email']; hasFilled = true; 
          }
          else if ((identifier.includes('aadhar') || identifier.includes('uidai') || identifier.includes('aadhaar')) && userData['aadhaar']) { 
             valToFill = userData['aadhaar']; hasFilled = true; 
          }
          else if ((identifier.includes('pan') || identifier.includes('pancard') || identifier.includes('pan_no')) && userData['pan']) { 
             valToFill = userData['pan']; hasFilled = true; 
          }
          else {
             // Fallback matching
             for (var key in userData) {
                if (!userData[key] || userData[key].toString().trim() === '') continue;
                
                var searchKey = key.toLowerCase().replace(/_/g, '');
                var altSearchKey = key.toLowerCase().replace(/_/g, ' ');
                
                if (searchKey.length > 2 && (identifier.includes(searchKey) || identifier.includes(altSearchKey))) {
                   valToFill = userData[key];
                   hasFilled = true;
                   break;
                }
             }
          }
          
          if (hasFilled && valToFill) {
            input.value = valToFill;
            // Dispatch events to trigger JS frameworks (React/Angular) 
            input.dispatchEvent(new Event('input', { bubbles: true }));
            input.dispatchEvent(new Event('change', { bubbles: true }));
            
            // Visual feedback
            input.style.backgroundColor = '#FEF3C7'; // Pale saffron highlight
            input.style.border = '1px solid #F59E0B';
            fillCount++;
          }
        }
        return fillCount;
      })('$jsonDataString');
    ''';

    try {
      final result = await _controller.runJavaScriptReturningResult(jsPayload);
      final int filledCount = int.tryParse(result.toString()) ?? 0;

      if (mounted) {
        if (filledCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✨ AI Auto-Filled $filledCount fields!'),
              backgroundColor: AppColors.emeraldLight,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No matching fields found to auto-fill.'),
              backgroundColor: AppColors.textMuted,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Auto-fill JS Error: \$e");
    }
  }

  // ─── Top Bar ────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.portalName,
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Guided Submission Assistant',
                  style: GoogleFonts.poppins(
                    color: AppColors.gold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Language Translator
          PopupMenuButton<String>(
            icon: const Icon(Icons.translate_rounded,
                color: AppColors.saffron, size: 20),
            tooltip: 'Translate Webpage',
            color: AppColors.bgMid,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (context) => const [
              PopupMenuItem(
                  value: 'en',
                  child: Text('English',
                      style: TextStyle(color: AppColors.textPrimary))),
              PopupMenuItem(
                  value: 'hi',
                  child: Text('Hindi',
                      style: TextStyle(color: AppColors.textPrimary))),
              PopupMenuItem(
                  value: 'mr',
                  child: Text('Marathi',
                      style: TextStyle(color: AppColors.textPrimary))),
              PopupMenuItem(
                  value: 'ta',
                  child: Text('Tamil',
                      style: TextStyle(color: AppColors.textPrimary))),
              PopupMenuItem(
                  value: 'te',
                  child: Text('Telugu',
                      style: TextStyle(color: AppColors.textPrimary))),
              PopupMenuItem(
                  value: 'bn',
                  child: Text('Bengali',
                      style: TextStyle(color: AppColors.textPrimary))),
              PopupMenuItem(
                  value: 'gu',
                  child: Text('Gujarati',
                      style: TextStyle(color: AppColors.textPrimary))),
              PopupMenuItem(
                  value: 'kn',
                  child: Text('Kannada',
                      style: TextStyle(color: AppColors.textPrimary))),
              PopupMenuItem(
                  value: 'ml',
                  child: Text('Malayalam',
                      style: TextStyle(color: AppColors.textPrimary))),
            ],
            onSelected: _translateWebPage,
          ),
          // Toggle guide panel
          IconButton(
            icon: Icon(
              _isPanelExpanded
                  ? Icons.expand_less_rounded
                  : Icons.expand_more_rounded,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Toggle Guide',
            onPressed: () =>
                setState(() => _isPanelExpanded = !_isPanelExpanded),
          ),
          // Toggle data panel
          IconButton(
            icon: Icon(
              Icons.content_copy_rounded,
              color:
                  _showDataPanel ? AppColors.saffron : AppColors.textSecondary,
              size: 20,
            ),
            tooltip: 'Your Data',
            onPressed: () => setState(() => _showDataPanel = !_showDataPanel),
          ),
          // Access Vault
          IconButton(
            icon: const Icon(Icons.folder_shared_rounded,
                color: AppColors.saffron, size: 20),
            tooltip: 'Access Vault',
            onPressed: () {
              final isPan = widget.portalName.toLowerCase().contains('pan') ||
                  widget.portalName.toLowerCase().contains('protean') ||
                  widget.portalName.toLowerCase().contains('nsdl');

              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => VaultDocumentPicker(
                  requiredTypes: isPan ? [DocumentType.aadhaar] : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── Guided Steps Panel ─────────────────────────────────────────────────────

  Widget _buildGuidedPanel() {
    if (widget.submitSteps.isEmpty) return const SizedBox();

    return Container(
      constraints: const BoxConstraints(maxHeight: 160),
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.assistant_rounded,
                  color: AppColors.gold, size: 16),
              const SizedBox(width: 6),
              Text(
                'Step ${_currentStep + 1} of ${widget.submitSteps.length}',
                style: GoogleFonts.poppins(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.submitSteps[_currentStep].getInstruction('en'),
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          // Step navigation
          Row(
            children: [
              if (_currentStep > 0)
                _StepButton(
                  label: '← Previous',
                  onTap: () => setState(() => _currentStep--),
                ),
              const SizedBox(width: 8),
              if (widget.formData.isNotEmpty)
                ActionChip(
                  label: Text('✨ Auto-Fill',
                      style: GoogleFonts.poppins(
                          fontSize: 11, fontWeight: FontWeight.w600)),
                  backgroundColor: AppColors.saffron.withValues(alpha: 0.2),
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: VisualDensity.compact,
                  onPressed: _autoFillForm,
                ),
              const Spacer(),
              if (_currentStep < widget.submitSteps.length - 1)
                _StepButton(
                  label: 'Next Step →',
                  isPrimary: true,
                  onTap: () => setState(() => _currentStep++),
                ),
              if (_currentStep == widget.submitSteps.length - 1)
                _StepButton(
                  label: '✓ Done',
                  isPrimary: true,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '🎉 Submission process complete!',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        backgroundColor: AppColors.emeraldLight,
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: -0.3, duration: 300.ms, curve: Curves.easeOut);
  }

  // ─── Data Panel with Copy Buttons ───────────────────────────────────────────

  Widget _buildDataPanel() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Row(
              children: [
                const Icon(Icons.data_object_rounded,
                    color: AppColors.saffron, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Your Pre-filled Data',
                  style: GoogleFonts.poppins(
                    color: AppColors.saffron,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  'Tap to copy',
                  style: GoogleFonts.poppins(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              shrinkWrap: true,
              itemCount: widget.formData.entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final entry = widget.formData.entries.elementAt(index);
                return _CopyableDataRow(
                  label: _humanizeKey(entry.key),
                  value: entry.value,
                );
              },
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    ).animate().slideY(begin: -0.3, duration: 300.ms, curve: Curves.easeOut);
  }

  /// Turn data_key_name into "Data Key Name"
  String _humanizeKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map(
            (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }
}

// ── Step Button ─────────────────────────────────────────────────────────────

class _StepButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _StepButton({
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.saffron : AppColors.bgMid,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isPrimary ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ── Copyable Data Row ─────────────────────────────────────────────────────

class _CopyableDataRow extends StatefulWidget {
  final String label;
  final String value;

  const _CopyableDataRow({required this.label, required this.value});

  @override
  State<_CopyableDataRow> createState() => _CopyableDataRowState();
}

class _CopyableDataRowState extends State<_CopyableDataRow> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: widget.value));
        setState(() => _copied = true);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) setState(() => _copied = false);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _copied
              ? AppColors.emeraldLight.withValues(alpha: 0.08)
              : AppColors.bgMid,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _copied
                ? AppColors.emeraldLight.withValues(alpha: 0.3)
                : AppColors.surfaceBorder,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: GoogleFonts.poppins(
                        color: AppColors.textMuted, fontSize: 10),
                  ),
                  Text(
                    widget.value,
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              _copied ? Icons.check_circle_rounded : Icons.copy_rounded,
              color: _copied ? AppColors.emeraldLight : AppColors.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
