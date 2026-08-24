class TenantMatch {
  final String propertyId;
  final String roomId;
  final String propertyName;
  final String city;
  final String? address;
  final int roomNumber;
  final double monthlyPrice;
  final DateTime? availableFrom;
  final String? imageUrl;
  final int score;
  final List<String> reasons;
  final bool isFavorite;
  final bool hasApplied;

  const TenantMatch({
    required this.propertyId,
    required this.roomId,
    required this.propertyName,
    required this.city,
    required this.address,
    required this.roomNumber,
    required this.monthlyPrice,
    required this.availableFrom,
    required this.imageUrl,
    required this.score,
    required this.reasons,
    required this.isFavorite,
    required this.hasApplied,
  });

  TenantMatch copyWith({
    bool? isFavorite,
    bool? hasApplied,
  }) {
    return TenantMatch(
      propertyId: propertyId,
      roomId: roomId,
      propertyName: propertyName,
      city: city,
      address: address,
      roomNumber: roomNumber,
      monthlyPrice: monthlyPrice,
      availableFrom: availableFrom,
      imageUrl: imageUrl,
      score: score,
      reasons: reasons,
      isFavorite: isFavorite ?? this.isFavorite,
      hasApplied: hasApplied ?? this.hasApplied,
    );
  }
}
