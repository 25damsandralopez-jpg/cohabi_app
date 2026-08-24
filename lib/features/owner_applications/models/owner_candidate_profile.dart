class OwnerCandidateProfile {
  final String applicationId;
  final String tenantId;
  final String tenantName;
  final String email;
  final String phone;
  final String status;

  final String propertyName;
  final String city;
  final int roomNumber;
  final double monthlyPrice;

  final Map<String, dynamic> tenantProfile;
  final Map<String, dynamic> selectionProfile;

  const OwnerCandidateProfile({
    required this.applicationId,
    required this.tenantId,
    required this.tenantName,
    required this.email,
    required this.phone,
    required this.status,
    required this.propertyName,
    required this.city,
    required this.roomNumber,
    required this.monthlyPrice,
    required this.tenantProfile,
    required this.selectionProfile,
  });

  factory OwnerCandidateProfile.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> safeMap(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
      return <String, dynamic>{};
    }

    double asDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    int asInt(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return OwnerCandidateProfile(
      applicationId: map['application_id']?.toString() ?? '',
      tenantId: map['tenant_id']?.toString() ?? '',
      tenantName: map['tenant_name']?.toString() ?? 'Inquilino Cohabi',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      status: map['status']?.toString() ?? 'pending',
      propertyName: map['property_name']?.toString() ?? 'Piso Cohabi',
      city: map['city']?.toString() ?? '',
      roomNumber: asInt(map['room_number']),
      monthlyPrice: asDouble(map['monthly_price']),
      tenantProfile: safeMap(map['tenant_profile']),
      selectionProfile: safeMap(map['selection_profile']),
    );
  }
}
