import 'package:flutter/foundation.dart';
import 'reasoning_engine.dart';

class TranslationService {
  final ReasoningEngine _reasoningEngine = ReasoningEngine();

  static const String baseLanguage = 'en';

  Future<String> translateToEnglish(
    String text,
    String sourceLanguageCode,
  ) async {
    if (sourceLanguageCode == baseLanguage || sourceLanguageCode.isEmpty) {
      return text;
    }

    try {
      final String translatedText = await _reasoningEngine.translateText(
        text,
        sourceLanguageCode,
      );
      return translatedText;
    } catch (e) {
      debugPrint('Translation error via ReasoningEngine: $e');
      return text; // Fallback to original text
    }
  }
}
