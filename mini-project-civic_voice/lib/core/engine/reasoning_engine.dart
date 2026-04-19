import 'package:civic_voice_interface/models/scheme_model.dart';

enum Intent { discovery, schemeInfo, eligibility, documents, process, unknown }

class ReasoningEngine {
  final String languageCode; // 'en' or 'hi'

  ReasoningEngine({this.languageCode = 'en'});

  Intent parseIntent(String text) {
    text = text.toLowerCase();
    
    if (text.contains('pension') || text.contains('वृद्धावस्था') || text.contains('paisa') || text.contains('money')) {
      return Intent.schemeInfo;
    }
    if (text.contains('eligible') || text.contains('योग्य') || text.contains('पात्र')) {
      return Intent.eligibility;
    }
    if (text.contains('document') || text.contains('कागजात') || text.contains('proof')) {
      return Intent.documents;
    }
    if (text.contains('apply') || text.contains('आवेदन') || text.contains('kaise')) {
      return Intent.process;
    }
    
    return Intent.discovery;
  }

  String detectSchemeId(String text) {
    text = text.toLowerCase();
    if (text.contains('pension')) return 'pension';
    if (text.contains('ration') || text.contains('राशन')) return 'ration';
    if (text.contains('kisan') || text.contains('kheti') || text.contains('किसान')) return 'pm-kisan';
    if (text.contains('school') || text.contains('scholar') || text.contains('छात्रवृत्ति')) return 'scholarship';
    if (text.contains('medical') || text.contains('ayushman') || text.contains('health') || text.contains('इलाज')) return 'ayushman';
    return 'pension'; // Default for now
  }

  String generateResponse(Intent intent, GovernmentScheme scheme, Map<String, dynamic> context) {
    bool isHindi = languageCode == 'hi';

    switch (intent) {
      case Intent.schemeInfo:
        return isHindi 
            ? '${scheme.names['hi']} के बारे में: ${scheme.description} क्या आप इसके लिए अपनी योग्यता (eligibility) जांचना चाहते हैं?'
            : 'About ${scheme.names['en']}: ${scheme.description} Would you like to check your eligibility for this?';
      
      case Intent.eligibility:
        return _formatEligibilityResponse(scheme, context, isHindi);
      
      case Intent.documents:
        String docs = scheme.requiredDocuments.map((d) => '- ${isHindi ? d.name['hi'] : d.name['en']} (${isHindi ? d.reason['hi'] : d.reason['en']})').join('\n');
        return isHindi 
            ? '${scheme.names['hi']} के लिए आवश्यक दस्तावेज:\n$docs\nक्या आपके पास ये दस्तावेज हैं?'
            : 'Documents required for ${scheme.names['en']}:\n$docs\nDo you have these documents?';
      
      case Intent.process:
        String steps = scheme.steps.map((s) => 'Step ${s.number}: ${isHindi ? s.title['hi'] : s.title['en']} - ${isHindi ? s.instruction['hi'] : s.instruction['en']}').join('\n');
        return isHindi
            ? 'यहाँ आवेदन की प्रक्रिया है:\n$steps'
            : 'Here is the application process:\n$steps';
      
      case Intent.discovery:
        return isHindi
            ? 'नमस्ते! मैं आपकी कैसे मदद कर सकता हूँ? क्या आप पेंशन, राशन कार्ड, या किसी अन्य योजना के बारे में जानना चाहते हैं?'
            : 'Hello! How can I help you today? Would you like to know about Pension, Ration Card, or any other scheme?';
      
      default:
        return isHindi ? 'माफ़ कीजिये, मैं समझ नहीं पाया। कृपया फिर से कहें।' : "I'm sorry, I didn't quite catch that. Could you please repeat?";
    }
  }

  String _formatEligibilityResponse(GovernmentScheme scheme, Map<String, dynamic> context, bool isHindi) {
    List<String> missing = [];
    for (var rule in scheme.eligibilityRules) {
      if (!context.containsKey(rule.parameter)) {
        missing.add(rule.parameter);
      }
    }

    if (missing.isNotEmpty) {
      var rule = scheme.eligibilityRules.firstWhere((r) => r.parameter == missing.first);
      return isHindi ? rule.question['hi']! : rule.question['en']!;
    }

    // All data present, check logic
    bool eligible = true;
    String reason = '';
    for (var rule in scheme.eligibilityRules) {
      if (!rule.check(context[rule.parameter])) {
        eligible = false;
        reason = isHindi ? rule.explanation['hi']! : rule.explanation['en']!;
        break;
      }
    }

    if (eligible) {
      return isHindi 
          ? 'बधाई हो! आप ${scheme.names['hi']} के लिए पात्र (eligible) हैं। क्या आप दस्तावेजों की सूची देखना चाहते हैं?'
          : 'Congratulations! You are eligible for ${scheme.names['en']}. Would you like to see the required documents?';
    } else {
      return isHindi
          ? 'क्षमा करें, आप पात्र (eligible) नहीं हैं। कारण: $reason। क्या आप किसी अन्य योजना के बारे में जानना चाहते हैं?'
          : 'I am sorry, you are not eligible. Reason: $reason. Would you like to explore other schemes?';
    }
  }
}
