class OwnerVisitSlot {
  final String id;
  final DateTime scheduledAt;
  final String status;

  const OwnerVisitSlot({
    required this.id,
    required this.scheduledAt,
    required this.status,
  });
}

class OwnerApplication {
  final String id;
  final String tenantId;
  final String tenantName;
  final String propertyId;
  final String propertyName;
  final String city;
  final String roomId;
  final int roomNumber;
  final double monthlyPrice;
  final String status;
  final DateTime createdAt;
  final DateTime? visitScheduledAt;
  final List<OwnerVisitSlot> visitSlots;

  const OwnerApplication({
    required this.id,
    required this.tenantId,
    required this.tenantName,
    required this.propertyId,
    required this.propertyName,
    required this.city,
    required this.roomId,
    required this.roomNumber,
    required this.monthlyPrice,
    required this.status,
    required this.createdAt,
    required this.visitScheduledAt,
    required this.visitSlots,
  });

  bool get isOpen => const {
        'pending',
        'under_review',
        'visit_proposed',
        'visit_confirmed',
      }.contains(status);

  bool get hasConfirmedVisit => status == 'visit_confirmed';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => const {'rejected', 'withdrawn', 'visit_declined'}.contains(status);
}
