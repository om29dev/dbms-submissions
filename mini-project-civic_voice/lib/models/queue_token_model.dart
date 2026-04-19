enum TokenStatus { active, called, completed, expired }

class QueueToken {
  final String id;
  final String serviceName; // e.g., "Aadhaar Update", "Ration Card"
  final String officeName; // e.g., "MeeSeva Center, Hyderabad"
  final int tokenNumber; // e.g., 45
  final int currentServing; // e.g., 42
  final DateTime estimatedTime;
  final TokenStatus status;

  QueueToken({
    required this.id,
    required this.serviceName,
    required this.officeName,
    required this.tokenNumber,
    required this.currentServing,
    required this.estimatedTime,
    this.status = TokenStatus.active,
  });

  // Calculate wait time in minutes
  int get waitTimeMinutes => estimatedTime.difference(DateTime.now()).inMinutes;
}
