import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/language_provider.dart';
import '../../providers/voice_provider.dart';
import '../../providers/services_provider.dart';

// ═════════════════════════════════════════════════════════════════════════════
// APP INITIALIZER
// Orchestrates startup — run once before runApp.
// ═════════════════════════════════════════════════════════════════════════════

class AppInitializer {
  AppInitializer._();

  static late SharedPreferences _prefs;

  static bool _firstLaunch = false;
  static bool _hasSession = false;

  static bool get isFirstLaunch => _firstLaunch;
  static bool get hasSession => _hasSession;

  /// Run all startup tasks. Providers are passed so we can pre-configure them.
  static Future<void> initialize({
    LanguageProvider? langProvider,
    VoiceProvider? voiceProvider,
    ServicesProvider? servicesProvider,
  }) async {
    _prefs = await SharedPreferences.getInstance();

    // ── 1. First-launch detection ───────────────────────────────────────────
    _firstLaunch = !(_prefs.getBool('cvi_onboarded') ?? false);

    // ── 2. Session check ───────────────────────────────────────────────────
    final sessionToken = _prefs.getString('cvi_session_token');
    _hasSession = sessionToken != null && sessionToken.isNotEmpty;

    // ── 3. Load language preference ────────────────────────────────────────
    final savedLang = _prefs.getString('cvi_language') ?? 'en';
    await langProvider?.switchLanguage(savedLang);

    // ── 4. Sync TTS with saved language ───────────────────────────────────
    await voiceProvider?.setLanguage(savedLang);

    // ServicesProvider loads on construction — no need to call loadServices() again.
  }

  /// Mark onboarding as complete.
  static Future<void> completeOnboarding() async {
    await _prefs.setBool('cvi_onboarded', true);
    _firstLaunch = false;
  }

  /// Returns the initial route based on session and onboarding state.
  static String get initialRoute {
    if (_firstLaunch) return '/onboarding';
    if (!_hasSession) return '/auth';
    return '/dashboard';
  }

  /// Clears all app state (for testing / logout).
  static Future<void> clearAllData() async {
    await _prefs.clear();
    _firstLaunch = true;
    _hasSession = false;
  }
}
