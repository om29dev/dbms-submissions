class ComplaintModel {
  final String id;
  final String userId;
  final String category; // e.g., Road, Water, Electricity
  final String description;
  final String location;
  final double? latitude;
  final double? longitude;
  final String? authorityEmail;
  final String? base64Image;
  final String status;
  final DateTime submittedAt;

  ComplaintModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.description,
    required this.location,
    this.latitude,
    this.longitude,
    this.authorityEmail,
    this.base64Image,
    this.status = 'Pending',
    required this.submittedAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      category: json['category'] ?? 'Other',
      description: json['description'] ?? '',
      location: json['location'] ?? 'Unknown',
      latitude: json['latitude'],
      longitude: json['longitude'],
      authorityEmail: json['authority_email'],
      base64Image: json['base64_image'],
      status: json['status'] ?? 'Pending',
      submittedAt: json['submitted_at'] != null 
          ? DateTime.parse(json['submitted_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category': category,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'authority_email': authorityEmail,
      'base64_image': base64Image,
      'status': status,
      'submitted_at': submittedAt.toIso8601String(),
    };
  }
}
