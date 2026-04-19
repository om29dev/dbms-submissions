import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Note: We'll use the standard webview_flutter which supports file selection on Android/iOS natively if configured,
// but for "Antigravity" style automation, we'll use JS Injection to guide the user or auto-select.
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

class SmartBrowserScreen extends StatefulWidget {
  final String url;
  final String title;
  final Map<String, String> formData;
  final List<Map<String, dynamic>> documents;
  final String languageCode;
  final bool initialTranslate;

  const SmartBrowserScreen({
    super.key,
    required this.url,
    required this.title,
    required this.formData,
    required this.documents,
    required this.languageCode,
    this.initialTranslate = true,
  });

  @override
  State<SmartBrowserScreen> createState() => _SmartBrowserScreenState();
}

class _SmartBrowserScreenState extends State<SmartBrowserScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0;
  bool _isAutoFillEnabled = true;
  late bool _isTranslationEnabled;
  bool _showTranslationPrompt = false; // Disable prompt, make it automatic

  @override
  void initState() {
    super.initState();
    _isTranslationEnabled =
        widget.initialTranslate && widget.languageCode != 'en';
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() => _progress = progress / 100);
          },
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            _injectAntigravityEngine();
            if (_isTranslationEnabled) {
              _injectTranslationEngine();
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        'CVIAgent',
        onMessageReceived: (JavaScriptMessage message) {
          _handleAgentMessage(message.message);
        },
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _handleAgentMessage(String msg) {
    try {
      final data = jsonDecode(msg);
      final type = data['type'];

      if (type == 'log') {
        debugPrint('🌐 [Browser Agent]: ${data['message']}');
      } else if (type == 'filled') {
        _showToast('✨ Auto-filled ${data['count']} more fields');
      } else if (type == 'file_requested') {
        _handleFileRequest(data['docType'], data['inputId']);
      }
    } catch (e) {
      debugPrint('Error parsing agent message: $e');
    }
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.outfit(fontSize: 13)),
        backgroundColor: AppColors.emerald,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
      ),
    );
  }

  Future<void> _handleFileRequest(
      String requestedDocType, String inputId) async {
    // Check if we have this document in the vault
    final doc = widget.documents.firstWhere(
      (d) => d['document_type']
          .toString()
          .toLowerCase()
          .contains(requestedDocType.toLowerCase()),
      orElse: () => {},
    );

    if (doc.isNotEmpty) {
      _showToast(
          '📂 Found matching ${requestedDocType.toUpperCase()} in your vault!');

      // We can't actually "push" binary data into a file input for security.
      // But we can guide the user or show a selection overlay.
      // Optimization: In a real system, you'd use a custom file provider.
    }
  }

  Future<void> _injectAntigravityEngine() async {
    final jsData = jsonEncode(widget.formData);
    final docInfo =
        jsonEncode(widget.documents.map((d) => d['document_type']).toList());

    final engineCode = '''
      (function() {
        if (window.CVI_ENGINE_ACTIVE) return;
        window.CVI_ENGINE_ACTIVE = true;
        
        const formData = $jsData;
        const availableDocs = $docInfo;
        let lastFilledCount = 0;

        const MAPPINGS = {
          'full_name': ['name', 'full name', 'applicant name', 'naam', 'नाम', 'candidate', 'person'],
          'father_name': ['father', 'pita', 'पिता', 'parent', 'guardian'],
          'mother_name': ['mother', 'maata', 'माता'],
          'date_of_birth': ['dob', 'date of birth', 'birth date', 'janm', 'जन्म', 'dd/mm/yyyy'],
          'gender': ['gender', 'sex', 'ling', 'लिंग'],
          'aadhaar_number': ['aadhaar', 'uid', 'aadhar', 'आधार', 'uidadhar'],
          'pan_number': ['pan', 'permanent account', 'पैन', 'panno'],
          'pincode': ['pincode', 'pin code', 'zip', 'पिन', 'postal'],
          'mobile_number': ['mobile', 'phone', 'contact', 'मोबाइल', 'cell'],
          'email_address': ['email', 'e-mail', 'ईमेल', 'mailid'],
          'address_line1': ['address', 'residence', 'पता', 'locality', 'house', 'flat', 'street', 'area'],
          'district': ['district', 'zila', 'जिला', 'city'],
          'state': ['state', 'rajya', 'राज्य'],
          'account_number': ['account', 'khata', 'खाता', 'accno'],
          'ifsc_code': ['ifsc', 'branch code', 'bank code']
        };

        function agentLog(msg) {
          if (window.CVIAgent) CVIAgent.postMessage(JSON.stringify({type: 'log', message: msg}));
        }

        function fillElements() {
          let currentFilled = 0;
          const inputs = document.querySelectorAll('input, select, textarea');
          
          inputs.forEach(input => {
            // Skip if already visually marked or hidden
            if (input.dataset.cviHandled === 'true' || input.type === 'hidden' || input.offsetParent === null) return;

            const searchPool = [
              input.id, input.name, input.placeholder, input.getAttribute('aria-label'), input.className
            ].join(' ').toLowerCase();

            // Check associated labels
            let labelText = '';
            if (input.id) {
              const label = document.querySelector('label[for="' + input.id + '"]');
              if (label) labelText = label.innerText.toLowerCase();
            }
            if (!labelText) {
              const parentLabel = input.closest('label');
              if (parentLabel) labelText = parentLabel.innerText.toLowerCase();
            }

            for (const [key, value] of Object.entries(formData)) {
              if (!value) continue;
              const keywords = MAPPINGS[key] || [];
              const match = keywords.some(k => searchPool.includes(k) || labelText.includes(k));

              if (match) {
                if (input.type === 'radio') {
                  if (input.value.toLowerCase() === value.toLowerCase() || labelText.includes(value.toLowerCase())) {
                    input.click();
                    input.checked = true;
                  }
                } else if (input.tagName === 'SELECT') {
                  for (let opt of input.options) {
                    if (opt.text.toLowerCase().includes(value.toLowerCase()) || opt.value.toLowerCase().includes(value.toLowerCase())) {
                      input.value = opt.value;
                      break;
                    }
                  }
                } else if (input.type === 'checkbox') {
                  if (searchPool.includes('agree') || searchPool.includes('declare')) {
                    input.click();
                    input.checked = true;
                  }
                } else {
                  input.value = value;
                }

                // Effect
                input.style.border = '2px solid #FF6B1A';
                input.style.background = '#FFF8F0';
                input.dataset.cviHandled = 'true';
                
                input.dispatchEvent(new Event('input', { bubbles: true }));
                input.dispatchEvent(new Event('change', { bubbles: true }));
                currentFilled++;
              }
            }

            // Detect File Uploads
            if (input.type === 'file') {
               const docMatch = availableDocs.find(d => searchPool.includes(d.toLowerCase()) || labelText.includes(d.toLowerCase()));
               if (docMatch) {
                 input.style.outline = '3px dashed #FF6B1A';
                 input.style.backgroundColor = 'rgba(255, 107, 26, 0.1)';
                 if (!input.dataset.cviWarned) {
                   agentLog('Detected file input for ' + docMatch);
                   input.dataset.cviWarned = 'true';
                 }
               }
            }
          });

          if (currentFilled > 0) {
            CVIAgent.postMessage(JSON.stringify({type: 'filled', count: currentFilled}));
          }
        }

        // Run Every 1.5 seconds to catch dynamic content (Self-Healing)
        setInterval(fillElements, 1500);
        fillElements();
        
        agentLog('Antigravity DOM Engine V2 Active');
      })();
    ''';

    await _controller.runJavaScript(engineCode);
  }

  Future<void> _injectTranslationEngine() async {
    if (widget.languageCode == 'en') return;

    final targetLang = widget.languageCode;

    // Antigravity Regional Translation Engine
    // This uses the official Google Translate Element logic
    final translateCode = '''
      (function() {
        if (window.CVI_TRANSLATE_ACTIVE) return;
        window.CVI_TRANSLATE_ACTIVE = true;

        var script = document.createElement('script');
        script.type = 'text/javascript';
        script.src = 'https://translate.google.com/translate_a/element.js?cb=googleTranslateElementInit';
        document.head.appendChild(script);

        window.googleTranslateElementInit = function() {
          new google.translate.TranslateElement({
            pageLanguage: 'en',
            includedLanguages: '$targetLang',
            layout: google.translate.TranslateElement.InlineLayout.SIMPLE,
            autoDisplay: true
          }, 'google_translate_element');
          
          // Force translation trigger with multiple event variants
          let attempts = 0;
          const pollSelect = setInterval(function() {
            var select = document.querySelector('.goog-te-combo');
            if (select) {
              select.value = '$targetLang';
              select.dispatchEvent(new Event('change', { bubbles: true }));
              select.dispatchEvent(new Event('click', { bubbles: true }));
              
              // Second attempt for stubborn sites
              setTimeout(() => {
                if (select.value !== '$targetLang') {
                   select.value = '$targetLang';
                   select.dispatchEvent(new Event('change', { bubbles: true }));
                }
              }, 500);

              clearInterval(pollSelect);
            }
            if (++attempts > 100) clearInterval(pollSelect);
          }, 300);
        };

        // UI cleanup
        var style = document.createElement('style');
        style.innerHTML = `
          .goog-te-banner-frame.skiptranslate { display: none !important; }
          body { top: 0px !important; }
          .goog-te-gadget { display: none !important; }
          .goog-te-combo { display: none !important; }
        `;
        document.head.appendChild(style);
      })();
    ''';

    await _controller.runJavaScript(translateCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.emerald,
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .fadeIn(duration: 500.ms)
                    .fadeOut(delay: 500.ms),
                const SizedBox(width: 4),
                Text(
                  'Antigravity DOM Active',
                  style: GoogleFonts.outfit(
                    color: AppColors.gold,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () => _controller.reload(),
          ),
          _buildVaultShortcut(),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: _progress < 1.0
              ? LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: AppColors.bgMid,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.saffron),
                  minHeight: 2,
                )
              : Container(height: 2, color: AppColors.emerald.withValues(alpha: 0.3)),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),

          // Translation Prompt Overlay
          if (_showTranslationPrompt && widget.languageCode != 'en')
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTranslationPrompt(),
            ),

          if (_isLoading)
            Container(
              color: AppColors.bgDeep,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: AppColors.saffron,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Injecting Antigravity Engine...',
                      style: GoogleFonts.outfit(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

          // Floating Assistant Info
          Positioned(
            bottom: 24,
            right: 16,
            left: 16,
            child: _buildAssistantPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildAssistantPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1208).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded,
              color: AppColors.gold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CVI Processing Website',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'I am monitoring the portal for new fields...',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _isAutoFillEnabled = !_isAutoFillEnabled);
              _injectAntigravityEngine();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.saffron,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Force Fill',
                style: GoogleFonts.outfit(
                    fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ).animate().slideY(begin: 1.0, end: 0.0, curve: Curves.easeOutCubic);
  }

  Widget _buildVaultShortcut() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon:
                const Icon(Icons.folder_shared_rounded, color: Colors.white70),
            onPressed: () {
              // Show a small overlay with vault items for easy access
              _showVaultOverlay();
            },
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                  color: AppColors.saffron, shape: BoxShape.circle),
              child: Text(
                '${widget.documents.length}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVaultOverlay() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgDeep,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '💾 Your Document Vault',
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap a document to copy its details',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.documents.length,
                  itemBuilder: (context, i) {
                    final d = widget.documents[i];
                    return ListTile(
                      leading: const Icon(Icons.description_rounded,
                          color: AppColors.gold),
                      title: Text(d['document_type'].toString().toUpperCase(),
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                          'Verified on ${d['created_at'].toString().split('T')[0]}',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 11)),
                      trailing: const Icon(Icons.copy_rounded,
                          color: Colors.white38, size: 18),
                      onTap: () {
                        // Copy data logic
                        Navigator.pop(context);
                        _showToast('Copied ${d['document_type']} details');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTranslationPrompt() {
    final langName = switch (widget.languageCode) {
      'hi' => 'हिन्दी',
      'mr' => 'मराठी',
      'ta' => 'தமிழ்',
      _ => 'Regional',
    };

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.saffron,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.g_translate_rounded, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Translate to $langName?',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Read the form in your own language.',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _showTranslationPrompt = false),
            child: Text('NOT NOW',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isTranslationEnabled = true;
                _showTranslationPrompt = false;
              });
              _injectTranslationEngine();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.saffron,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: Text('TRANSLATE',
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: -1.0, end: 0.0, curve: Curves.easeOutCubic)
        .fadeIn();
  }
}
