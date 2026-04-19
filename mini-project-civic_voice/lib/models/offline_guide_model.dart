class OfflineGuideModel {
  final String id;
  final String title;
  final String category;
  final List<String> steps;
  final List<String> requiredDocuments;
  final String tip;

  OfflineGuideModel({
    required this.id,
    required this.title,
    required this.category,
    required this.steps,
    required this.requiredDocuments,
    required this.tip,
  });

  factory OfflineGuideModel.fromJson(Map<String, dynamic> json) {
    return OfflineGuideModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'General',
      steps: List<String>.from(json['steps'] ?? []),
      requiredDocuments: List<String>.from(json['required_documents'] ?? []),
      tip: json['tip'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'steps': steps,
      'required_documents': requiredDocuments,
      'tip': tip,
    };
  }
}
