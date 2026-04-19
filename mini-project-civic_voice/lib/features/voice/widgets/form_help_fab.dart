import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/aws_bedrock_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class FormHelpFab extends StatefulWidget {
  final ScreenshotController screenshotController;
  final String formContext;

  const FormHelpFab({
    super.key,
    required this.screenshotController,
    this.formContext = 'this form',
  });

  @override
  State<FormHelpFab> createState() => _FormHelpFabState();
}

class _FormHelpFabState extends State<FormHelpFab> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  bool _isProcessing = false;
  String _spokenText = '';

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-IN');
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      // Give initial prompt
      await _tts.speak('How can I help you with ${widget.formContext}?');

      // Small delay to let TTS finish
      await Future.delayed(const Duration(seconds: 2));

      _speech.listen(
        onResult: (result) {
          setState(() {
            _spokenText = result.recognizedWords;
          });
          if (result.finalResult && _spokenText.isNotEmpty) {
            _processQuestion(_spokenText);
          }
        },
        listenFor: const Duration(seconds: 10),
      );
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _processQuestion(String question) async {
    await _stopListening();
    setState(() => _isProcessing = true);

    try {
      // 1. Capture the screen
      final Uint8List? imageBytes = await widget.screenshotController.capture();

      if (imageBytes == null) {
        throw Exception("Could not capture screenshot.");
      }

      // 2. Compress the image heavily to save AWS Vision tokens
      final Uint8List compressedImage =
          await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: 60, // 60% quality is usually enough for OCR
        minWidth: 800,
        minHeight: 800,
      );

      // 3. Define the instruction to keep answers minimal
      final systemPrompt = '''
You are a helpful UI assistant. A user is filling out a digital form.
You are given a screenshot of their current screen and their spoken question.
Your goal is to answer their question directly, guiding them on what to tap or type.
Keep your answer EXTREMELY concise and conversational, no more than 1 or 2 sentences.
Example: "Tap the calendar icon on the right to select your Date of Birth."
Do NOT output any JSON or markdown, just the plain spoken text response.
''';

      // 4. Send to Bedrock (Nova Lite handles multimodality natively in DocumentAIService logic)
      final responseBody = {
        if (systemPrompt.isNotEmpty)
          "system": [
            {"text": systemPrompt}
          ],
        "messages": [
          {
            "role": "user",
            "content": [
              {
                "image": {
                  "format": "jpeg",
                  "source": {"bytes": base64Encode(compressedImage)}
                }
              },
              {"text": question}
            ]
          }
        ],
        "inferenceConfig": {
          "maxTokens": 100, // Strict limit for cost-saving
          "temperature": 0.2,
          "topP": 0.9,
        }
      };

      final result = await AWSBedrockService.invokeModel(
        modelId: 'amazon.nova-lite-v1:0', // Reusing the Nova Lite model
        body: responseBody,
        api: 'converse',
      );

      // Parse Converse response
      String aiResponse =
          "I'm sorry, I couldn't process the form. Please try again.";
      final output = result['output'];
      if (output != null && output['message'] != null) {
        final content = output['message']['content'] as List;
        for (final item in content) {
          if (item is Map && item.containsKey('text')) {
            aiResponse = item['text'] as String;
            break;
          }
        }
      }

      // 5. Speak the answer back.
      await _tts.speak(aiResponse);
    } catch (e) {
      debugPrint("FormHelp Error: \$e");
      await _tts.speak("Sorry, I encountered an error while viewing the form.");
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _isProcessing
          ? null
          : (_isListening ? _stopListening : _startListening),
      backgroundColor: _isListening ? AppTheme.error : AppTheme.electricBlue,
      heroTag: 'formHelpFab',
      icon: _isProcessing
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  color: AppTheme.deepSpaceBlue, strokeWidth: 2))
          : Icon(_isListening ? Icons.mic_off : Icons.mic,
              color: AppTheme.deepSpaceBlue),
      label: Text(
        _isProcessing
            ? 'Thinking...'
            : (_isListening ? 'Listening...' : 'Ask AI'),
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: AppTheme.deepSpaceBlue,
        ),
      ),
    )
        .animate(target: _isListening || _isProcessing ? 1 : 0)
        .shimmer()
        .boxShadow();
  }
}
