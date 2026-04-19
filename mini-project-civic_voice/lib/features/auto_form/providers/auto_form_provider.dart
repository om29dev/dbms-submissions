// ═══════════════════════════════════════════════════════════════════════════════
// AUTO FORM PROVIDER — Animated AI Form Auto-Fill State Management
// ═══════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/auto_form_model.dart';
import '../services/form_template_service.dart';
import '../../../core/services/document_vault_service.dart';
import '../../../providers/voice_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/citizen_profile_provider.dart';

// Future AWS Polly integration point for premium voice synthesis

/// Manages the full lifecycle of a smart auto-fill form:
/// template loading → data extraction → animated fill → voice explanation → review.
class AutoFormProvider extends ChangeNotifier {
  // ─── State ──────────────────────────────────────────────────────────────────
  SmartFormTemplate? _template;
  Map<String, String?> _filledValues = {};
  Map<String, String> _dataSources = {}; // fieldId → source doc label
  Map<String, dynamic> _rawProfileData =
      {}; // Full profile capture for JS heuristics
  List<String> _emptyFieldIds = [];
  int _filledCount = 0;
  int _totalCount = 0;

  bool _isLoading = false;
  bool _isAnimating = false;
  bool _isExplaining = false;
  bool _animationSkipped = false;
  int _animatedFieldIndex = -1; // which field is animating currently
  int _currentExplainIndex = -1;
  String? _errorMessage;

  // ─── Getters ────────────────────────────────────────────────────────────────
  SmartFormTemplate? get template => _template;
  Map<String, String?> get filledValues => Map.unmodifiable(_filledValues);
  Map<String, String> get dataSources => Map.unmodifiable(_dataSources);
  List<String> get emptyFieldIds => List.unmodifiable(_emptyFieldIds);
  int get filledCount => _filledCount;
  int get totalCount => _totalCount;
  double get fillPercentage => _totalCount > 0 ? _filledCount / _totalCount : 0;

  bool get isLoading => _isLoading;
  bool get isAnimating => _isAnimating;
  bool get isExplaining => _isExplaining;
  int get animatedFieldIndex => _animatedFieldIndex;
  int get currentExplainIndex => _currentExplainIndex;
  String? get errorMessage => _errorMessage;

  // ─── Source label helper ────────────────────────────────────────────────────
  static const _sourceLabels = {
    'aadhaar': 'Aadhaar Card',
    'pan': 'PAN Card',
    'passport': 'Passport',
    'bankPassbook': 'Bank Passbook',
    'incomeCertificate': 'Income Certificate',
    'profile': 'Your Profile',
    'manual': 'Manual Input',
  };

  String getSourceLabel(String fieldId) =>
      _dataSources[fieldId] ?? 'Manual Input';

  // ─── Load Template ──────────────────────────────────────────────────────────

  Future<void> loadTemplate(String serviceId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _template = await FormTemplateService.loadTemplate(serviceId);
      if (_template == null) {
        _errorMessage = 'No form template available for this service.';
      } else {
        _totalCount = _template!.fields.length;
        // Initialize empty values
        _filledValues = {for (var f in _template!.fields) f.id: null};
      }
    } catch (e) {
      _errorMessage = 'Failed to load form template.';
      debugPrint('[AutoFormProvider] Load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Auto-Fill from Document Vault (FormAutoFillMapper) ─────────────────────

  /// Pulls data from AWS Amplify extracted data and maps to form fields.
  /// This is the FormAutoFillMapper layer — converts extracted data → field values.
  Future<void> autoFillFromVault() async {
    if (_template == null) return;

    try {
      final userData = await DocumentVaultService.getUserExtractedData();
      if (userData == null) {
        debugPrint('[AutoFormProvider] No extracted data available.');
        return;
      }

      _mapExtractedDataToFields(userData);
    } catch (e) {
      debugPrint('[AutoFormProvider] Auto-fill error: $e');
    }
  }

  // ─── Auto-Fill from User Profile ────────────────────────────────────────────

  /// Pulls data from UserProvider and CitizenProfileProvider and fills fields
  /// that match by dataKey. This fetches age, phone, email, name, state, etc.
  void autoFillFromProfile({
    required UserProvider userProvider,
    required CitizenProfileProvider citizenProvider,
  }) {
    if (_template == null) return;

    // Build a combined profile data map
    final profileData = <String, dynamic>{};

    // From UserProvider
    final user = userProvider.currentUser;
    if (user.name.isNotEmpty && user.name != 'Guest User') {
      profileData['full_name'] = user.name;
    }
    if (user.email.isNotEmpty && user.email != 'guest@civic.app') {
      profileData['email'] = user.email;
    }
    if (user.phone.isNotEmpty) profileData['mobile_number'] = user.phone;
    if (user.age != null) profileData['age'] = user.age.toString();
    if (user.annualIncome != null) {
      profileData['annual_income'] = user.annualIncome!.toStringAsFixed(0);
    }
    if (user.occupation != null) profileData['occupation'] = user.occupation;
    if (user.location != null) profileData['location'] = user.location;

    // From CitizenProfileProvider (overrides with more specific data)
    final citizen = citizenProvider.profile;
    if (citizen != null) {
      if (citizen.fullName.isNotEmpty) {
        profileData['full_name'] = citizen.fullName;
      }
      if (citizen.mobile.isNotEmpty) {
        profileData['mobile_number'] = citizen.mobile;
      }
      if (citizen.email.isNotEmpty) {
        profileData['email'] = citizen.email;
      }
      if (citizen.state.isNotEmpty) profileData['state'] = citizen.state;
      if (citizen.district != null && citizen.district!.isNotEmpty) {
        profileData['district'] = citizen.district;
      }
      if (citizen.age > 0) profileData['age'] = citizen.age.toString();
      if (citizen.income > 0) {
        profileData['annual_income'] = citizen.income.toStringAsFixed(0);
      }
    }

    _rawProfileData = Map<String, dynamic>.from(profileData);

    // Map profile data to unfilled fields only
    for (final field in _template!.fields) {
      // Skip already-filled fields (from vault)
      final current = _filledValues[field.id];
      if (current != null && current.isNotEmpty) continue;

      final rawValue = profileData[field.dataKey];
      if (rawValue != null &&
          rawValue.toString().isNotEmpty &&
          rawValue.toString() != 'null') {
        _filledValues[field.id] = rawValue.toString();
        _dataSources[field.id] = 'Your Profile';
      }
    }

    _recalculateStats();
    notifyListeners();
  }

  /// Internal mapper: converts raw extracted data map → form field values.
  void _mapExtractedDataToFields(Map<String, dynamic> userData) {
    final empty = <String>[];
    int filled = 0;

    for (final field in _template!.fields) {
      final rawValue = userData[field.dataKey];
      String? value;

      if (rawValue != null &&
          rawValue.toString().isNotEmpty &&
          rawValue.toString() != 'null') {
        value = rawValue.toString();

        // Format dates
        if (field.fieldType == 'date' && value.isNotEmpty) {
          try {
            final date = DateTime.parse(value);
            value = '${date.day.toString().padLeft(2, '0')}/'
                '${date.month.toString().padLeft(2, '0')}/'
                '${date.year}';
          } catch (_) {}
        }

        _filledValues[field.id] = value;
        _dataSources[field.id] =
            _sourceLabels[field.sourceDocument] ?? field.sourceDocument;
        filled++;
      } else {
        _filledValues[field.id] = null;
        empty.add(field.id);
      }
    }

    _filledCount = filled;
    _emptyFieldIds = empty;
    notifyListeners();
  }

  // ─── Animated Sequential Fill ───────────────────────────────────────────────

  /// Triggers sequential field-by-field fill with staggered delays.
  /// Shows each field lighting up one-by-one.
  Future<void> startAnimatedFill({int delayMs = 250}) async {
    if (_template == null) return;

    _isAnimating = true;
    _animationSkipped = false;
    _animatedFieldIndex = -1;
    notifyListeners();

    // Save current values and clear for animation
    final savedValues = Map<String, String?>.from(_filledValues);
    final savedSources = Map<String, String>.from(_dataSources);
    _filledValues = {for (var f in _template!.fields) f.id: null};
    _filledCount = 0;
    notifyListeners();

    // Animate each field
    for (int i = 0; i < _template!.fields.length; i++) {
      if (_animationSkipped) break;

      final field = _template!.fields[i];
      _animatedFieldIndex = i;

      if (savedValues[field.id] != null) {
        _filledValues[field.id] = savedValues[field.id];
        _dataSources[field.id] = savedSources[field.id] ?? '';
        _filledCount++;
      }

      notifyListeners();

      if (!_animationSkipped) {
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }

    // Restore any remaining values
    _filledValues = savedValues;
    _dataSources = savedSources;
    _recalculateStats();
    _isAnimating = false;
    _animatedFieldIndex = -1;
    notifyListeners();
  }

  /// Skip the animation and show all fields immediately.
  void skipAnimation() {
    _animationSkipped = true;
  }

  // ─── Manual Field Update ────────────────────────────────────────────────────

  void updateField(String fieldId, String value) {
    _filledValues[fieldId] = value.isEmpty ? null : value;
    if (value.isNotEmpty) {
      _dataSources[fieldId] = 'Manual Input';
    } else {
      _dataSources.remove(fieldId);
    }
    _recalculateStats();
    notifyListeners();
  }

  // ─── Voice Explanation ──────────────────────────────────────────────────────

  Timer? _explainTimer;

  /// Walks through form info using TTS:
  /// 1. Form name + importance
  /// 2. List of required fields/documents
  /// 3. Each field's individual explanation
  Future<void> startVoiceExplanation({
    required String langCode,
    required VoiceProvider voiceProvider,
  }) async {
    if (_template == null) return;

    _isExplaining = true;
    _currentExplainIndex = -1;
    notifyListeners();

    // Set TTS language
    await voiceProvider.setLanguage(langCode);

    // Step 1: Form name + intro/importance
    final formName = _template!.getTitle(langCode);
    final introMap = {
      'en': 'This is $formName form.',
      'hi': 'यह $formName फॉर्म है।',
      'ta': 'இது $formName படிவம்.',
      'mr': 'हा $formName फॉर्म आहे.',
    };
    await voiceProvider.speakAndWait(introMap[langCode] ?? introMap['en']!);
    await Future.delayed(const Duration(milliseconds: 400));

    if (!_isExplaining) return;

    // Speak custom intro if available
    final intro = _template!.getIntro(langCode);
    if (intro.isNotEmpty) {
      await voiceProvider.speakAndWait(intro);
      await Future.delayed(const Duration(milliseconds: 400));
    }

    if (!_isExplaining) return;

    // Step 2: List required fields/documents
    final requiredFields = _template!.fields
        .where((f) => f.required)
        .map((f) => f.getLabel(langCode))
        .toList();

    if (requiredFields.isNotEmpty) {
      final reqIntroMap = {
        'en':
            'For filling this form, you will need the following: ${requiredFields.join(", ")}.',
        'hi':
            'इस फॉर्म को भरने के लिए आपको चाहिए: ${requiredFields.join(", ")}.',
        'ta':
            'இந்தப் படிவத்தை நிரப்ப உங்களுக்குத் தேவை: ${requiredFields.join(", ")}.',
        'mr':
            'हा फॉर्म भरण्यासाठी तुम्हाला लागेल: ${requiredFields.join(", ")}.',
      };
      await voiceProvider
          .speakAndWait(reqIntroMap[langCode] ?? reqIntroMap['en']!);
      await Future.delayed(const Duration(milliseconds: 400));
    }

    if (!_isExplaining) return;

    // Step 3: Explain each field individually
    final explainIntroMap = {
      'en': 'Now let me explain each field.',
      'hi': 'अब मैं हर फील्ड समझाता हूँ।',
      'ta': 'இப்போது ஒவ்வொரு புலத்தையும் விளக்குகிறேன்.',
      'mr': 'आता प्रत्येक फील्ड समजावतो.',
    };
    await voiceProvider
        .speakAndWait(explainIntroMap[langCode] ?? explainIntroMap['en']!);
    await Future.delayed(const Duration(milliseconds: 300));

    for (int i = 0; i < _template!.fields.length; i++) {
      if (!_isExplaining) break;

      _currentExplainIndex = i;
      notifyListeners();

      final field = _template!.fields[i];
      final explanation = field.getExplanation(langCode);

      if (explanation.isNotEmpty) {
        await voiceProvider.speakAndWait(explanation);
        // Smooth pause between fields
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }

    _isExplaining = false;
    _currentExplainIndex = -1;
    notifyListeners();
  }

  // ─── Voice Readout of Filled Data ───────────────────────────────────────────

  bool _isReadingFilledData = false;
  bool get isReadingFilledData => _isReadingFilledData;

  /// Announces all filled field values via TTS, field-by-field.
  /// e.g. "Name: Vikram Singh, filled from Aadhaar Card"
  Future<void> speakFilledData({
    required String langCode,
    required VoiceProvider voiceProvider,
  }) async {
    if (_template == null) return;

    _isReadingFilledData = true;
    _currentExplainIndex = -1;
    notifyListeners();

    await voiceProvider.setLanguage(langCode);

    // Intro message per language
    final introMap = {
      'en': 'Here is your filled form data.',
      'hi': 'यह आपका भरा हुआ फॉर्म डेटा है।',
      'ta': 'இது உங்கள் நிரப்பப்பட்ட படிவ தரவு.',
    };
    await voiceProvider.speak(introMap[langCode] ?? introMap['en']!);
    await _waitForSpeechComplete(voiceProvider);

    if (!_isReadingFilledData) return;

    for (int i = 0; i < _template!.fields.length; i++) {
      if (!_isReadingFilledData) break;

      final field = _template!.fields[i];
      final value = _filledValues[field.id];
      if (value == null || value.isEmpty) continue;

      _currentExplainIndex = i;
      notifyListeners();

      // Build speech text per language
      final label = field.getLabel(langCode);
      final source = _dataSources[field.id] ?? '';
      final displayValue = field.sensitive && value.length > 4
          ? 'ending in ${value.substring(value.length - 4)}'
          : value;

      String speech;
      switch (langCode) {
        case 'hi':
          speech = '$label: $displayValue';
          if (source.isNotEmpty) speech += ', $source से भरा गया';
          break;
        case 'ta':
          speech = '$label: $displayValue';
          if (source.isNotEmpty) speech += ', $source இருந்து நிரப்பப்பட்டது';
          break;
        default:
          speech = '$label: $displayValue';
          if (source.isNotEmpty) speech += ', filled from $source';
      }

      await voiceProvider.speak(speech);
      await _waitForSpeechComplete(voiceProvider);
    }

    // Summary
    final summaryMap = {
      'en':
          '$_filledCount out of $_totalCount fields filled. ${_emptyFieldIds.length} fields need manual input.',
      'hi':
          '$_filledCount में से $_totalCount फ़ील्ड भरे गए। ${_emptyFieldIds.length} फ़ील्ड में मैन्युअल इनपुट आवश्यक है।',
      'ta':
          '$_totalCount புலங்களில் $_filledCount நிரப்பப்பட்டது. ${_emptyFieldIds.length} புலங்களுக்கு கையமுறை உள்ளீடு தேவை.',
    };
    if (_isReadingFilledData) {
      await voiceProvider.speak(summaryMap[langCode] ?? summaryMap['en']!);
      await _waitForSpeechComplete(voiceProvider);
    }

    _isReadingFilledData = false;
    _currentExplainIndex = -1;
    notifyListeners();
  }

  /// Stop voice readout of filled data.
  Future<void> stopReadingFilledData(VoiceProvider voiceProvider) async {
    _isReadingFilledData = false;
    _currentExplainIndex = -1;
    await voiceProvider.stopSpeaking();
    notifyListeners();
  }

  /// Wait for TTS to finish speaking.
  Future<void> _waitForSpeechComplete(VoiceProvider voiceProvider) async {
    // Poll until TTS is done (max 30 seconds per field)
    int waited = 0;
    while (voiceProvider.isSpeaking && waited < 300 && _isExplaining) {
      await Future.delayed(const Duration(milliseconds: 100));
      waited++;
    }
    // Small pause between fields
    if (_isExplaining) {
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  /// Stop voice explanation.
  Future<void> stopVoiceExplanation(VoiceProvider voiceProvider) async {
    _isExplaining = false;
    _currentExplainIndex = -1;
    await voiceProvider.stopSpeaking();
    _explainTimer?.cancel();
    notifyListeners();
  }

  // ─── Get Filled Data for Submission ─────────────────────────────────────────

  /// Returns all non-null filled field values keyed by dataKey.
  Map<String, String> getFilledDataByDataKey() {
    if (_template == null) return {};

    final result = <String, String>{};

    // 1. Inject raw profile data as a baseline fallback
    _rawProfileData.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        result[key] = value.toString();

        // Auto-split names for better heuristics on web forms
        if (key == 'full_name' || key == 'name') {
          final parts = value.toString().trim().split(' ');
          if (parts.isNotEmpty) {
            result['firstname'] = parts.first;
            result['fname'] = parts.first;
            if (parts.length == 2) {
              result['lastname'] = parts.last;
              result['lname'] = parts.last;
            } else if (parts.length > 2) {
              result['middlename'] =
                  parts.sublist(1, parts.length - 1).join(' ');
              result['mname'] = result['middlename']!;
              result['lastname'] = parts.last;
              result['lname'] = parts.last;
            }
          }
        }
      }
    });

    // 2. Override with specific field values gathered from ID processing etc.
    for (final field in _template!.fields) {
      final val = _filledValues[field.id];
      if (val != null && val.isNotEmpty) {
        result[field.dataKey] = val;

        // Auto-split names for better heuristics on web forms
        if (field.dataKey == 'full_name' || field.dataKey == 'name') {
          final parts = val.trim().split(' ');
          if (parts.isNotEmpty) {
            result['firstname'] = parts.first;
            result['fname'] = parts.first;
            if (parts.length == 2) {
              result['lastname'] = parts.last;
              result['lname'] = parts.last;
            } else if (parts.length > 2) {
              result['middlename'] =
                  parts.sublist(1, parts.length - 1).join(' ');
              result['mname'] = result['middlename']!;
              result['lastname'] = parts.last;
              result['lname'] = parts.last;
            }
          }
        }
      }
    }
    return result;
  }

  /// Returns all filled values keyed by field label (for display).
  Map<String, String> getFilledDataByLabel(String langCode) {
    if (_template == null) return {};

    final result = <String, String>{};
    for (final field in _template!.fields) {
      final val = _filledValues[field.id];
      result[field.getLabel(langCode)] = val ?? '';
    }
    return result;
  }

  // ─── Internal ───────────────────────────────────────────────────────────────

  void _recalculateStats() {
    if (_template == null) return;

    int filled = 0;
    final empty = <String>[];

    for (final field in _template!.fields) {
      final val = _filledValues[field.id];
      if (val != null && val.isNotEmpty) {
        filled++;
      } else {
        empty.add(field.id);
      }
    }

    _filledCount = filled;
    _emptyFieldIds = empty;
  }

  /// Reset state for a new form.
  void reset() {
    _template = null;
    _filledValues = {};
    _dataSources = {};
    _emptyFieldIds = [];
    _filledCount = 0;
    _totalCount = 0;
    _isLoading = false;
    _isAnimating = false;
    _isExplaining = false;
    _animatedFieldIndex = -1;
    _currentExplainIndex = -1;
    _errorMessage = null;
    _explainTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _explainTimer?.cancel();
    super.dispose();
  }
}
