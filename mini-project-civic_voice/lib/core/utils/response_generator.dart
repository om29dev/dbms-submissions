import '../../models/service_model.dart';
import 'intent_engine.dart';

// ═════════════════════════════════════════════════════════════════════════════
// RESPONSE GENERATOR — formats structured CVI reply text from intent + service
// ═════════════════════════════════════════════════════════════════════════════

class ResponseGenerator {
  ResponseGenerator._();

  /// Generates a formatted response string for the given [intent], [service],
  /// and [language] code ('en' | 'hi' | 'mr' | 'ta').
  static String generate({
    required IntentResult intent,
    ServiceModel? service,
    String language = 'en',
  }) {
    return switch (intent.intent) {
      CviIntent.greeting      => _greeting(language),
      CviIntent.goodbye       => _goodbye(language),
      CviIntent.serviceInfo   => _serviceInfo(service, language),
      CviIntent.checkEligibility => _eligibility(service, language),
      CviIntent.listDocuments => _documents(service, language),
      CviIntent.getSteps      => _steps(service, language),
      CviIntent.getTimeline   => _timeline(service, language),
      CviIntent.getFees       => _fees(service, language),
      CviIntent.getHelpline   => _helpline(service, language),
      CviIntent.switchLanguage => _languageSwitch(language),
      CviIntent.unknown       => _unknown(language),
    };
  }

  // ── Greeting ───────────────────────────────────────────────────────────────

  static String _greeting(String lang) => switch (lang) {
        'hi' =>
          'नमस्ते! मैं CVI हूँ — आपका डिजिटल भारत सहायक। 🇮🇳\n\n'
          'मैं इन सेवाओं में मदद कर सकता हूँ:\n'
          '• आधार कार्ड\n• पैन कार्ड\n• पासपोर्ट\n• ड्राइविंग लाइसेंस\n'
          '• जन्म प्रमाण पत्र\n• राशन कार्ड\n• भूमि अभिलेख\n• वृद्धावस्था पेंशन\n\n'
          'आप क्या जानना चाहते हैं?',
        'mr' =>
          'नमस्कार! मी CVI आहे — तुमचा सरकारी सेवा मार्गदर्शक. 🇮🇳\n\n'
          'मी मदत करू शकतो:\n'
          '• आधार कार्ड\n• पॅन कार्ड\n• पासपोर्ट\n• वाहन परवाना\n'
          '• जन्म दाखला\n• रेशन कार्ड\n• जमीन नोंदी\n• वृद्धापकाळ पेंशन\n\n'
          'तुम्हाला कशाची माहिती हवी आहे?',
        'ta' =>
          'வணக்கம்! நான் CVI — உங்கள் அரசு சேவை வழிகாட்டி. 🇮🇳\n\n'
          'நான் உதவுவேன்:\n'
          '• ஆதார் அட்டை\n• பான் அட்டை\n• கடவுச்சீட்டு\n• வாகன உரிமம்\n'
          '• பிறப்புச் சான்றிதழ்\n• ரேஷன் அட்டை\n• நில பதிவுகள்\n• முதியோர் ஓய்வூதியம்\n\n'
          'நீங்கள் எதைப் பற்றி தெரிந்துகொள்ள விரும்புகிறீர்கள்?',
        _ =>
          'Namaste! I\'m CVI — your AI guide for Indian government services. 🇮🇳\n\n'
          'I can help you with:\n'
          '• Aadhaar Card\n• PAN Card\n• Passport\n• Driving License\n'
          '• Birth Certificate\n• Ration Card\n• Land Records\n• Senior Citizen Pension\n\n'
          'What would you like to know?',
      };

  // ── Goodbye ────────────────────────────────────────────────────────────────

  static String _goodbye(String lang) => switch (lang) {
        'hi' => 'धन्यवाद! यदि भविष्य में कोई सहायता चाहिए तो वापस आएँ। जय हिन्द! 🇮🇳',
        'mr' => 'धन्यवाद! पुन्हा कधीही मदत लागल्यास परत या. जय हिंद! 🇮🇳',
        'ta' => 'நன்றி! மீண்டும் உதவி தேவைப்பட்டால் வாருங்கள். ஜய் ஹிந்த்! 🇮🇳',
        _    => 'Thank you for using CVI! Come back any time. Jai Hind! 🇮🇳',
      };

  // ── Service Info ───────────────────────────────────────────────────────────

  static String _serviceInfo(ServiceModel? service, String lang) {
    if (service == null) return _askWhich(lang);
    final name = service.localizedName(lang);
    final desc = service.localizedDescription(lang);
    return switch (lang) {
      'hi' =>
        '**${service.iconEmoji} $name**\n\n$desc\n\n'
        '📋 पात्रता: ${service.eligibilityCriteria.length} मानदंड\n'
        '📄 जरूरी दस्तावेज: ${service.requiredDocuments.length} दस्तावेज\n'
        '⏱️ समयसीमा: ${service.estimatedTimeline}\n'
        '💰 शुल्क: ${service.fees}\n\n'
        '"कदम दिखाएं" कहें — step-by-step guide के लिए!',
      'ta' =>
        '**${service.iconEmoji} $name**\n\n$desc\n\n'
        '📋 தகுதி: ${service.eligibilityCriteria.length} நிபந்தனைகள்\n'
        '📄 ஆவணங்கள்: ${service.requiredDocuments.length} ஆவணங்கள்\n'
        '⏱️ காலம்: ${service.estimatedTimeline}\n'
        '💰 கட்டணம்: ${service.fees}\n\n'
        'கட்டங்களை காட்ட "படிகள் காட்டு" என்று சொல்லுங்கள்!',
      _ =>
        'Here\'s what you need to know about **${service.iconEmoji} $name**:\n\n'
        '$desc\n\n'
        '📋 Eligibility: ${service.eligibilityCriteria.length} criteria to check\n'
        '📄 Documents needed: ${service.requiredDocuments.length} documents\n'
        '⏱️ Timeline: ${service.estimatedTimeline}\n'
        '💰 Fees: ${service.fees}\n\n'
        'Say "show me the steps" for a step-by-step guide!',
    };
  }

  // ── Eligibility ────────────────────────────────────────────────────────────

  static String _eligibility(ServiceModel? service, String lang) {
    if (service == null) return _askWhich(lang);
    final name = service.localizedName(lang);
    final list = service.eligibilityCriteria
        .asMap()
        .entries
        .map((e) => '${e.key + 1}. ${e.value}')
        .join('\n');
    return switch (lang) {
      'hi' => '✅ **$name के लिए पात्रता**\n\n$list',
      'ta' => '✅ **$name-க்கான தகுதி நிபந்தனைகள்**\n\n$list',
      _    => '✅ **Eligibility for $name**\n\n$list',
    };
  }

  // ── Documents ──────────────────────────────────────────────────────────────

  static String _documents(ServiceModel? service, String lang) {
    if (service == null) return _askWhich(lang);
    final name = service.localizedName(lang);
    final list = service.requiredDocuments
        .map((d) => '${d.isOptional ? "⭕" : "✅"} **${d.name}**: ${d.description}')
        .join('\n\n');
    return switch (lang) {
      'hi' =>
        '📄 **$name के लिए आवश्यक दस्तावेज**\n\n$list\n\n'
        '_(⭕ = वैकल्पिक, ✅ = अनिवार्य)_',
      'ta' =>
        '📄 **$name-க்கு தேவையான ஆவணங்கள்**\n\n$list\n\n'
        '_(⭕ = விருப்ப, ✅ = கட்டாயம்)_',
      _ =>
        '📄 **Documents required for $name**\n\n$list\n\n'
        '_(⭕ = optional, ✅ = required)_',
    };
  }

  // ── Steps ──────────────────────────────────────────────────────────────────

  static String _steps(ServiceModel? service, String lang) {
    if (service == null) return _askWhich(lang);
    final name = service.localizedName(lang);
    final list = service.steps
        .map((s) => '**Step ${s.number}: ${s.title}**\n${s.description}')
        .join('\n\n');
    return switch (lang) {
      'hi' => '🔢 **$name के लिए आवेदन कैसे करें**\n\n$list',
      'ta' => '🔢 **$name-க்கு விண்ணப்பிக்கும் முறை**\n\n$list',
      _    => '🔢 **How to apply for $name**\n\n$list',
    };
  }

  // ── Timeline ───────────────────────────────────────────────────────────────

  static String _timeline(ServiceModel? service, String lang) {
    if (service == null) return _askWhich(lang);
    final name = service.localizedName(lang);
    return switch (lang) {
      'hi' =>
        '⏱️ **$name की समयसीमा**\n\n${service.estimatedTimeline}\n\n'
        'यह अनुमानित समय है। राज्य और आवेदन की मात्रा के अनुसार भिन्न हो सकता है।',
      'ta' =>
        '⏱️ **$name-க்கான கால அவகாசம்**\n\n${service.estimatedTimeline}\n\n'
        'இது தோராயமான கால அளவு. மாநிலம் மற்றும் விண்ணப்பங்களின் எண்ணிக்கையைப் பொறுத்து மாறுபடலாம்.',
      _ =>
        '⏱️ **Timeline for $name**\n\n${service.estimatedTimeline}\n\n'
        'This is an estimate. Actual time may vary by state and application volume.',
    };
  }

  // ── Fees ───────────────────────────────────────────────────────────────────

  static String _fees(ServiceModel? service, String lang) {
    if (service == null) return _askWhich(lang);
    final name = service.localizedName(lang);
    return switch (lang) {
      'hi' => '💰 **$name के लिए शुल्क**\n\n${service.fees}',
      'ta' => '💰 **$name-க்கான கட்டணம்**\n\n${service.fees}',
      _    => '💰 **Fees for $name**\n\n${service.fees}',
    };
  }

  // ── Helpline ───────────────────────────────────────────────────────────────

  static String _helpline(ServiceModel? service, String lang) {
    if (service == null) return _askWhich(lang);
    final name = service.localizedName(lang);
    return switch (lang) {
      'hi' =>
        '📞 **$name हेल्पलाइन**\n\n'
        'संपर्क करें: **${service.helplineNumber}**\n\n'
        '🌐 आधिकारिक वेबसाइट: ${service.officialLink}',
      'ta' =>
        '📞 **$name உதவி எண்**\n\n'
        'அழைக்கவும்: **${service.helplineNumber}**\n\n'
        '🌐 அதிகாரப்பூர்வ இணையதளம்: ${service.officialLink}',
      _ =>
        '📞 **Helpline for $name**\n\n'
        'Call: **${service.helplineNumber}**\n\n'
        '🌐 Official website: ${service.officialLink}',
    };
  }

  // ── Language switch ────────────────────────────────────────────────────────

  static String _languageSwitch(String lang) => switch (lang) {
        'hi' => 'हिंदी मोड सक्रिय! अब आप हिंदी में प्रश्न पूछ सकते हैं। 🇮🇳',
        'mr' => 'मराठी मोड सुरू! आता मराठीत विचारा. 🇮🇳',
        'ta' => 'தமிழ் பயன்முறை செயலில் உள்ளது! இப்போது தமிழில் கேளுங்கள். 🇮🇳',
        _    => 'English mode active! Ask me anything in English.',
      };

  // ── Unknown ────────────────────────────────────────────────────────────────

  static String _unknown(String lang) => switch (lang) {
        'hi' =>
          'मुझे खेद है, मैं आपका प्रश्न समझ नहीं पाया। 🙏\n\n'
          'कृपया किसी सेवा का नाम बताएं जैसे "आधार", "पैन", "पासपोर्ट"।',
        'ta' =>
          'மன்னிக்கவும், புரியவில்லை. 🙏\n\n'
          '"ஆதார்", "பான்", "கடவுச்சீட்டு" போன்ற சேவையைக் குறிப்பிடுங்கள்.',
        _ =>
          'I\'m not sure I understood that. 🙏\n\n'
          'Try asking about "Aadhaar", "PAN card", "Passport" or say "help" for options.',
      };

  static String _askWhich(String lang) => switch (lang) {
        'hi' =>
          'कृपया बताएं आप किस सेवा के बारे में जानना चाहते हैं?\n'
          'उदाहरण: आधार, पैन, पासपोर्ट, ड्राइविंग लाइसेंस',
        'ta' =>
          'நீங்கள் எந்த சேவையைப் பற்றி தெரிந்துகொள்ள விரும்புகிறீர்கள்?\n'
          'உதாரணம்: ஆதார், பான், கடவுச்சீட்டு',
        _ =>
          'Which service are you asking about?\n'
          'Example: Aadhaar, PAN, Passport, Driving License',
      };
}
