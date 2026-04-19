
enum ApplicationStatus { submitted, verified, approved, rejected }

class UserApplication {
  final String id;
  final String schemeId;
  final String schemeName;
  final ApplicationStatus status;
  final DateTime submissionDate;
  final String? currentStep;
  final String? nextStep;
  final List<ApplicationEvent> timeline;

  UserApplication({
    required this.id,
    required this.schemeId,
    required this.schemeName,
    required this.status,
    required this.submissionDate,
    this.currentStep,
    this.nextStep,
    this.timeline = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'schemeId': schemeId,
    'schemeName': schemeName,
    'status': status.index,
    'submissionDate': submissionDate.toIso8601String(),
    'currentStep': currentStep,
    'nextStep': nextStep,
    'timeline': timeline.map((e) => e.toJson()).toList(),
  };
}

class ApplicationEvent {
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isCompleted;

  ApplicationEvent({
    required this.title,
    required this.description,
    required this.timestamp,
    this.isCompleted = true,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'timestamp': timestamp.toIso8601String(),
    'isCompleted': isCompleted,
  };
}
