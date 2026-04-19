import '../providers/user_provider.dart';
import 'service_model.dart';

class EligibilityRule {
  final Map<String, String> question;
  final String parameter; // 'age', 'income', 'residence', 'land', 'marks'
  final String operator; // '>=', '<=', '==', 'bool'
  final dynamic value;
  final Map<String, String> explanation;

  EligibilityRule({
    required this.question,
    required this.parameter,
    required this.operator,
    required this.value,
    required this.explanation,
  });

  bool check(dynamic userValue) {
    if (userValue == null) return false;
    // Special case for 'bool' operator where userValue might be coming from 'ownsLand' etc.
    if (operator == 'bool') return userValue == value;
    
    try {
      switch (operator) {
        case '>=': return (userValue as num) >= (value as num);
        case '<=': return (userValue as num) <= (value as num);
        case '==': return userValue == value;
        default: return false;
      }
    } catch (e) {
      return false;
    }
  }
}

class SchemeDocument {
  final Map<String, String> name;
  final Map<String, String> reason;
  final Map<String, String>? howToGet; // "How to get this document"
  final List<String>? verificationChecklist; // Checklist for verifying the document

  SchemeDocument({
    required this.name,
    required this.reason,
    this.howToGet,
    this.verificationChecklist,
  });
}

class SchemeStep {
  final int number;
  final Map<String, String> title;
  final Map<String, String> instruction;
  final Map<String, String>? estimatedTime;
  final Map<String, String>? location;
  final Map<String, String>? officeHours;
  final List<String>? prerequisites; // e.g., ["Aadhaar", "Step 1"]
  final String? formUrl;

  SchemeStep({
    required this.number,
    required this.title,
    required this.instruction,
    this.estimatedTime,
    this.location,
    this.officeHours,
    this.prerequisites,
    this.formUrl,
  });
}

class GovernmentScheme {
  final String id;
  final String category; // 'senior_citizens', 'students', 'farmers', 'health', 'food_security'
  final Map<String, String> names;
  final String description;
  final String benefits; // Detailed benefits
  final String? helplineNumber;
  final String? officialWebsite;
  final String? applicationMode; // 'Online', 'Offline', 'Both'
  final List<EligibilityRule> eligibilityRules;
  final List<SchemeDocument> requiredDocuments;
  final List<SchemeStep> steps;

  final List<String>? alternativeSchemeIds; // Schemes to suggest if not eligible

  GovernmentScheme({
    required this.id,
    required this.category,
    required this.names,
    required this.description,
    required this.benefits,
    this.helplineNumber,
    this.officialWebsite,
    this.applicationMode,
    required this.eligibilityRules,
    required this.requiredDocuments,
    required this.steps,
    this.alternativeSchemeIds,
  });

  bool isEligible(UserProfile user) {
    if (eligibilityRules.isEmpty) return true;
    
    for (var rule in eligibilityRules) {
      dynamic userValue;
      switch (rule.parameter) {
        case 'age':
          userValue = user.age;
          break;
        case 'income':
          userValue = user.annualIncome;
          break;
        case 'land':
          userValue = user.ownsLand;
          break;
        case 'occupation':
          userValue = user.occupation;
          break;
        default:
          userValue = null;
      }
      if (!rule.check(userValue)) return false;
    }
    return true;
  }

  ServiceModel toServiceModel() {
    return ServiceModel(
      id: id,
      name: names,
      description: {
        'en': description,
        'hi': description,
      },
      eligibilityCriteria: eligibilityRules.map((r) => r.explanation['en'] ?? '').where((s) => s.isNotEmpty).toList(),
      requiredDocuments: requiredDocuments.map((d) => DocumentItem(
        name: d.name['en'] ?? 'Document',
        description: d.reason['en'] ?? '',
      )).toList(),
      steps: steps.map((s) => StepItem(
        number: s.number,
        title: s.title['en'] ?? 'Step',
        description: s.instruction['en'] ?? '',
      )).toList(),
      estimatedTimeline: 'Varies',
      fees: 'Free / Minimum',
      officialLink: officialWebsite ?? '',
      helplineNumber: helplineNumber ?? '1800-XXX-XXXX',
      category: _mapCategory(category),
      iconEmoji: _mapEmoji(category),
      isAvailable: true,
      isPopular: false,
    );
  }

  ServiceCategory _mapCategory(String cat) {
    switch (cat.toLowerCase()) {
      case 'health': return ServiceCategory.health;
      case 'students': return ServiceCategory.education;
      case 'farmers': return ServiceCategory.agriculture;
      case 'senior_citizens': return ServiceCategory.welfare;
      case 'finance': return ServiceCategory.finance;
      default: return ServiceCategory.welfare;
    }
  }

  String _mapEmoji(String cat) {
    switch (cat.toLowerCase()) {
      case 'health': return '🏥';
      case 'students': return '🎓';
      case 'farmers': return '🚜';
      case 'senior_citizens': return '👴';
      case 'finance': return '💰';
      default: return '🏛️';
    }
  }
}
