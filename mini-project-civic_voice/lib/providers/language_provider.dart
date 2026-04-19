import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_strings.dart';
import '../services/translation_service.dart';

/// Manages the UI language.
/// Uses Google Translate (free, no API key) via [TranslationService].
/// Provides [translateSync] for [TText] widgets and [t(key)] for keyed lookups.
class LanguageProvider extends ChangeNotifier {
  static const _prefKey = 'cvi_language';

  String _currentLanguage = 'en';
  bool _isTranslating = false;
  String? _translationError;

  /// All cached translations for the current language.
  /// Key = English source text, Value = translated text.
  Map<String, String> _cache = {};

  /// Strings pending translation (registered by TText widgets).
  final Set<String> _pendingStrings = {};
  bool _pendingScheduled = false;

  // ── Getters ───────────────────────────────────────────────────────────────

  String  get currentLanguage   => _currentLanguage;
  String  get currentCode       => _currentLanguage;
  bool    get isTranslating     => _isTranslating;
  String? get translationError  => _translationError;
  String  get languageCode      => _currentLanguage;

  Locale get currentLocale => switch (_currentLanguage) {
        'hi' => const Locale('hi', 'IN'),
        'mr' => const Locale('mr', 'IN'),
        'ta' => const Locale('ta', 'IN'),
        _    => const Locale('en', 'IN'),
      };

  String get currentLanguageName => switch (_currentLanguage) {
        'hi' => 'हिन्दी',
        'mr' => 'मराठी',
        'ta' => 'தமிழ்',
        _    => 'English',
      };

  String get languageName  => currentLanguageName;
  String get fullLocaleId  => switch (_currentLanguage) {
        'hi' => 'hi-IN',
        'mr' => 'mr-IN',
        'ta' => 'ta-IN',
        _    => 'en-IN',
      };

  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English',  'native': 'English'},
    {'code': 'hi', 'name': 'Hindi',    'native': 'हिन्दी'},
    {'code': 'mr', 'name': 'Marathi',  'native': 'मराठी'},
    {'code': 'ta', 'name': 'Tamil',    'native': 'தமிழ்'},
  ];

  // ── Constructor ───────────────────────────────────────────────────────────

  LanguageProvider() {
    _initCache();
    _init();
  }

  void _initCache() {
    // Pre-populate cache with known English strings
    for (final e in AppStrings.englishStrings.entries) {
      _cache[e.value] = e.value; // English → English
    }
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved != null && _isSupported(saved) && saved != 'en') {
        // Try loading from disk cache first (no network call)
        final diskCache = await TranslationService.loadCache(saved);
        if (diskCache != null && diskCache.isNotEmpty) {
          _currentLanguage = saved;
          _cache = diskCache;
          notifyListeners();
        } else {
          await switchLanguage(saved);
        }
      }
    } catch (_) {}
  }

  bool _isSupported(String code) =>
      supportedLanguages.any((l) => l['code'] == code);

  // ── Core Translation API ──────────────────────────────────────────────────

  /// Synchronous translation for [TText] widgets.
  /// Returns cached translation instantly. If not cached, returns [englishText]
  /// and schedules a background translate that will call notifyListeners() when done.
  String translateSync(String englishText) {
    if (_currentLanguage == 'en' || englishText.isEmpty) return englishText;

    final cached = _cache[englishText];
    if (cached != null) return cached;

    // Not cached yet — schedule background translation
    _schedulePendingTranslation(englishText);
    return englishText; // show English temporarily
  }

  /// Schedule a batch of unseen strings for background translation.
  void _schedulePendingTranslation(String text) {
    _pendingStrings.add(text);
    if (_pendingScheduled) return;
    _pendingScheduled = true;

    // Debounce: wait for the next frame to batch all pending strings
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _pendingScheduled = false;
      if (_pendingStrings.isEmpty || _currentLanguage == 'en') return;

      final batch = Map.fromEntries(
        _pendingStrings.map((t) => MapEntry(t, t)),
      );
      _pendingStrings.clear();

      try {
        final translated = await TranslationService.translateBatch(
          batch,
          _currentLanguage,
        );
        _cache.addAll(translated);
        notifyListeners(); // rebuild TText widgets with translated text
      } catch (_) {}
    });
  }

  /// Key-based translation using AppStrings keys.
  /// Example: `lang.t('nav_home')` → 'होम'
  String t(String key) {
    final english = AppStrings.englishStrings[key];
    if (english == null) return key;
    return translateSync(english);
  }

  // Deprecated aliases kept for legacy callers
  String getLocalizedText(Map<String, String> m) => m[_currentLanguage] ?? m['en'] ?? '';
  String translate(String key) => t(key);

  // ── Language Switch ───────────────────────────────────────────────────────

  /// Switch to [langCode]. Fetches/loads translations, then rebuilds all TText widgets.
  Future<void> switchLanguage(String langCode) async {
    if (!_isSupported(langCode)) return;
    if (_currentLanguage == langCode) return;

    _currentLanguage = langCode;
    _translationError = null;

    if (langCode == 'en') {
      // Reset cache to English → English mappings
      _cache = {};
      for (final e in AppStrings.englishStrings.entries) {
        _cache[e.value] = e.value;
      }
      notifyListeners();
      await _saveLangPref(langCode);
      return;
    }

    _isTranslating = true;
    notifyListeners();

    try {
      // Translate ALL known English strings at once
      final allEnglish = Map.fromEntries(
        AppStrings.englishStrings.values.map((v) => MapEntry(v, v)),
      );
      final translations = await TranslationService.translateAll(
        allEnglish,
        langCode,
      );
      _cache = translations;
      await _saveLangPref(langCode);
    } catch (e) {
      _translationError = 'Translation failed';
      // Keep English
      _cache = {for (final v in AppStrings.englishStrings.values) v: v};
    } finally {
      _isTranslating = false;
      notifyListeners();
    }
  }

  Future<void> setLanguageByCode(String code) => switchLanguage(code);

  Future<void> _saveLangPref(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, code);
    } catch (_) {}
  }

  // ── Dynamic text translation (for Voice/AI responses) ─────────────────────

  /// Asynchronously translate arbitrary text (e.g., AI responses, service names).
  Future<String> translateText(String text, {String? targetLang}) async {
    final lang = targetLang ?? _currentLanguage;
    if (text.trim().isEmpty || lang == 'en') return text;
    try {
      final result = await TranslationService.translateBatch({'_': text}, lang);
      return result['_'] ?? text;
    } catch (_) {
      return text;
    }
  }
}
