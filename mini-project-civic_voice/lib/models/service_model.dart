import 'package:flutter/material.dart';

/// A single document required to apply for a government service.
class DocumentItem {
  final String name;
  final String description;
  final bool isOptional;

  const DocumentItem({
    required this.name,
    required this.description,
    this.isOptional = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'isOptional': isOptional,
      };

  factory DocumentItem.fromJson(Map<String, dynamic> json) => DocumentItem(
        name: json['name'] as String,
        description: json['description'] as String,
        isOptional: json['isOptional'] as bool? ?? false,
      );
}

/// A single procedural step in a government service application.
class StepItem {
  final int number;
  final String title;
  final String description;
  final String? actionUrl;

  const StepItem({
    required this.number,
    required this.title,
    required this.description,
    this.actionUrl,
  });

  Map<String, dynamic> toJson() => {
        'number': number,
        'title': title,
        'description': description,
        'actionUrl': actionUrl,
      };

  factory StepItem.fromJson(Map<String, dynamic> json) => StepItem(
        number: json['number'] as int,
        title: json['title'] as String,
        description: json['description'] as String,
        actionUrl: json['actionUrl'] as String?,
      );
}

/// Categories of government services available in CVI.
enum ServiceCategory {
  identity,
  finance,
  welfare,
  transport,
  property,
  health,
  education,
  business,
  agriculture,
  employment,
}

extension ServiceCategoryEx on ServiceCategory {
  String get label => switch (this) {
        ServiceCategory.identity    => 'Identity',
        ServiceCategory.finance     => 'Finance',
        ServiceCategory.welfare     => 'Welfare',
        ServiceCategory.transport   => 'Transport',
        ServiceCategory.property    => 'Property',
        ServiceCategory.health      => 'Health',
        ServiceCategory.education   => 'Education',
        ServiceCategory.business    => 'Business',
        ServiceCategory.agriculture => 'Agriculture',
        ServiceCategory.employment  => 'Employment',
      };

  String get value => name;

  static ServiceCategory fromString(String value) =>
      ServiceCategory.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ServiceCategory.identity,
      );
}

/// A government service entity with full multilingual metadata.
class ServiceModel {
  final String id;

  /// Multilingual name map. Keys: en, hi, mr, ta.
  final Map<String, String> name;

  /// Multilingual description map. Keys: en, hi, mr, ta.
  final Map<String, String> description;

  final List<String> eligibilityCriteria;
  final List<DocumentItem> requiredDocuments;
  final List<StepItem> steps;
  final String estimatedTimeline;
  final String fees;
  final String officialLink;
  final String helplineNumber;
  final ServiceCategory category;
  final String iconEmoji;
  final bool isAvailable;
  final bool isPopular;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.eligibilityCriteria,
    required this.requiredDocuments,
    required this.steps,
    required this.estimatedTimeline,
    required this.fees,
    required this.officialLink,
    required this.helplineNumber,
    required this.category,
    required this.iconEmoji,
    this.isAvailable = true,
    this.isPopular = false,
  });

  /// Returns the localized name for [langCode], falling back to English.
  String localizedName(String langCode) =>
      name[langCode] ?? name['en'] ?? '';

  /// Returns the localized description for [langCode], falling back to English.
  String localizedDescription(String langCode) =>
      description[langCode] ?? description['en'] ?? '';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'eligibilityCriteria': eligibilityCriteria,
        'requiredDocuments': requiredDocuments.map((d) => d.toJson()).toList(),
        'steps': steps.map((s) => s.toJson()).toList(),
        'estimatedTimeline': estimatedTimeline,
        'fees': fees,
        'officialLink': officialLink,
        'helplineNumber': helplineNumber,
        'category': category.value,
        'iconEmoji': iconEmoji,
        'isAvailable': isAvailable,
      };

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
        id: json['id'] as String,
        name: Map<String, String>.from(json['name'] as Map),
        description: Map<String, String>.from(json['description'] as Map),
        eligibilityCriteria:
            List<String>.from(json['eligibilityCriteria'] as List),
        requiredDocuments: (json['requiredDocuments'] as List)
            .map((d) => DocumentItem.fromJson(d as Map<String, dynamic>))
            .toList(),
        steps: (json['steps'] as List)
            .map((s) => StepItem.fromJson(s as Map<String, dynamic>))
            .toList(),
        estimatedTimeline: json['estimatedTimeline'] as String,
        fees: json['fees'] as String,
        officialLink: json['officialLink'] as String,
        helplineNumber: json['helplineNumber'] as String,
        category: ServiceCategoryEx.fromString(json['category'] as String),
        iconEmoji: json['iconEmoji'] as String,
        isAvailable: json['isAvailable'] as bool? ?? true,
      );

  ServiceModel copyWith({
    String? id,
    Map<String, String>? name,
    Map<String, String>? description,
    List<String>? eligibilityCriteria,
    List<DocumentItem>? requiredDocuments,
    List<StepItem>? steps,
    String? estimatedTimeline,
    String? fees,
    String? officialLink,
    String? helplineNumber,
    ServiceCategory? category,
    String? iconEmoji,
    bool? isAvailable,
  }) =>
      ServiceModel(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        eligibilityCriteria: eligibilityCriteria ?? this.eligibilityCriteria,
        requiredDocuments: requiredDocuments ?? this.requiredDocuments,
        steps: steps ?? this.steps,
        estimatedTimeline: estimatedTimeline ?? this.estimatedTimeline,
        fees: fees ?? this.fees,
        officialLink: officialLink ?? this.officialLink,
        helplineNumber: helplineNumber ?? this.helplineNumber,
        category: category ?? this.category,
        iconEmoji: iconEmoji ?? this.iconEmoji,
        isAvailable: isAvailable ?? this.isAvailable,
      );
}

// ─── Legacy model types used by older/secondary screens ─────────────────────

/// Process step with title + optional instruction.
/// Used by [HorizontalProcessTimeline] and [service_detail_screen.dart].
class ProcessStep {
  final int order;
  final String title;
  final String? instruction;

  const ProcessStep({
    required this.order,
    required this.title,
    this.instruction,
  });
}

/// Legacy government service object used by [service_card.dart] and
/// [service_navigation_screen.dart].  Wraps primitive fields directly.
class GovernmentService {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> documents;
  final List<ProcessStep> steps;

  const GovernmentService({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.documents = const [],
    this.steps = const [],
  });

  /// Stub — returns empty list; real eligibility is handled by ServicesProvider.
  List<({String question})> get eligibilityRules => const [];
}

/// Dummy list used by [ServiceNavigationScreen] so it compiles.
const List<GovernmentService> appServices = [];
