import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Uses the free, unofficial Google Translate endpoint (no API key needed).
/// Endpoint: https://translate.googleapis.com/translate_a/single?client=gtx
///
/// All strings are joined with a sentinel separator, sent in ONE HTTP call,
/// then split back — keeping API calls to a minimum.
class TranslationService {
  TranslationService._();

  static const _baseUrl =
      'https://translate.googleapis.com/translate_a/single';

  /// Separator used to join/split strings in a single batch request.
  /// Must not appear in any UI string.
  static const _sep = '\n||||\n';

  // ── Cache ────────────────────────────────────────────────────────────────

  /// In-memory cache: langCode → {key → translatedString}
  static final Map<String, Map<String, String>> _memCache = {};

  static String _cacheKey(String langCode) => 'cvi_translations_$langCode';

  /// Load cached translations for [langCode] from SharedPreferences.
  static Future<Map<String, String>?> loadCache(String langCode) async {
    if (_memCache.containsKey(langCode)) return _memCache[langCode];
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey(langCode));
      if (raw == null) return null;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final result = decoded.map((k, v) => MapEntry(k, v.toString()));
      _memCache[langCode] = result;
      return result;
    } catch (_) {
      return null;
    }
  }

  /// Persist [translations] for [langCode] to SharedPreferences.
  static Future<void> _saveCache(
      String langCode, Map<String, String> translations) async {
    try {
      _memCache[langCode] = translations;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey(langCode), jsonEncode(translations));
    } catch (_) {}
  }

  // ── Translation ──────────────────────────────────────────────────────────

  /// Translate a [batch] of {key → englishText} pairs to [targetLang].
  /// Returns {key → translatedText} using a single HTTP request.
  static Future<Map<String, String>> translateBatch(
    Map<String, String> batch,
    String targetLang,
  ) async {
    if (targetLang == 'en') {
      // No translation needed — return source as-is
      return Map.from(batch);
    }

    final keys = batch.keys.toList();
    final texts = batch.values.toList();

    // Join all texts with sentinel for a single request
    final joined = texts.join(_sep);

    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'client': 'gtx',
        'sl': 'en',
        'tl': targetLang,
        'dt': 't',
        'q': joined,
      });

      final response = await http
          .get(uri, headers: {'User-Agent': 'Mozilla/5.0'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        // On error: return original English texts
        return Map.fromIterables(keys, texts);
      }

      final json = jsonDecode(response.body) as List<dynamic>;

      // The response is: [ [ ["translated","original",...], ... ], ... ]
      // All sentence chunks are in json[0]
      final chunks = json[0] as List<dynamic>;
      final rawTranslated = chunks
          .map((c) => (c as List<dynamic>)[0].toString())
          .join('');

      // Split back by sentinel (translation may slightly alter it, so be flexible)
      final translatedParts = _splitTranslated(rawTranslated, texts.length);

      final result = <String, String>{};
      for (var i = 0; i < keys.length; i++) {
        result[keys[i]] =
            i < translatedParts.length ? translatedParts[i].trim() : texts[i];
      }
      return result;
    } catch (_) {
      // Network/parse error: fall back to English
      return Map.fromIterables(keys, texts);
    }
  }

  /// Split translated batch string back into individual strings.
  /// Google Translate preserves `\n` but may slightly alter the sentinel.
  static List<String> _splitTranslated(String raw, int expectedCount) {
    // Try exact sentinel first
    if (raw.contains('||||')) {
      return raw.split(RegExp(r'\n?\|\|\|\|\n?'));
    }
    // Fallback: split on newlines and group by expectedCount
    final lines = raw.split('\n').where((l) => l.trim().isNotEmpty).toList();
    return lines;
  }

  // ── Public API ───────────────────────────────────────────────────────────

  /// Translate all [englishStrings] to [targetLang].
  /// Checks in-memory and SharedPreferences cache first.
  /// Returns {key → translatedString}.
  static Future<Map<String, String>> translateAll(
    Map<String, String> englishStrings,
    String targetLang,
  ) async {
    if (targetLang == 'en') {
      return Map.from(englishStrings);
    }

    // 1. Try memory cache
    final cached = await loadCache(targetLang);
    if (cached != null && cached.isNotEmpty) {
      // Check that cache has all keys (app may have added new strings)
      final missingKeys = englishStrings.keys
          .where((k) => !cached.containsKey(k))
          .toList();
      if (missingKeys.isEmpty) return cached;

      // Translate only missing keys and merge
      final missingBatch = {for (var k in missingKeys) k: englishStrings[k]!};
      final newTranslations = await translateBatch(missingBatch, targetLang);
      final merged = {...cached, ...newTranslations};
      await _saveCache(targetLang, merged);
      return merged;
    }

    // 2. Full batch translation
    final translations = await translateBatch(englishStrings, targetLang);
    await _saveCache(targetLang, translations);
    return translations;
  }

  /// Clear all cached translations (useful for testing).
  static Future<void> clearCache() async {
    _memCache.clear();
    final prefs = await SharedPreferences.getInstance();
    for (final lang in ['hi', 'mr', 'ta']) {
      await prefs.remove(_cacheKey(lang));
    }
  }
}
