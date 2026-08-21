class AccountStateData {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String activeMode;
  final bool hasTenantProfile;
  final bool hasOwnerProfile;

  const AccountStateData({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.activeMode,
    required this.hasTenantProfile,
    required this.hasOwnerProfile,
  });

  bool get isTenant => activeMode == 'tenant';
  bool get isOwner => activeMode == 'owner';
  bool get hasBothProfiles => hasTenantProfile && hasOwnerProfile;

  String get fullName {
    final value = '$firstName $lastName'.trim();
    return value.isEmpty ? 'Usuario Cohabi' : value;
  }
}
