class SchemeDiscoveryModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> eligibilityCriteria;
  final String applicationProcess;

  SchemeDiscoveryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.eligibilityCriteria,
    required this.applicationProcess,
  });

  factory SchemeDiscoveryModel.fromJson(Map<String, dynamic> json) {
    return SchemeDiscoveryModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
      eligibilityCriteria: List<String>.from(json['eligibility_criteria'] ?? []),
      applicationProcess: json['application_process'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'eligibility_criteria': eligibilityCriteria,
      'application_process': applicationProcess,
    };
  }
}
