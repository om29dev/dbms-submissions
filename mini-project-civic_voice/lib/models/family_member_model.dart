class FamilyMember {
  final String id;
  final String name;
  final String relation; // "Father", "Mother", "Son", "Daughter", "Spouse"
  final int age;
  final String occupation;
  final double? annualIncome;
  final bool isDependent;

  FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.age,
    required this.occupation,
    this.annualIncome,
    this.isDependent = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'relation': relation,
      'age': age,
      'occupation': occupation,
      'annualIncome': annualIncome,
      'isDependent': isDependent,
    };
  }

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'],
      name: json['name'],
      relation: json['relation'],
      age: json['age'],
      occupation: json['occupation'],
      annualIncome: json['annualIncome']?.toDouble(),
      isDependent: json['isDependent'] ?? false,
    );
  }
}
