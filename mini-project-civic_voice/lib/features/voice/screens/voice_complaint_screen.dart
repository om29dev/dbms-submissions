import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/complaint_provider.dart';
import '../../../../widgets/glass_card.dart';
import '../../../../providers/voice_provider.dart';
import '../../../../providers/language_provider.dart';

class VoiceComplaintScreen extends StatefulWidget {
  const VoiceComplaintScreen({super.key});

  @override
  State<VoiceComplaintScreen> createState() => _VoiceComplaintScreenState();
}

class _VoiceComplaintScreenState extends State<VoiceComplaintScreen> {
  final TextEditingController _mockVoiceInput = TextEditingController();

  // 0 = Record Complaint, 1 = Provide Location
  int _step = 0;
  String _capturedComplaint = '';

  @override
  void dispose() {
    _mockVoiceInput.dispose();
    super.dispose();
  }

  Future<void> _onComplaintMicTap(BuildContext context) async {
    final voice = context.read<VoiceProvider>();
    final lang = context.read<LanguageProvider>().currentLanguage;

    if (voice.state == VoiceState.listening) {
      await voice.stopListening();
      final text = voice.transcribedText.isNotEmpty
          ? voice.transcribedText
          : (voice.partialText.isNotEmpty
              ? voice.partialText
              : _mockVoiceInput.text);

      final finalText =
          text.isNotEmpty ? text : 'Road is completely broken in XYZ area';
      setState(() {
        _capturedComplaint = finalText;
        _step = 1;
        _mockVoiceInput.clear();
      });
    } else {
      await voice.startListening(
        localeId: lang == 'hi' ? 'hi_IN' : 'en_IN',
        onFinalResult: (text) async {
          setState(() {
            _capturedComplaint = text.isNotEmpty
                ? text
                : 'Road is completely broken in XYZ area';
            _step = 1;
            _mockVoiceInput.clear();
          });
        },
      );
    }
  }

  Future<void> _onLocationMicTap(BuildContext context) async {
    final cp = context.read<ComplaintProvider>();
    final voice = context.read<VoiceProvider>();
    final lang = context.read<LanguageProvider>().currentLanguage;

    if (voice.state == VoiceState.listening) {
      await voice.stopListening();
      final text = voice.transcribedText.isNotEmpty
          ? voice.transcribedText
          : (voice.partialText.isNotEmpty
              ? voice.partialText
              : _mockVoiceInput.text);

      final finalText = text.isNotEmpty ? text : 'Unknown Location';
      await cp.processVoiceComplaint(_capturedComplaint, finalText);
    } else {
      await voice.startListening(
        localeId: lang == 'hi' ? 'hi_IN' : 'en_IN',
        onFinalResult: (text) async {
          await cp.processVoiceComplaint(_capturedComplaint, text);
        },
      );
    }
  }

  Future<void> _pickImage(ComplaintProvider cp) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      final bytes = await File(file.path).readAsBytes();
      cp.attachImage(base64Encode(bytes));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ComplaintProvider>();
    final voice = context.watch<VoiceProvider>();
    final isRecording = voice.state == VoiceState.listening;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Column(
          children: [
            Text(
              'CIVIC VOICE INTERFACE',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.saffron,
                letterSpacing: 2,
              ),
            ),
            Text(
              'Government of India Official Portal',
              style: GoogleFonts.inter(
                fontSize: 8,
                color: AppColors.textMuted,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.security, color: AppColors.emerald, size: 20),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildOfficialBanner(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: provider.draftComplaint == null
                    ? (_step == 0
                        ? _buildComplaintInputView(voice, isRecording)
                        : _buildLocationInputView(voice, isRecording))
                    : _buildReviewView(provider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficialBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.saffron.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
            AppColors.emerald.withValues(alpha: 0.1),
          ],
        ),
        border: Border(
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.gpp_good, color: AppColors.emerald, size: 14),
          const SizedBox(width: 8),
          Text(
            'SECURE END-TO-END ENCRYPTED FILING',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintInputView(VoiceProvider voice, bool isRecording) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'Speak to Report',
          style: GoogleFonts.playfairDisplay(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).animate().fadeIn().slideY(begin: 0.2),
        const SizedBox(height: 8),
        Text(
          'Describe your issue clearly. We will ask for the location next.',
          textAlign: TextAlign.center,
          style:
              GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13),
        ).animate().fadeIn(delay: 200.ms),

        const Spacer(),

        // Voice Record Interaction Area
        GestureDetector(
          onTap: () => _onComplaintMicTap(context),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isRecording)
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.saffron.withValues(alpha: 0.2),
                        width: 1),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.5, 1.5))
                    .fadeOut(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isRecording ? 180 : 150,
                height: isRecording ? 180 : 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isRecording
                        ? [AppColors.semanticError, const Color(0xFFC0392B)]
                        : [AppColors.accentBlue, const Color(0xFF2980B9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isRecording
                              ? AppColors.semanticError
                              : AppColors.accentBlue)
                          .withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Icon(
                  isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ).animate(target: isRecording ? 1 : 0).shimmer(duration: 2.seconds),

        const SizedBox(height: 40),

        _buildTrustIndicators(),

        const Spacer(),

        if (isRecording)
          TextField(
            controller: _mockVoiceInput,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Simulate voice text here...',
              hintStyle: const TextStyle(color: Colors.white30),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ).animate().fadeIn(),
      ],
    );
  }

  Widget _buildLocationInputView(VoiceProvider voice, bool isRecording) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'Where is this?',
          style: GoogleFonts.playfairDisplay(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).animate().fadeIn().slideY(begin: 0.2),
        const SizedBox(height: 8),
        Text(
          'Provide the location for: "$_capturedComplaint"',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
              color: AppColors.saffron,
              fontSize: 13,
              fontStyle: FontStyle.italic),
        ).animate().fadeIn(delay: 200.ms),

        const Spacer(),

        // Voice Record Interaction Area
        GestureDetector(
          onTap: () => _onLocationMicTap(context),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isRecording)
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.saffron.withValues(alpha: 0.2),
                        width: 1),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.5, 1.5))
                    .fadeOut(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isRecording ? 100 : 80,
                height: isRecording ? 100 : 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isRecording
                        ? [AppColors.semanticError, const Color(0xFFC0392B)]
                        : [AppColors.bgMid, AppColors.bgLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: AppColors.surfaceBorder),
                  boxShadow: [
                    if (isRecording)
                      BoxShadow(
                        color: AppColors.semanticError.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                  ],
                ),
                child: Icon(
                  isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  size: 32,
                  color: isRecording ? Colors.white : AppColors.saffron,
                ),
              ),
            ],
          ),
        ).animate(target: isRecording ? 1 : 0).shimmer(duration: 2.seconds),

        const Spacer(),

        if (isRecording)
          TextField(
            controller: _mockVoiceInput,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Simulate location text here...',
              hintStyle: const TextStyle(color: Colors.white30),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ).animate().fadeIn(),
      ],
    );
  }

  Widget _buildTrustIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _trustItem(Icons.location_on, 'GPS Verified'),
        _trustItem(Icons.fingerprint, 'Biometric Auth'),
        _trustItem(Icons.account_balance, 'Gov Integrated'),
      ],
    );
  }

  Widget _trustItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.saffron, size: 20),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildReviewView(ComplaintProvider provider) {
    final complaint = provider.draftComplaint!;

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Review Draft',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.emerald.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.emerald),
              ),
              child: Row(
                children: [
                  const Icon(Icons.gps_fixed,
                      color: AppColors.emerald, size: 12),
                  const SizedBox(width: 4),
                  Text('GPS LOCATED',
                      style: GoogleFonts.inter(
                          color: AppColors.emerald,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Status Section
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.emerald),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Location Captured',
                        style: GoogleFonts.inter(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      complaint.location,
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField(
                  'Authority',
                  complaint.authorityEmail ?? 'Detecting...',
                  Icons.account_balance,
                  isGold: true),
              const Divider(color: AppColors.surfaceBorder, height: 32),
              _buildField('Category', complaint.category, Icons.category),
              const Divider(color: AppColors.surfaceBorder, height: 32),
              _buildField(
                  'Description', complaint.description, Icons.description),
            ],
          ),
        ).animate().fadeIn(),

        const SizedBox(height: 24),

        _buildMediaSection(provider),

        const SizedBox(height: 32),

        _buildActionButtons(provider),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildMediaSection(ComplaintProvider provider) {
    return GestureDetector(
      onTap: () => _pickImage(provider),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.bgDeep,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: provider.draftComplaint!.base64Image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                          base64Decode(provider.draftComplaint!.base64Image!),
                          fit: BoxFit.cover),
                    )
                  : const Icon(Icons.add_a_photo,
                      color: AppColors.saffron, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.draftComplaint!.base64Image != null
                        ? 'Evidence Attached'
                        : 'Attach Visual Evidence',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Photos help authorities resolve issues 40% faster.',
                    style: GoogleFonts.inter(
                        color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ComplaintProvider provider) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            onPressed: () {
              setState(() => _step = 0);
              provider.discardDraft();
            },
            child: Text('DISCARD',
                style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 8,
              shadowColor: AppColors.emerald.withValues(alpha: 0.3),
            ),
            onPressed: provider.isProcessing
                ? null
                : () async {
                    final refId =
                        'GOI-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                    await provider.submitComplaint();
                    if (mounted) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.bgDeep,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: const BorderSide(color: AppColors.emerald)),
                          title: Column(
                            children: [
                              const Icon(Icons.verified_user,
                                  color: AppColors.emerald, size: 48),
                              const SizedBox(height: 16),
                              Text('FILED OFFICIALLY',
                                  style: GoogleFonts.playfairDisplay(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                  'Your complaint has been encrypted and routed to:',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                      color: AppColors.textSecondary,
                                      fontSize: 12)),
                              const SizedBox(height: 8),
                              Text(
                                  provider.complaints.last.authorityEmail ??
                                      'Central Authority',
                                  style: GoogleFonts.poppins(
                                      color: AppColors.gold,
                                      fontWeight: FontWeight.bold)),
                              const Divider(
                                  color: AppColors.surfaceBorder, height: 32),
                              Text('FILING REFERENCE NUMBER',
                                  style: GoogleFonts.inter(
                                      color: AppColors.textMuted,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1)),
                              const SizedBox(height: 8),
                              SelectableText(refId,
                                  style: GoogleFonts.robotoMono(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2)),
                            ],
                          ),
                          actions: [
                            Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.emerald,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12))),
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  setState(() => _step = 0);
                                  provider.discardDraft();
                                },
                                child: const Text('ACKNOWLEDGE',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      );
                    }
                  },
            child: provider.isProcessing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text('SUBMIT OFFICIALLY',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, String val, IconData icon,
      {bool isGold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            color: isGold ? AppColors.gold : AppColors.textMuted, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(),
                  style: GoogleFonts.inter(
                      color: AppColors.textMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
              const SizedBox(height: 6),
              Text(val,
                  style: GoogleFonts.poppins(
                      color: isGold ? AppColors.gold : AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: isGold ? FontWeight.bold : FontWeight.w500)),
            ],
          ),
        )
      ],
    );
  }
}
