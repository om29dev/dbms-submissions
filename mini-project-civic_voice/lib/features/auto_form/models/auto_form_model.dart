// ═══════════════════════════════════════════════════════════════════════════════
// AUTO FORM MODEL — Smart AI Form Auto-Filling System
// ═══════════════════════════════════════════════════════════════════════════════

/// A single field in a smart government form.
class SmartFormField {
  final String id;
  final Map<String, String> label; // lang code → label
  final String dataKey; // maps to user_extracted_data column
  final String fieldType; // text, date, dropdown
  final bool required;
  final List<String>? options; // for dropdowns
  final String? validationPattern;
  final String sourceDocument; // aadhaar, pan, profile, manual, etc.
  final Map<String, String> voiceExplanation; // lang code → explanation
  final bool sensitive; // mask in logs

  const SmartFormField({
    required this.id,
    required this.label,
    required this.dataKey,
    this.fieldType = 'text',
    this.required = false,
    this.options,
    this.validationPattern,
    this.sourceDocument = 'manual',
    this.voiceExplanation = const {},
    this.sensitive = false,
  });

  /// Get label for language, fallback to English.
  String getLabel(String langCode) => label[langCode] ?? label['en'] ?? id;

  /// Get voice explanation for language, fallback to English.
  String getExplanation(String langCode) =>
      voiceExplanation[langCode] ?? voiceExplanation['en'] ?? '';

  factory SmartFormField.fromJson(Map<String, dynamic> json) {
    return SmartFormField(
      id: json['id'] as String,
      label: Map<String, String>.from(json['label'] as Map),
      dataKey: json['dataKey'] as String,
      fieldType: json['fieldType'] as String? ?? 'text',
      required: json['required'] as bool? ?? false,
      options: json['options'] != null
          ? List<String>.from(json['options'] as List)
          : null,
      validationPattern: json['validationPattern'] as String?,
      sourceDocument: json['sourceDocument'] as String? ?? 'manual',
      voiceExplanation: json['voiceExplanation'] != null
          ? Map<String, String>.from(json['voiceExplanation'] as Map)
          : const {},
      sensitive: json['sensitive'] as bool? ?? false,
    );
  }
}

/// A submission step for guided portal submission.
class SubmitStep {
  final int step;
  final Map<String, String> instruction;

  const SubmitStep({required this.step, required this.instruction});

  String getInstruction(String langCode) =>
      instruction[langCode] ?? instruction['en'] ?? '';

  factory SubmitStep.fromJson(Map<String, dynamic> json) {
    return SubmitStep(
      step: json['step'] as int,
      instruction: Map<String, String>.from(json['instruction'] as Map),
    );
  }
}

/// A complete smart form template for a government service.
class SmartFormTemplate {
  final String serviceId;
  final Map<String, String> formTitle;
  final String portalName;
  final String officialUrl;
  final Map<String, String> introExplanation;
  final List<String> requiredDocuments;
  final List<String> optionalDocuments;
  final List<SubmitStep> submitSteps;
  final List<SmartFormField> fields;

  const SmartFormTemplate({
    required this.serviceId,
    required this.formTitle,
    required this.portalName,
    required this.officialUrl,
    required this.introExplanation,
    this.requiredDocuments = const [],
    this.optionalDocuments = const [],
    this.submitSteps = const [],
    required this.fields,
  });

  String getTitle(String langCode) =>
      formTitle[langCode] ?? formTitle['en'] ?? '';

  String getIntro(String langCode) =>
      introExplanation[langCode] ?? introExplanation['en'] ?? '';

  factory SmartFormTemplate.fromJson(Map<String, dynamic> json) {
    return SmartFormTemplate(
      serviceId: json['serviceId'] as String,
      formTitle: Map<String, String>.from(json['formTitle'] as Map),
      portalName: json['portalName'] as String,
      officialUrl: json['officialUrl'] as String,
      introExplanation:
          Map<String, String>.from(json['introExplanation'] as Map),
      requiredDocuments:
          List<String>.from(json['requiredDocuments'] as List? ?? []),
      optionalDocuments:
          List<String>.from(json['optionalDocuments'] as List? ?? []),
      submitSteps: (json['submitSteps'] as List? ?? [])
          .map((s) => SubmitStep.fromJson(s as Map<String, dynamic>))
          .toList(),
      fields: (json['fields'] as List)
          .map((f) => SmartFormField.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Result of auto-fill mapping — tracks which fields were filled and their sources.
class AutoFillResult {
  final Map<String, String?> filledValues;
  final Map<String, String> dataSources; // fieldId → source doc name
  final List<String> emptyFieldIds;
  final int filledCount;
  final int totalCount;

  const AutoFillResult({
    required this.filledValues,
    required this.dataSources,
    required this.emptyFieldIds,
    required this.filledCount,
    required this.totalCount,
  });

  double get fillPercentage =>
      totalCount > 0 ? filledCount / totalCount : 0.0;
}
