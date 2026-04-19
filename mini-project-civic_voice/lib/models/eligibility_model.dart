class EligibilityModel {
  final String id;
  final String userId;
  final int age;
  final String incomeLevel;
  final String location;
  final List<String> questionsAnswered;
  final List<String> eligibleSchemes;

  EligibilityModel({
    required this.id,
    required this.userId,
    required this.age,
    required this.incomeLevel,
    required this.location,
    required this.questionsAnswered,
    required this.eligibleSchemes,
  });

  factory EligibilityModel.fromJson(Map<String, dynamic> json) {
    return EligibilityModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      age: json['age'] ?? 0,
      incomeLevel: json['income_level'] ?? '',
      location: json['location'] ?? '',
      questionsAnswered: List<String>.from(json['questions_answered'] ?? []),
      eligibleSchemes: List<String>.from(json['eligible_schemes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'age': age,
      'income_level': incomeLevel,
      'location': location,
      'questions_answered': questionsAnswered,
      'eligible_schemes': eligibleSchemes,
    };
  }
}
