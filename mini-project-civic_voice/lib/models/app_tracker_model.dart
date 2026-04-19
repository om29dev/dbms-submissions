class AppTrackerModel {
  final String id;
  final String schemeName;
  final String status; // Pending, In Progress, Completed, Rejected
  final String department;
  final DateTime submittedDate;
  final DateTime? estimatedCompletion;

  AppTrackerModel({
    required this.id,
    required this.schemeName,
    required this.status,
    required this.department,
    required this.submittedDate,
    this.estimatedCompletion,
  });

  factory AppTrackerModel.fromJson(Map<String, dynamic> json) {
    return AppTrackerModel(
      id: json['id'] ?? '',
      schemeName: json['scheme_name'] ?? '',
      status: json['status'] ?? 'Pending',
      department: json['department'] ?? '',
      submittedDate: json['submitted_date'] != null 
          ? DateTime.parse(json['submitted_date']) 
          : DateTime.now(),
      estimatedCompletion: json['estimated_completion'] != null 
          ? DateTime.parse(json['estimated_completion']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheme_name': schemeName,
      'status': status,
      'department': department,
      'submitted_date': submittedDate.toIso8601String(),
      'estimated_completion': estimatedCompletion?.toIso8601String(),
    };
  }
}
