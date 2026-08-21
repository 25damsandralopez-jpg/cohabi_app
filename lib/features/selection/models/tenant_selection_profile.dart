class TenantSelectionProfile {
  final int currentStep;
  final bool completed;
  final Map<String, dynamic> data;

  const TenantSelectionProfile({
    required this.currentStep,
    required this.completed,
    required this.data,
  });

  factory TenantSelectionProfile.fromMap(Map<String, dynamic> map) {
    return TenantSelectionProfile(
      currentStep: (map['current_step'] as num?)?.toInt() ?? 1,
      completed: map['completed'] == true,
      data: Map<String, dynamic>.from(map),
    );
  }
}
