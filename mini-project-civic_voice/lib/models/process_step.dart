class ProcessStep {
  final int stepNumber;
  final String description;

  ProcessStep(this.description, this.stepNumber);

  factory ProcessStep.fromJson(Map<String, dynamic> json) {
    return ProcessStep(
      json['description'] ?? '',
      json['step'] ?? 0,
    );
  }
}
