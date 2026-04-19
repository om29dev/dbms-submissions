import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterTts _tts = FlutterTts();
  bool _isNavigated = false;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    debugPrint('[CVI_SPLASH] Initializing Direct Intro Sequence');

    // We set a 4-second fallback timer just in case the TTS engine
    // on the phone is completely broken and never fires completion handlers,
    // to ensure the user isn't permanently stuck on the splash screen.
    _fallbackTimer = Timer(const Duration(milliseconds: 4000), () {
      debugPrint('[CVI_SPLASH] Fallback Timer Triggered Navigation');
      _navigate();
    });

    _playWelcomeVoice();
  }

  Future<void> _playWelcomeVoice() async {
    try {
      // Configure TTS
      await _tts.setLanguage("en-IN");
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);

      // The critical piece: Listen for when the speech STARTS, then use a precise
      // 1800ms timer to navigate. This bypasses a common Android TTS bug where
      // the engine returns 'completed' seconds after the audio actually finishes due to trailing silence.
      _tts.setStartHandler(() {
        debugPrint(
            '[CVI_SPLASH] TTS Audio Started. Queueing 1.8s timer for navigation.');
        Future.delayed(const Duration(milliseconds: 1800), () {
          _navigate();
        });
      });

      _tts.setErrorHandler((msg) {
        debugPrint(
            '[CVI_SPLASH] TTS Error Event: $msg. Triggering Navigation.');
        _navigate();
      });

      // Avoid awaiting speak completion to prevent engine blocks
      await _tts.awaitSpeakCompletion(false);

      // Speak immediately; animations will play concurrently
      _tts.speak("Jago Bharat Jago");
    } catch (e) {
      debugPrint('[CVI_SPLASH] TTS Exception: $e');
      _navigate();
    }
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _tts.stop();
    super.dispose();
  }

  Future<void> _navigate() async {
    // Ensure we only navigate once, whether triggered by TTS ending or fallback timer
    if (_isNavigated) return;
    _isNavigated = true;
    _fallbackTimer?.cancel();

    debugPrint('[CVI_SPLASH] Nav: Starting transition flow...');

    final auth = context.read<AuthProvider>();
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('cvi_onboarded') ?? false;

    if (!mounted) {
      AppRouter.hasShownSplash = true; // Fallback unlock
      return;
    }

    String target;
    if (auth.isAuthenticated) {
      target = Routes.dashboard;
    } else if (!seen) {
      target = Routes.onboarding;
    } else {
      target = Routes.auth;
    }
    AppRouter.hasShownSplash = true; // Unlock the router redirect

    if (mounted) {
      context.go(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        textTheme: TextTheme(
          bodyMedium: GoogleFonts.inter(color: Colors.white),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A), // Official Navy Blue
        body: Stack(
          children: [
            // Full-screen custom artwork background
            Positioned.fill(
              child: Image.asset(
                'assets/images/intro_bg.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if the user hasn't copied the image yet
                  return Container(
                    color: const Color(0xFF0F172A),
                    child: const Center(
                      child: Text(
                        'Please add intro_bg.png\nto assets/images/',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
