class OwnerApplication {
  final String id;
  final String tenantId;
  final String propertyId;
  final String roomId;
  final String status;
  final DateTime createdAt;
  final DateTime? visitScheduledAt;
  final String tenantName;
  final String propertyName;
  final int roomNumber;

  const OwnerApplication({
    required this.id,
    required this.tenantId,
    required this.propertyId,
    required this.roomId,
    required this.status,
    required this.createdAt,
    required this.visitScheduledAt,
    required this.tenantName,
    required this.propertyName,
    required this.roomNumber,
  });

  bool get isOpen => const {
        'pending',
        'under_review',
        'visit_proposed',
        'visit_confirmed',
      }.contains(status);
}
