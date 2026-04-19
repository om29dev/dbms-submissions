import 'package:flutter/foundation.dart';

enum ApplicationStatus { submitted, processing, approved, rejected }

@immutable
class ApplicationTracker {
  final String id;
  final String serviceId;
  final String serviceName;
  final String applicationNumber;
  final ApplicationStatus status;
  final DateTime submittedDate;
  final DateTime? lastUpdated;
  final List<ApplicationStep> timeline;
  final String? trackingUrl;

  const ApplicationTracker({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.applicationNumber,
    required this.status,
    required this.submittedDate,
    this.lastUpdated,
    required this.timeline,
    this.trackingUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceId': serviceId,
        'serviceName': serviceName,
        'applicationNumber': applicationNumber,
        'status': status.name,
        'submittedDate': submittedDate.toIso8601String(),
        'lastUpdated': lastUpdated?.toIso8601String(),
        'timeline': timeline.map((s) => s.toJson()).toList(),
        'trackingUrl': trackingUrl,
      };

  factory ApplicationTracker.fromJson(Map<String, dynamic> json) {
    return ApplicationTracker(
      id: json['id'] as String,
      serviceId: json['serviceId'] as String,
      serviceName: json['serviceName'] as String,
      applicationNumber: json['applicationNumber'] as String,
      status: ApplicationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ApplicationStatus.submitted,
      ),
      submittedDate: DateTime.parse(json['submittedDate'] as String),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
      timeline: (json['timeline'] as List)
          .map((s) => ApplicationStep.fromJson(s as Map<String, dynamic>))
          .toList(),
      trackingUrl: json['trackingUrl'] as String?,
    );
  }
}

@immutable
class ApplicationStep {
  final String title;
  final String description;
  final DateTime? completedAt;
  final bool isCompleted;
  final bool isCurrent;

  const ApplicationStep({
    required this.title,
    required this.description,
    this.completedAt,
    this.isCompleted = false,
    this.isCurrent = false,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'completedAt': completedAt?.toIso8601String(),
        'isCompleted': isCompleted,
        'isCurrent': isCurrent,
      };

  factory ApplicationStep.fromJson(Map<String, dynamic> json) {
    return ApplicationStep(
      title: json['title'] as String,
      description: json['description'] as String,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool,
      isCurrent: json['isCurrent'] as bool,
    );
  }
}
