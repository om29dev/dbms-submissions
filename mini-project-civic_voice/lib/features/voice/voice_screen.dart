import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/conversation_model.dart';
import '../../providers/conversation_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/voice_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../widgets/decorative/chakra_painter.dart';
import '../../widgets/decorative/tricolor_bar.dart';
import '../../models/service_model.dart';
import '../../providers/citizen_profile_provider.dart';
import '../../providers/document_vault_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// VOICE SCREEN — Bharat Silicon Design
// ═══════════════════════════════════════════════════════════════════════════════

class VoiceScreen extends StatefulWidget {
  final ServiceModel? scheme;
  const VoiceScreen({super.key, this.scheme});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _textCtrl = TextEditingController();
  bool _showTextInput = false;

  late AnimationController _micPulseOuter;
  late AnimationController _micPulseInner;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _micPulseOuter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _micPulseInner = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Initialize Scheme Context if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.scheme != null) {
        _initializeSchemeContext();
      }
    });
  }

  void _initializeSchemeContext() {
    final conv = context.read<ConversationProvider>();
    final citizen = context.read<CitizenProfileProvider>();
    final vault = context.read<DocumentVaultProvider>();

    conv.setSchemeGuidanceContext(
      scheme: widget.scheme!,
      userProfile: citizen.profile?.toJson(),
      documents: vault.documents
          .map((d) => d['document_type'] as String? ?? '')
          .toList(),
    );

    // Trigger an invisible initial prompt to the AI to introduce itself in context
    final prompt = context.read<LanguageProvider>().languageCode == 'hi'
        ? 'कृपया अपना परिचय दें और मुझे बताएं कि आप ${widget.scheme!.name} के बारे में मेरी कैसे मदद कर सकते हैं।'
        : 'Please introduce yourself and tell me how you can help me with the ${widget.scheme!.name} scheme.';

    conv.sendMessage(prompt);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _textCtrl.dispose();
    _micPulseOuter.dispose();
    _micPulseInner.dispose();
    super.dispose();
  }

  Future<void> _scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 80));
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Sends recognized text to the conversation provider.
  Future<void> _handleRecognizedText(String text) async {
    final conv = context.read<ConversationProvider>();
    final voice = context.read<VoiceProvider>();

    if (text.isEmpty || conv.isLoading) return;

    debugPrint('[VoiceScreen] Sending recognized text: "$text"');
    context.read<AnalyticsProvider>().incrementVoiceQuery();
    try {
      await conv.sendMessage(text);
    } finally {
      if (mounted) voice.setIdle();
    }
    _scrollToBottom();
    if (mounted && voice.isTTSEnabled) {
      final msgs = conv.messages;
      if (msgs.isNotEmpty && !msgs.last.isUser) {
        await voice.speak(msgs.last.text);
      }
    }
  }

  Future<void> _onMicTap() async {
    final voice = context.read<VoiceProvider>();
    final lang = context.read<LanguageProvider>().currentLanguage;

    HapticFeedback.mediumImpact();

    debugPrint('[VoiceScreen] Mic tapped. Voice state: ${voice.state}');

    switch (voice.state) {
      case VoiceState.idle:
      case VoiceState.permissionDenied:
      case VoiceState.unavailable:
        debugPrint('[VoiceScreen] Starting listening...');
        await voice.startListening(
          localeId: _localeId(lang),
          onFinalResult: (text) async {
            // Auto-send when speech naturally ends (user stops talking)
            debugPrint('[VoiceScreen] Auto-send triggered with: "$text"');
            await _handleRecognizedText(text);
          },
        );
        break;

      case VoiceState.listening:
        await voice.stopListening();
        final text = voice.transcribedText.isNotEmpty
            ? voice.transcribedText
            : voice.partialText;
        debugPrint('[VoiceScreen] Manual stop. Text: "$text"');
        await _handleRecognizedText(text);
        break;

      case VoiceState.speaking:
        await voice.stopSpeaking();
        break;

      case VoiceState.processing:
      case VoiceState.responding:
      case VoiceState.error:
        debugPrint('[VoiceScreen] Resetting from ${voice.state} to idle.');
        voice.setIdle();
        break;
    }
  }

  Future<void> _sendText() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    _textCtrl.clear();
    final conv = context.read<ConversationProvider>();
    final voice = context.read<VoiceProvider>();
    context.read<AnalyticsProvider>().incrementVoiceQuery();
    await conv.sendMessage(text);
    _scrollToBottom();
    if (voice.isTTSEnabled && mounted) {
      final msgs = conv.messages;
      if (msgs.isNotEmpty && !msgs.last.isUser) {
        await voice.speak(msgs.last.text);
      }
    }
  }

  String _localeId(String lang) => switch (lang) {
        'hi' => 'hi_IN',
        'mr' => 'mr_IN',
        'ta' => 'ta_IN',
        _ => 'en_IN',
      };

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final voice = context.watch<VoiceProvider>();
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final conv = context.watch<ConversationProvider>();

    final isListening = voice.state == VoiceState.listening;
    final isProcessing = voice.state == VoiceState.processing ||
        voice.state == VoiceState.responding;
    final isSpeaking = voice.state == VoiceState.speaking;

    if (conv.hasMessages) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          // Chakra watermark
          const Center(
            child: ChakraPainterWidget(
              size: 340,
              opacity: 0.05,
              color: AppColors.gold,
              rotationSeconds: 20,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Tricolor bar
                const TricolorBar(height: 2),

                // Top bar
                _TopBar(lang: lang),

                // Conversation area
                Expanded(
                  child: _ConversationArea(
                    conv: conv,
                    lang: lang,
                    scrollCtrl: _scrollCtrl,
                    voice: voice,
                    outerPulse: _micPulseOuter,
                    innerPulse: _micPulseInner,
                    onMicTap: _onMicTap,
                    isListening: isListening,
                    isProcessing: isProcessing,
                    isSpeaking: isSpeaking,
                  ),
                ),

                // Bottom input
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: _showTextInput
                      ? _TextBar(
                          key: const ValueKey('text'),
                          ctrl: _textCtrl,
                          onSend: _sendText,
                          onClose: () => setState(() => _showTextInput = false),
                        )
                      : _BottomMicBar(
                          key: const ValueKey('mic'),
                          voice: voice,
                          onMicTap: _onMicTap,
                          onTextToggle: () =>
                              setState(() => _showTextInput = true),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TOP BAR
// ═══════════════════════════════════════════════════════════════════════════════

class _TopBar extends StatelessWidget {
  final String lang;
  static const _codes = ['en', 'hi', 'mr', 'ta'];
  static const _labels = ['EN', 'HI', 'MR', 'TA'];

  const _TopBar({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: AppColors.textSecondary, size: 20),
            onPressed: () {
              context.read<VoiceProvider>().stopSpeaking();
              Navigator.of(context).maybePop();
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        context.watch<ConversationProvider>().isSchemeMode
                            ? 'Scheme Advisor'
                            : 'CVI Voice',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (context.watch<ConversationProvider>().isSchemeMode) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: AppColors.emerald.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          'SPECIALIST',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.emerald,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  context.watch<ConversationProvider>().isSchemeMode
                      ? context.watch<ConversationProvider>().activeSchemeName
                      : (context.watch<LanguageProvider>().languageCode == 'hi'
                          ? 'कोई भी सरकारी सेवा के बारे में पूछें'
                          : 'Ask about any government service'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.watch<LanguageProvider>().languageCode == 'hi'
                      ? GoogleFonts.notoSansDevanagari(
                          fontSize: 9, color: AppColors.textMuted)
                      : GoogleFonts.poppins(
                          fontSize: 9, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          // Language pill
          Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: AppColors.bgMid,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(4, (i) {
                final active = _codes[i] == lang;
                return GestureDetector(
                  onTap: () {
                    final lp = context.read<LanguageProvider>();
                    lp.switchLanguage(_codes[i]);
                    context.read<ConversationProvider>().setLanguage(_codes[i]);
                    context.read<VoiceProvider>().setLanguage(_codes[i]);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: active ? AppColors.saffron : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      _labels[i],
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: active ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.textMuted, size: 20),
            onPressed: () {
              context.read<ConversationProvider>().clearConversation();
              context.read<VoiceProvider>().clearTranscription();
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CONVERSATION AREA
// ═══════════════════════════════════════════════════════════════════════════════

class _ConversationArea extends StatelessWidget {
  final ConversationProvider conv;
  final String lang;
  final ScrollController scrollCtrl;
  final VoiceProvider voice;
  final AnimationController outerPulse;
  final AnimationController innerPulse;
  final VoidCallback onMicTap;
  final bool isListening;
  final bool isProcessing;
  final bool isSpeaking;

  const _ConversationArea({
    required this.conv,
    required this.lang,
    required this.scrollCtrl,
    required this.voice,
    required this.outerPulse,
    required this.innerPulse,
    required this.onMicTap,
    required this.isListening,
    required this.isProcessing,
    required this.isSpeaking,
  });

  @override
  Widget build(BuildContext context) {
    if (!conv.hasMessages && !conv.isLoading) {
      // Idle state — greeting + mic
      return Consumer<ConversationProvider>(
        builder: (context, conv, _) => SingleChildScrollView(
          child: Column(
            children: [
              // Greeting section — isolated repaint boundary
              RepaintBoundary(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.watch<LanguageProvider>().languageCode == 'hi'
                            ? 'नमस्ते! मैं CVI हूं'
                            : 'Hello! I am CVI',
                        style: context.watch<LanguageProvider>().languageCode ==
                                'hi'
                            ? GoogleFonts.notoSansDevanagari(
                                fontSize: 14,
                                color: AppColors.gold,
                                fontWeight: FontWeight.w500,
                              )
                            : GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.gold,
                                fontWeight: FontWeight.w600,
                              ),
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 4),
                      Text(
                        context.watch<LanguageProvider>().languageCode == 'hi'
                            ? 'मैं आपकी कैसे सहायता कर सकता हूं?'
                            : 'How can I help you today?',
                        style: context.watch<LanguageProvider>().languageCode ==
                                'hi'
                            ? GoogleFonts.notoSansDevanagari(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              )
                            : GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms)
                          .slideY(begin: 0.05, end: 0),
                      const SizedBox(height: 12),
                      // Suggestion chips — no per-chip animations
                      RepaintBoundary(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              for (final (i, chip) in [
                                'Passport apply?',
                                'Aadhaar update?',
                                'PAN card?',
                              ].indexed)
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: 8, left: i == 0 ? 0 : 0),
                                  child: GestureDetector(
                                    onTap: () => conv.sendMessage(chip),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 150),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.bgMid,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: AppColors.saffron
                                                .withValues(alpha: 0.6),
                                            width: 1),
                                      ),
                                      child: Text(
                                        chip,
                                        style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500),
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
                ),
              ),
              // Big mic with padding to ensure visibility
              const SizedBox(height: 40),
              _IdleMic(
                outerPulse: outerPulse,
                innerPulse: innerPulse,
                onMicTap: onMicTap,
                isListening: isListening,
                isProcessing: isProcessing,
              ),
              const SizedBox(height: 80), // Bottom breathing room for keyboard
            ],
          ),
        ),
      );
    }

    // Conversation mode
    return ListView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      physics: const BouncingScrollPhysics(),
      itemCount: conv.messages.length + (conv.isLoading ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == conv.messages.length) {
          return const _TypingBubble();
        }
        final msg = conv.messages[i].toModel();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child:
              msg.isUser ? _UserBubble(message: msg) : _BotBubble(message: msg),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// IDLE MIC
// ═══════════════════════════════════════════════════════════════════════════════

class _IdleMic extends StatelessWidget {
  final AnimationController outerPulse;
  final AnimationController innerPulse;
  final VoidCallback onMicTap;
  final bool isListening;
  final bool isProcessing;

  const _IdleMic({
    required this.outerPulse,
    required this.innerPulse,
    required this.onMicTap,
    required this.isListening,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isListening
        ? AppColors.emerald
        : isProcessing
            ? AppColors.gold
            : AppColors.saffron;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Rings + button
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              AnimatedBuilder(
                animation: outerPulse,
                builder: (_, __) => Container(
                  width: 160 + outerPulse.value * 10,
                  height: 160 + outerPulse.value * 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activeColor.withValues(
                        alpha: 0.06 + outerPulse.value * 0.04),
                  ),
                ),
              ),
              // Middle ring
              AnimatedBuilder(
                animation: innerPulse,
                builder: (_, __) => Container(
                  width: 120 + innerPulse.value * 6,
                  height: 120 + innerPulse.value * 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activeColor.withValues(
                        alpha: 0.10 + innerPulse.value * 0.06),
                  ),
                ),
              ),
              // Inner button
              GestureDetector(
                onTap: onMicTap,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isListening
                          ? [AppColors.emerald, const Color(0xFF086030)]
                          : isProcessing
                              ? [AppColors.gold, AppColors.goldLight]
                              : [AppColors.saffron, AppColors.saffronDeep],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.45),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    isProcessing
                        ? Icons.auto_awesome_rounded
                        : Icons.mic_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Status text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Column(
              key: ValueKey(isListening
                  ? 'l'
                  : isProcessing
                      ? 'p'
                      : 'i'),
              children: [
                Text(
                  isListening
                      ? (context.watch<LanguageProvider>().languageCode == 'hi'
                          ? 'सुन रहा हूं...'
                          : 'Listening...')
                      : isProcessing
                          ? (context.watch<LanguageProvider>().languageCode ==
                                  'hi'
                              ? 'CVI सोच रहा है...'
                              : 'CVI is thinking...')
                          : (context.watch<LanguageProvider>().languageCode ==
                                  'hi'
                              ? 'बोलें'
                              : 'Tap to Speak'),
                  style: context.watch<LanguageProvider>().languageCode == 'hi'
                      ? GoogleFonts.notoSansDevanagari(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: isListening
                              ? AppColors.emeraldLight
                              : AppColors.gold,
                        )
                      : GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: isListening
                              ? AppColors.emeraldLight
                              : AppColors.gold,
                        ),
                ),
                if (context.watch<LanguageProvider>().languageCode == 'hi') ...[
                  const SizedBox(height: 4),
                  Text(
                    isListening
                        ? 'सुनना रोकने के लिए टैप करें'
                        : isProcessing
                            ? 'आपके प्रश्न पर कार्रवाई कर रहे हैं...'
                            : 'बोलना शुरू करने के लिए टैप करें',
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                  Text(
                    isListening
                        ? 'Listening... tap to stop'
                        : isProcessing
                            ? 'Processing your query...'
                            : 'Tap to Speak',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Waveform bars
          _WaveformBars(
            active: isListening,
            color: activeColor,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// WAVEFORM BARS
// ═══════════════════════════════════════════════════════════════════════════════

class _WaveformBars extends StatefulWidget {
  final bool active;
  final Color color;
  const _WaveformBars({required this.active, required this.color});

  @override
  State<_WaveformBars> createState() => _WaveformBarsState();
}

class _WaveformBarsState extends State<_WaveformBars> {
  final _heights = List.filled(28, 4.0);
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _animate();
  }

  Future<void> _animate() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      setState(() {
        for (int i = 0; i < 28; i++) {
          _heights[i] = widget.active ? 4 + _rng.nextDouble() * 26 : 4.0;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(28, (i) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            width: 2.5,
            height: _heights[i],
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: widget.active
                  ? widget.color.withValues(alpha: 0.7)
                  : AppColors.surfaceBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CONVERSATION BUBBLES
// ═══════════════════════════════════════════════════════════════════════════════

class _UserBubble extends StatelessWidget {
  final MessageModel message;
  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.75),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.saffron, AppColors.saffronDeep],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.saffron.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.text,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _fmt(message.timestamp),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 250.ms)
        .slideX(begin: 0.1, end: 0, duration: 250.ms);
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _BotBubble extends StatelessWidget {
  final MessageModel message;
  const _BotBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.84),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.bgMid,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            border: Border(
              left: BorderSide(color: AppColors.saffron, width: 3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // AI label
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.saffron, AppColors.gold],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🏛', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'CVI',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.saffron,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  message.text,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _fmt(message.timestamp),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 250.ms)
        .slideX(begin: -0.08, end: 0, duration: 250.ms);
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 1200.ms)..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.bgMid,
          borderRadius: BorderRadius.circular(16),
          border: const Border(
              left: BorderSide(color: AppColors.saffron, width: 3)),
        ),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final phase = (_ctrl.value - i * 0.15).clamp(0.0, 1.0);
                final opacity =
                    (sin(phase * 2 * pi) * 0.5 + 0.5).clamp(0.2, 1.0);
                return Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.saffron.withValues(alpha: opacity),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BOTTOM BARS
// ═══════════════════════════════════════════════════════════════════════════════

class _BottomMicBar extends StatelessWidget {
  final VoiceProvider voice;
  final VoidCallback onMicTap;
  final VoidCallback onTextToggle;

  const _BottomMicBar({
    super.key,
    required this.voice,
    required this.onMicTap,
    required this.onTextToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isListening = voice.state == VoiceState.listening;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.bgMid,
        border:
            Border(top: BorderSide(color: AppColors.surfaceBorder, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Text toggle
            GestureDetector(
              onTap: onTextToggle,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.bgDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: const Icon(Icons.keyboard_alt_outlined,
                    color: AppColors.textMuted, size: 20),
              ),
            ),

            const Spacer(),

            // Central mic
            GestureDetector(
              onTap: onMicTap,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isListening
                        ? [AppColors.emerald, const Color(0xFF086030)]
                        : [AppColors.saffron, AppColors.saffronDeep],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isListening ? AppColors.emerald : AppColors.saffron)
                              .withValues(alpha: 0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  isListening ? Icons.stop_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),

            const Spacer(),

            // TTS toggle
            GestureDetector(
              onTap: () => voice.toggleTTS(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: voice.isTTSEnabled
                      ? AppColors.saffron.withValues(alpha: 0.15)
                      : AppColors.bgDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: voice.isTTSEnabled
                        ? AppColors.saffron.withValues(alpha: 0.4)
                        : AppColors.surfaceBorder,
                  ),
                ),
                child: Icon(
                  voice.isTTSEnabled
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                  color: voice.isTTSEnabled
                      ? AppColors.saffron
                      : AppColors.textMuted,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextBar extends StatelessWidget {
  final TextEditingController ctrl;
  final VoidCallback onSend;
  final VoidCallback onClose;

  const _TextBar({
    super.key,
    required this.ctrl,
    required this.onSend,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.bgMid,
        border:
            Border(top: BorderSide(color: AppColors.surfaceBorder, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: onClose,
              child: const Icon(Icons.arrow_back_ios_rounded,
                  color: AppColors.textMuted, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.bgDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: TextField(
                  controller: ctrl,
                  autofocus: true,
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Type your question...',
                    hintStyle: GoogleFonts.poppins(
                        fontSize: 13, color: AppColors.textMuted),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSend,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.saffron, AppColors.saffronDeep],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
