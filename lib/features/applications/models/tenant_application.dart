class ApplicationVisitSlot {
  final String id;
  final DateTime scheduledAt;
  final String status;

  const ApplicationVisitSlot({
    required this.id,
    required this.scheduledAt,
    required this.status,
  });
}

class TenantApplication {
  final String id;
  final String propertyId;
  final String roomId;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? visitScheduledAt;
  final String propertyName;
  final String city;
  final String? address;
  final int roomNumber;
  final double monthlyPrice;
  final DateTime? availableFrom;
  final String? imageUrl;
  final List<ApplicationVisitSlot> visitSlots;

  const TenantApplication({
    required this.id,
    required this.propertyId,
    required this.roomId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.visitScheduledAt,
    required this.propertyName,
    required this.city,
    required this.address,
    required this.roomNumber,
    required this.monthlyPrice,
    required this.availableFrom,
    required this.imageUrl,
    required this.visitSlots,
  });

  bool get needsResponse => status == 'visit_proposed';

  bool get isInProgress => const {
        'pending',
        'under_review',
        'visit_proposed',
        'visit_confirmed',
      }.contains(status);

  bool get isFinalized => status == 'accepted';

  bool get isDiscarded => const {
        'rejected',
        'withdrawn',
        'visit_declined',
      }.contains(status);
}
