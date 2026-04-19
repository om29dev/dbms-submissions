import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

/// Represents the lifecycle state of the voice system.
enum VoiceState {
  idle,
  listening,
  processing,
  speaking,
  responding, // alias for speaking (used by legacy screens)
  error, // error state (used by legacy screens)
  permissionDenied,
  unavailable,
}

class VoiceProvider extends ChangeNotifier {
  final stt.SpeechToText _stt = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  VoiceState _state = VoiceState.idle;
  String _transcribedText = '';
  String _partialText = '';
  bool _isTTSEnabled = true;
  double _speechRate = 0.5;
  String _voiceGender = 'female';
  bool _sttInitialized = false;
  double _soundLevel = 0.0;
  String? _errorMessage;

  // ─── Getters ───────────────────────────────────────────────────────────────
  VoiceState get state => _state;
  String get transcribedText => _transcribedText;
  String get partialText => _partialText;
  bool get isTTSEnabled => _isTTSEnabled;
  double get speechRate => _speechRate;
  String get voiceGender => _voiceGender;
  double get soundLevel => _soundLevel;
  String? get errorMessage => _errorMessage;

  bool get isListening => _state == VoiceState.listening;
  bool get isSpeaking => _state == VoiceState.speaking;
  bool get isIdle => _state == VoiceState.idle;
  bool get isProcessing => _state == VoiceState.processing;

  VoiceProvider() {
    _initTTS();
  }

  // ─── TTS Setup ─────────────────────────────────────────────────────────────

  Future<void> _initTTS() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(_speechRate);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() {
      _state = VoiceState.speaking;
      notifyListeners();
    });
    _tts.setCompletionHandler(() {
      _state = VoiceState.idle;
      notifyListeners();
    });
    _tts.setErrorHandler((msg) {
      _errorMessage = msg;
      _state = VoiceState.idle;
      notifyListeners();
    });
  }

  // ─── STT Setup ─────────────────────────────────────────────────────────────

  Future<bool> _ensureSTTInitialized() async {
    if (_sttInitialized) {
      debugPrint('[VoiceProvider] STT already initialized.');
      return true;
    }
    debugPrint('[VoiceProvider] Initializing STT...');
    try {
      _sttInitialized = await _stt.initialize(
        onError: (error) {
          debugPrint('[VoiceProvider] STT onError: ${error.errorMsg}');
          _errorMessage = error.errorMsg;
          _state = VoiceState.idle;
          notifyListeners();
        },
        onStatus: (status) {
          debugPrint('[VoiceProvider] STT onStatus: $status');
          if (status == 'done' || status == 'notListening') {
            if (_state == VoiceState.listening) {
              _state = VoiceState.processing;
            }
            notifyListeners();
          }
        },
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        debugPrint('[VoiceProvider] STT initialize timed out after 5s');
        return false;
      });
    } catch (e) {
      debugPrint('[VoiceProvider] STT initialize exception: $e');
      _sttInitialized = false;
    }

    debugPrint('[VoiceProvider] STT initialized: $_sttInitialized');
    if (!_sttInitialized) {
      _state = VoiceState.unavailable;
      _errorMessage = 'Speech recognition not available on this device.';
      notifyListeners();
    }
    return _sttInitialized;
  }

  // ─── Permissions ───────────────────────────────────────────────────────────

  Future<bool> requestMicPermission() async {
    debugPrint('[VoiceProvider] Requesting mic permission...');
    final status = await Permission.microphone.request();
    debugPrint('[VoiceProvider] Mic permission status: $status');
    if (status.isDenied || status.isPermanentlyDenied) {
      _state = VoiceState.permissionDenied;
      _errorMessage = status.isPermanentlyDenied
          ? 'Microphone access is permanently denied. Please enable it in Settings.'
          : 'Microphone permission is required for voice input.';
      notifyListeners();
      if (status.isPermanentlyDenied) openAppSettings();
      return false;
    }
    return true;
  }

  // ─── Listening ─────────────────────────────────────────────────────────────

  Future<void> startListening(
      {String? localeId, Function(String text)? onFinalResult}) async {
    _errorMessage = null;

    final hasPermission = await requestMicPermission();
    if (!hasPermission) return;

    final initialized = await _ensureSTTInitialized();
    if (!initialized) return;

    if (!_stt.isAvailable) {
      debugPrint('[VoiceProvider] STT not available after init.');
      _errorMessage = 'Speech recognition not available';
      _state = VoiceState.error;
      notifyListeners();
      return;
    }

    _errorMessage = null;
    _transcribedText = '';
    _partialText = '';
    _state = VoiceState.listening;
    notifyListeners();

    debugPrint('[VoiceProvider] Calling _stt.listen(localeId: $localeId)...');

    try {
      await _stt.listen(
        onResult: (result) {
          debugPrint(
              '[VoiceProvider] STT result: final=${result.finalResult}, words="${result.recognizedWords}"');
          if (result.finalResult) {
            _transcribedText = result.recognizedWords;
            _partialText = '';
            _state = VoiceState.processing;
            if (onFinalResult != null && _transcribedText.isNotEmpty) {
              onFinalResult(_transcribedText);
            }
          } else {
            _partialText = result.recognizedWords;
          }
          notifyListeners();
        },
        onSoundLevelChange: (level) {
          // Throttle: only notify if level changed significantly
          // Prevents dozens of full widget-tree rebuilds per second while listening
          if ((level - _soundLevel).abs() > 2.0) {
            _soundLevel = level;
            notifyListeners();
          }
        },
        localeId: localeId,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
        ),
      );
      debugPrint('[VoiceProvider] _stt.listen() returned successfully.');
    } catch (e) {
      debugPrint('[VoiceProvider] _stt.listen() exception: $e');
      _errorMessage = 'Failed to start speech recognition: $e';
      _state = VoiceState.error;
      notifyListeners();
    }
  }

  Future<void> stopListening() async {
    await _stt.stop();
    if (_state == VoiceState.listening) {
      _transcribedText =
          _partialText.isNotEmpty ? _partialText : _transcribedText;
      _partialText = '';
      _state = VoiceState.processing;
      notifyListeners();
    }
  }

  void setIdle() {
    _state = VoiceState.idle;
    notifyListeners();
  }

  // ─── TTS ───────────────────────────────────────────────────────────────────

  /// Strip markdown and special characters so TTS reads naturally.
  String _sanitizeForSpeech(String text) {
    return text
        .replaceAll(RegExp(r'\*{1,3}'), '') // bold/italic asterisks
        .replaceAll(RegExp(r'#{1,6}\s*'), '') // headers
        .replaceAll(RegExp(r'`{1,3}'), '') // code blocks
        .replaceAll(
            RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'$1') // links → text only
        .replaceAll(RegExp(r'^[-•]\s*', multiLine: true), '') // bullet points
        .replaceAll(RegExp(r'^\d+\.\s*', multiLine: true), '') // numbered lists
        .replaceAll(RegExp(r'[_~]'), '') // underscores/strikethrough
        .replaceAll(RegExp(r'\n{2,}'), '\n') // collapse extra newlines
        .trim();
  }

  Future<void> speak(String text) async {
    if (!_isTTSEnabled || text.trim().isEmpty) return;
    if (isSpeaking) await _tts.stop();
    final cleanText = _sanitizeForSpeech(text);
    await _tts.speak(cleanText);
  }

  /// Speaks text and waits for TTS to fully complete before returning.
  /// This prevents the next speak() call from canceling current speech.
  Future<void> speakAndWait(String text) async {
    if (!_isTTSEnabled || text.trim().isEmpty) return;
    if (isSpeaking) await _tts.stop();
    final cleanText = _sanitizeForSpeech(text);

    final completer = Completer<void>();

    // Temporarily override the completion handler
    _tts.setCompletionHandler(() {
      _state = VoiceState.idle;
      notifyListeners();
      if (!completer.isCompleted) completer.complete();
    });
    _tts.setErrorHandler((msg) {
      _errorMessage = msg;
      _state = VoiceState.idle;
      notifyListeners();
      if (!completer.isCompleted) completer.complete();
    });

    await _tts.speak(cleanText);
    await completer.future;
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
    _state = VoiceState.idle;
    notifyListeners();
  }

  void toggleTTS() {
    _isTTSEnabled = !_isTTSEnabled;
    if (!_isTTSEnabled && isSpeaking) _tts.stop();
    notifyListeners();
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.1, 1.0);
    await _tts.setSpeechRate(_speechRate);
    notifyListeners();
  }

  Future<void> setVoiceGender(String gender) async {
    _voiceGender = gender;
    // Apply language/gender specific voice on supported platforms
    final voices = await _tts.getVoices as List?;
    if (voices != null) {
      final preferredVoice = voices.firstWhere(
        (v) => (v['name'] as String).toLowerCase().contains(gender),
        orElse: () => voices.first,
      );
      if (preferredVoice != null) {
        await _tts.setVoice({
          'name': preferredVoice['name'],
          'locale': preferredVoice['locale'],
        });
      }
    }
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    final locale = switch (langCode) {
      'hi' => 'hi-IN',
      'mr' => 'mr-IN',
      'ta' => 'ta-IN',
      _ => 'en-IN',
    };
    await _tts.setLanguage(locale);
  }

  void clearTranscription() {
    _transcribedText = '';
    _partialText = '';
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _stt.stop();
    _tts.stop();
    super.dispose();
  }

  // ─── Legacy API Stubs ────────────────────────────────────────────────────
  Future<void> stopSilently() async {
    await _stt.stop();
    await _tts.stop();
  }

  Future<void> initVoice() async {
    /* STT lazily initialized on startListening */
  }
  Future<void> setLocale(String bcp47) async {
    await _tts.setLanguage(bcp47);
  }
}
