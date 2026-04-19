
// ═════════════════════════════════════════════════════════════════════════════
// INTENT ENGINE  — local NLP intent classifier (no server needed)
// ═════════════════════════════════════════════════════════════════════════════

enum CviIntent {
  greeting,
  serviceInfo,
  checkEligibility,
  listDocuments,
  getSteps,
  getTimeline,
  getFees,
  getHelpline,
  switchLanguage,
  goodbye,
  unknown,
}

class IntentResult {
  final CviIntent intent;
  final String? serviceId;
  final double confidence;

  const IntentResult({
    required this.intent,
    this.serviceId,
    this.confidence = 0.8,
  });
}

class IntentEngine {
  IntentEngine._();

  // ── Service keyword maps ───────────────────────────────────────────────────

  static const _serviceKeywords = <String, List<String>>{
    'aadhaar_card': [
      'aadhaar', 'aadhar', 'uid', 'uidai', 'unique id',
      'आधार', 'आधार कार्ड', 'uidai',
      'ஆதார்', 'ஆதார் அட்டை',
      'आधार',
    ],
    'pan_card': [
      'pan card', 'pan', 'permanent account number', 'income tax id',
      'पैन', 'पैन कार्ड', 'स्थायी खाता संख्या',
      'பான் கார்டு', 'பான்',
    ],
    'passport': [
      'passport', 'travel document', 'travel book', 'mea', 'passportindia',
      'पासपोर्ट', 'यात्रा दस्तावेज',
      'பாஸ்போர்ட்', 'கடவுச்சீட்டு',
    ],
    'driving_license': [
      'driving license', 'driving licence', 'dl', 'driver license',
      'rto', 'vehicle license', 'motor license',
      'ड्राइविंग लाइसेंस', 'वाहन परवाना', 'चालक अनुज्ञापत्र',
      'வாகன உரிமம்', 'ஓட்டுனர் உரிமம்',
    ],
    'land_records': [
      'land record', 'land', 'bhoomi', 'khasra', 'khata', 'bhulekh',
      'property record', 'plot record',
      'भूमि', 'जमीन', 'भूलेख', 'खसरा', 'खाता',
      'நில பதிவு', 'நிலம்',
    ],
    'birth_certificate': [
      'birth certificate', 'birth cert', 'birth registration',
      'janam praman patra', 'janam',
      'जन्म प्रमाण पत्र', 'जन्म', 'जन्म प्रमाणपत्र',
      'பிறப்பு சான்றிதழ்', 'பிறப்பு',
    ],
    'ration_card': [
      'ration card', 'ration', 'pds', 'food card', 'food subsidy',
      'राशन कार्ड', 'राशन', 'राशन',
      'ரேஷன் கார்டு', 'ரேஷன்',
    ],
    'senior_citizen_pension': [
      'pension', 'senior citizen', 'old age pension', 'nsap',
      'retirement benefit', 'vridha pension',
      'पेंशन', 'वृद्धावस्था पेंशन', 'बुजुर्ग पेंशन',
      'பென்ஷன்', 'முதியோர் ஓய்வூதியம்',
    ],
  };

  // ── Intent keyword maps ────────────────────────────────────────────────────

  static const _greetings = [
    'hello', 'hi', 'hey', 'namaste', 'namaskar', 'good morning',
    'नमस्ते', 'नमस्कार', 'हेलो', 'हाय',
    'வணக்கம்', 'நமஸ்தே',
    'नमस्कार', 'हॅलो',
  ];

  static const _goodbyes = [
    'bye', 'goodbye', 'thank you', 'thanks', 'tata', 'see you', 'quit', 'exit',
    'धन्यवाद', 'शुक्रिया', 'अलविदा', 'बाय',
    'நன்றி', 'விடைபெறுகிறேன்',
  ];

  static const _eligibilityKw = [
    'eligible', 'eligibility', 'qualify', 'who can', 'who can apply',
    'criteria', 'am i eligible', 'requirement',
    'पात्रता', 'योग्यता', 'कौन आवेदन', 'पात्र',
    'தகுதி', 'தகுதி அளவுகோல்',
  ];

  static const _documentsKw = [
    'document', 'documents', 'papers', 'proof', 'evidence', 'required document',
    'what do i need', 'what papers',
    'दस्तावेज', 'कागज', 'प्रमाण', 'क्या चाहिए',
    'ஆவணம்', 'கடிதம்', 'அத்தாட்சி',
  ];

  static const _stepsKw = [
    'step', 'steps', 'process', 'procedure', 'how to apply', 'how do i apply',
    'apply', 'guide', 'walkthrough', 'tutorial',
    'कैसे आवेदन', 'आवेदन कैसे करें', 'प्रक्रिया', 'कदम',
    'எப்படி விண்ணப்பிக்க', 'விண்ணப்ப செயல்முறை',
  ];

  static const _timelineKw = [
    'timeline', 'how long', 'days', 'time', 'duration', 'when will',
    'processing time', 'how many days',
    'कितने दिन', 'समय', 'कब मिलेगा',
    'எத்தனை நாள்', 'கால அவகாசம்',
  ];

  static const _feesKw = [
    'fee', 'fees', 'cost', 'charge', 'price', 'how much', 'money', 'pay',
    'payment', 'free', 'rupee',
    'शुल्क', 'कितना', 'पैसे', 'मुफ्त', 'शुल्क क्या है',
    'கட்டணம்', 'செலவு', 'எவ்வளவு',
  ];

  static const _helplineKw = [
    'helpline', 'contact', 'phone', 'number', 'call', 'toll free', 'customer care',
    'support number',
    'हेल्पलाइन', 'संपर्क', 'फोन', 'नंबर',
    'உதவி எண்', 'தொலைபேசி',
  ];

  static const _langSwitchKw = [
    'switch to', 'change language', 'speak in', 'hindi', 'english',
    'marathi', 'tamil', 'हिंदी में', 'मराठी में',
  ];

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Classify [input] text and return a structured [IntentResult].
  static IntentResult classify(String input) {
    final text = input.toLowerCase().trim();

    if (_matchAny(text, _greetings)) {
      return const IntentResult(intent: CviIntent.greeting, confidence: 1.0);
    }
    if (_matchAny(text, _goodbyes)) {
      return const IntentResult(intent: CviIntent.goodbye, confidence: 1.0);
    }
    if (_matchAny(text, _langSwitchKw)) {
      return const IntentResult(
          intent: CviIntent.switchLanguage, confidence: 0.9);
    }

    final serviceId = _detectService(text);

    if (_matchAny(text, _eligibilityKw)) {
      return IntentResult(
          intent: CviIntent.checkEligibility,
          serviceId: serviceId,
          confidence: 0.9);
    }
    if (_matchAny(text, _documentsKw)) {
      return IntentResult(
          intent: CviIntent.listDocuments,
          serviceId: serviceId,
          confidence: 0.9);
    }
    if (_matchAny(text, _stepsKw)) {
      return IntentResult(
          intent: CviIntent.getSteps,
          serviceId: serviceId,
          confidence: 0.9);
    }
    if (_matchAny(text, _feesKw)) {
      return IntentResult(
          intent: CviIntent.getFees,
          serviceId: serviceId,
          confidence: 0.9);
    }
    if (_matchAny(text, _timelineKw)) {
      return IntentResult(
          intent: CviIntent.getTimeline,
          serviceId: serviceId,
          confidence: 0.85);
    }
    if (_matchAny(text, _helplineKw)) {
      return IntentResult(
          intent: CviIntent.getHelpline,
          serviceId: serviceId,
          confidence: 0.9);
    }
    if (serviceId != null) {
      return IntentResult(
          intent: CviIntent.serviceInfo,
          serviceId: serviceId,
          confidence: 0.85);
    }

    return const IntentResult(intent: CviIntent.unknown, confidence: 0.2);
  }

  static bool _matchAny(String input, List<String> keywords) =>
      keywords.any((kw) => input.contains(kw));

  static String? _detectService(String text) {
    for (final entry in _serviceKeywords.entries) {
      if (entry.value.any((kw) => text.contains(kw))) {
        return entry.key;
      }
    }
    return null;
  }
}
