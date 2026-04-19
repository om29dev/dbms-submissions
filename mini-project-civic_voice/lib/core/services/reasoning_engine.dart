import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'aws_bedrock_service.dart';
import 'scheme_knowledge_base.dart';

enum Intent {
  discovery,
  schemeInfo,
  eligibility,
  documents,
  process,
  ambiguous,
  unknown
}

class DetectionResult {
  final Intent intent;
  final String? schemeId;
  final double confidence;
  final List<String> ambiguousOptions;
  final List<String> detectedKeywords;

  DetectionResult({
    required this.intent,
    this.schemeId,
    this.confidence = 0.0,
    this.ambiguousOptions = const [],
    this.detectedKeywords = const [],
  });
}

class SmartIntentParser {
  // 1. Weighted Keyword Scorer with Synonyms
  static const Map<String, List<String>> schemeSynonyms = {
    'pension': [
      'old age',
      'widow',
      'money for elderly',
      'financial aid',
      'retirement',
      'senior citizen',
      'वृद्धावस्था',
      'पेंशन',
      '60 years'
    ],
    'ration': [
      'food',
      'grains',
      'bpl',
      'ration',
      'खाना',
      'अनाज',
      'rice',
      'wheat',
      'राशन'
    ],
    'pm-kisan': [
      'farmer',
      'kisan',
      'agriculture',
      'land',
      'खेती',
      'किसान',
      'farming',
      '2000 rupees'
    ],
    'ayushman': [
      'health',
      'medical',
      'hospital',
      'doctor',
      'treatment',
      'insurance',
      'इलाज',
      'स्वास्थ्य',
      'ayushman'
    ],
    'land': ['housing', 'awas', 'pmay', 'house', 'home', 'घर', 'आवास', 'roof'],
  };

  static const Map<String, Map<Intent, List<String>>> intentKeywords = {
    'en': {
      Intent.eligibility: [
        'eligible',
        'qualify',
        'can i',
        'check',
        'am i',
        'rules'
      ],
      Intent.documents: [
        'document',
        'paper',
        'proof',
        'certificate',
        'id',
        'required'
      ],
      Intent.process: [
        'apply',
        'how to',
        'register',
        'form',
        'steps',
        'procedure',
        'enroll'
      ],
    },
    'hi': {
      Intent.eligibility: ['पात्र', 'योग्य', 'सकता हूँ', 'नियम', 'check'],
      Intent.documents: ['दस्तावेज', 'कागजात', 'प्रमाण', 'आईडी', 'जरूरी'],
      Intent.process: ['आवेदन', 'कैसे', 'रजिस्टर', 'फॉर्म', 'प्रक्रिया', 'कदम'],
    },
    'mr': {
      Intent.eligibility: ['पात्र', 'योग्य', 'कसे', 'नियम', 'चेक'],
      Intent.documents: [
        'दस्तावेज',
        'कागदपत्रे',
        'प्रमाणपत्र',
        'आईडी',
        'आवश्यक'
      ],
      Intent.process: ['अर्ज', 'नोंदणी', 'कसे करायचे', 'प्रक्रिया', 'फॉर्म'],
    },
    'ta': {
      Intent.eligibility: ['தகுதி', 'தகுதியுள்ள', 'விதிமுறை', 'சேர முடியுமா'],
      Intent.documents: ['ஆவணம்', 'சான்றிதழ்', 'அடையாள அட்டை', 'தேவையான'],
      Intent.process: ['விண்ணப்பி', 'பதிவு செய்', 'முறை', 'படி நிலைகள்'],
    }
  };

  static DetectionResult parse(String text, String languageCode) {
    text = text.toLowerCase();

    // Detect Scheme first
    Map<String, double> schemeScores = {};
    Set<String> allDetectedKeywords = {};

    schemeSynonyms.forEach((id, keywords) {
      double score = 0.0;
      for (var keyword in keywords) {
        if (text.contains(keyword.toLowerCase())) {
          // Weight: Exact match is better than partial?
          // For now, simple presence. Longer keywords could be weighted higher.
          score += 1.0;
          allDetectedKeywords.add(keyword);
        }
      }
      if (score > 0) schemeScores[id] = score;
    });

    String? topScheme;
    List<String> ambiguousCandidates = [];
    double maxScore = 0.0;
    double totalConfidence = 0.0;

    if (schemeScores.isNotEmpty) {
      var sorted = schemeScores.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      maxScore = sorted.first.value;

      // Calculate simplistic confidence (maxScore / total keywords found or just raw score cap)
      // Let's normalize slightly: if score >= 1.0, we have at least one keyword.
      // Confidence logic:
      // 1 match = 0.5
      // 2 matches = 0.8
      // 3+ matches = 0.95
      if (maxScore == 1.0) {
        totalConfidence = 0.5;
      } else if (maxScore == 2.0) {
        totalConfidence = 0.8;
      } else {
        totalConfidence = 0.95;
      }

      // Ambiguity Check
      if (sorted.length > 1) {
        double secondScore = sorted[1].value;
        // If top two scores are close (within 1 point or equal)
        if (maxScore - secondScore < 1.0) {
          ambiguousCandidates = [sorted[0].key, sorted[1].key];
        }
      }

      if (ambiguousCandidates.isEmpty) {
        topScheme = sorted.first.key;
      }
    }

    // Detect Intent Type (Eligibility vs Docs vs Process vs Discovery)
    Intent detectedIntent = Intent.discovery; // Default
    // If scheme is found but no specific intent keywords, usually means "Tell me about X" -> schemeInfo
    if (topScheme != null || ambiguousCandidates.isNotEmpty) {
      detectedIntent = Intent.schemeInfo;
    }

    // Check specific intent keywords
    final langKey =
        ['en', 'hi', 'mr', 'ta'].contains(languageCode) ? languageCode : 'en';
    Map<Intent, List<String>> currentLangKeywords = intentKeywords[langKey]!;

    currentLangKeywords.forEach((intent, keywords) {
      for (var k in keywords) {
        if (text.contains(k)) {
          detectedIntent = intent;
          break;
        }
      }
    });

    // 3. Ambiguity Resolution
    if (ambiguousCandidates.isNotEmpty) {
      return DetectionResult(
          intent: Intent.ambiguous,
          ambiguousOptions: ambiguousCandidates,
          detectedKeywords: allDetectedKeywords.toList());
    }

    // Low Confidence Check -> Discovery
    if (totalConfidence < 0.4 && topScheme != null) {
      // If confidence is low, maybe we shouldn't guess parameters.
      // But for "pension", confidence is 0.5 (1 keyword), which is > 0.4. Good.
      // "money" -> 'pension' (1 match) -> 0.5.
    }

    if (topScheme == null) {
      return DetectionResult(
          intent: Intent.discovery,
          detectedKeywords: allDetectedKeywords.toList());
    }

    return DetectionResult(
      intent: detectedIntent,
      schemeId: topScheme,
      confidence: totalConfidence,
      detectedKeywords: allDetectedKeywords.toList(),
    );
  }
}

class ReasoningEngine {
  final String languageCode; // 'en' or 'hi'

  // Phase 4: Logic & Empathy - Partial Match Tracking
  final Set<String> _sessionKeywords = {};

  ReasoningEngine({this.languageCode = 'en'});

  // Legacy method replacement
  String detectSchemeId(String text) {
    final result = SmartIntentParser.parse(text, languageCode);
    return result.schemeId ?? '';
  }

  String _buildSystemInstruction() {
    final schemesSummary = SchemeKnowledgeBase.schemes.map((s) {
      return """
      Scheme: ${s.names['en']} (${s.names['hi']}) / ${s.names['ta'] ?? ''}
      ID: ${s.id}
      Description: ${s.description}
      Eligibility: ${s.eligibilityRules.map((r) => '${r.parameter} ${r.operator} ${r.value}').join(', ')}
      Documents: ${s.requiredDocuments.map((d) => d.name['en']).join(', ')}
      """;
    }).join("\n---\n");

    return """
    You are 'Civic Voice Assistant' (CVI), an advanced AI specialized in Indian Government Schemes.
    
    KNOWLEDGE BASE:
    $schemesSummary

    Your goal is to be a helpful, empathetic guide.

    Intelligence Guidelines:
    1. **"What-If" & Disqualification**:
       - Explain precisely WHY they might be disqualified.
       - IMMEDIATELY suggest 'Alternatives'.
    
    2. **Fraud Detection**:
       - If user mentions "paying money", "agent", "bribe", "password", TRIGGER FRAUD WARNING.
       - "⚠️ WARNING: Government schemes never ask for money or passwords. This sounds like a SCAM."

    3. **Actionable Commands**:
       - [ACTION:LINK], [ACTION:NAVIGATE], [ACTION:GUIDE], [ACTION:REMINDER] are supported.

    4. **Language**:
       - You MUST respond in the language code: $languageCode.
    """;
  }

  Future<String> generateAIResponse(
      String userInput, List<Map<String, String>> history) async {
    final detection = SmartIntentParser.parse(userInput, languageCode);
    _sessionKeywords.addAll(detection.detectedKeywords);

    // 1. Ambiguity Handling
    if (detection.intent == Intent.ambiguous) {
      String options = detection.ambiguousOptions.map((id) {
        var s = SchemeKnowledgeBase.getSchemeById(id);
        return s?.names[languageCode] ?? s?.names['en'] ?? id;
      }).join(' or ');

      return languageCode == 'hi'
          ? "मुझे लगता है कि आप $options के बारे में पूछ रहे हैं। आप किसका मतलब था?"
          : "I detected you might be asking about $options. Which one did you mean?";
    }

    try {
      debugPrint('ReasoningEngine: Formatting Llama 3 Prompt...');
      final systemPrompt = _buildSystemInstruction();

      final StringBuffer promptBuffer = StringBuffer();
      promptBuffer.write(
          '<|begin_of_text|><|start_header_id|>system<|end_header_id|>\n\n');
      promptBuffer.write(systemPrompt);
      promptBuffer.write('<|eot_id|>');

      for (final msg in history) {
        final role = msg['role'] == 'user' ? 'user' : 'assistant';
        promptBuffer.write('<|start_header_id|>$role<|end_header_id|>\n\n');
        promptBuffer.write(msg['content']);
        promptBuffer.write('<|eot_id|>');
      }

      promptBuffer.write('<|start_header_id|>user<|end_header_id|>\n\n');
      promptBuffer.write(userInput);
      promptBuffer
          .write('<|eot_id|><|start_header_id|>assistant<|end_header_id|>\n\n');

      final finalPrompt = promptBuffer.toString();

      debugPrint('ReasoningEngine: Sending prompt to Bedrock...');
      return await AWSBedrockService.chatWithLlama3(finalPrompt);
    } catch (e) {
      debugPrint("Bedrock Error: $e");
      return "I'm having trouble connecting to my brain. Please try again soon.";
    }
  }

  // Phase 5: Form Guidance — Intelligent contextual assistance
  Future<String> generateFormGuidance({
    required String userInput,
    required Map<String, dynamic> formContext,
    required Map<String, dynamic> userProfile,
  }) async {
    final systemPrompt = """
    You are 'Civic Voice Form Partner' (CVI), an expert in Indian government paperwork.
    Your task is to guide the user as they fill out a form for: ${formContext['serviceName'] ?? 'a civic service'}.

    USER PROFILE DATA (Use this to provide personalized advice):
    ${json.encode(userProfile)}

    FORM CONTEXT:
    - Service ID: ${formContext['serviceId']}
    - Current Field: ${formContext['currentFieldLabel']}
    - All Fields: ${formContext['allFields']}

    GUIDE RULES:
    1. Be concise but extremely helpful.
    2. If the user asks "How do I fill this?", look at their PROFILE. If they have the data (like Aadhaar Number), tell them exactly what to type.
    3. If they don't have the data, tell them where to find it (e.g., "Look at the back of your Aadhaar card").
    4. Speak in the $languageCode language.
    5. Be encouraging. Filling forms is stressful; be their calm partner.
    6. If the user says something unrelated, gently bring them back to the form.

    Current field being filled: ${formContext['currentFieldLabel']} (${formContext['currentFieldValue'] ?? 'empty'})
    """;

    try {
      final StringBuffer promptBuffer = StringBuffer();
      promptBuffer.write(
          '<|begin_of_text|><|start_header_id|>system<|end_header_id|>\n\n');
      promptBuffer.write(systemPrompt);
      promptBuffer
          .write('<|eot_id|><|start_header_id|>user<|end_header_id|>\n\n');
      promptBuffer.write(userInput);
      promptBuffer
          .write('<|eot_id|><|start_header_id|>assistant<|end_header_id|>\n\n');

      final finalPrompt = promptBuffer.toString();
      debugPrint('ReasoningEngine: Requesting Form Guidance from Llama 3...');
      return await AWSBedrockService.chatWithLlama3(finalPrompt);
    } catch (e) {
      debugPrint("Form Guidance Error: $e");
      return "I'm here to help, but I'm having a small connection issue. Please try describing your question again.";
    }
  }

  /// AI guidance specifically for the Scheme Detail screen (before applying).
  Future<String> generateSchemeGuidance({
    required String userInput,
    required Map<String, dynamic> schemeContext,
    required Map<String, dynamic> userProfile,
    required List<String> availableDocuments,
    List<Map<String, String>> history = const [],
  }) async {
    final systemPrompt = """
    You are 'Civic Voice SPECIALIST' (CVI), an elite advisor for Indian government schemes.
    Your task: Help the user understand their eligibility and requirements for: ${schemeContext['name']}.

    CONTEXT AUDIT (Compare Vault/Profile vs Scheme):
    1. USER PROFILE: ${json.encode(userProfile)}
    2. VAULT DOCUMENTS: ${availableDocuments.join(', ')}
    3. SCHEME REQUIREMENTS:
       - Eligibility: ${schemeContext['eligibilityCriteria']}
       - Required Docs: ${schemeContext['requiredDocuments']}

    GUIDE RULES:
    1. PROACTIVE GAP ANALYSIS: Immediately identify if they are missing a document or don't meet an age/income requirement.
    2. DOCUMENT MAPPING: If a scheme requires "Proof of Identity", check if they have "Aadhaar" or "PAN" in their vault. Tell them they are "Set" or "Need help".
    3. BE BOLD & SPECIFIC: Don't say "You may need papers." Say "You have your Aadhaar, but your Income Certificate is missing. I can help you find where to apply for it."
    4. ACTION ORIENTED: If eligible, push them to 'Apply Now'. If not, suggest a fix or alternative.
    5. LANGUAGE: Respond in $languageCode. Use a premium, expert tone.
    6. Form Guidance: If they ask about filling the form, assure them you'll be there every step of the way with their details pre-remembered.
    """;

    try {
      final StringBuffer promptBuffer = StringBuffer();
      promptBuffer.write(
          '<|begin_of_text|><|start_header_id|>system<|end_header_id|>\n\n');
      promptBuffer.write(systemPrompt);
      promptBuffer.write('<|eot_id|>');

      // Add History
      for (final msg in history) {
        final role = msg['role'] == 'user' ? 'user' : 'assistant';
        promptBuffer.write('<|start_header_id|>$role<|end_header_id|>\n\n');
        promptBuffer.write(msg['content']);
        promptBuffer.write('<|eot_id|>');
      }

      // New Message
      promptBuffer.write('<|start_header_id|>user<|end_header_id|>\n\n');
      promptBuffer.write(userInput);
      promptBuffer
          .write('<|eot_id|><|start_header_id|>assistant<|end_header_id|>\n\n');

      final finalPrompt = promptBuffer.toString();
      debugPrint(
          'ReasoningEngine: Requesting Scheme Guidance from Llama 70B...');
      return await AWSBedrockService.chatWithLlama3(finalPrompt);
    } catch (e) {
      debugPrint("Scheme Guidance Error: $e");
      return "I'm having trouble analyzing this scheme right now. Please try again in a moment.";
    }
  }

  Future<Map<String, dynamic>> verifyDocumentImage(String base64Image) async {
    const verificationPrompt = """
    Verify this Indian document image. 
    Check for:
    1. Validity (Is it a real document?)
    2. Expiry date (if Aadhaar/PAN don't have expiry, skip)
    3. Extracted text overview.
    
    Return ONLY JSON:
    {"isValid": true/false, "message": "...", "documentType": "...", "expiryDate": "YYYY-MM-DD", "extractedText": "..."}
    """;

    try {
      debugPrint(
          'ReasoningEngine: Verifying image with Bedrock (Llama 3.2 Vision)...');
      // Convert base64 back to bytes for AWSBedrockService
      final imageBytes = base64Decode(base64Image);
      return await AWSBedrockService.extractWithVision(
        prompt: verificationPrompt,
        imageBytes: imageBytes,
      );
    } catch (e) {
      debugPrint("Vision Error: $e");
      return {"isValid": false, "message": "Verification failed due to error."};
    }
  }

  Future<String> translateText(String text, String sourceLanguage) async {
    if (['en', 'english'].contains(sourceLanguage.toLowerCase())) return text;

    try {
      final prompt =
          "Translate the following text to English. Output only the translation: $text";
      return await AWSBedrockService.chatWithLlama3(prompt);
    } catch (_) {
      return text;
    }
  }
}
