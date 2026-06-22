class ProfileUser {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role;
  final String language;
  final bool emailVerified;
  final String? profileImage;
  final bool notificationsEnabled;

  ProfileUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.language,
    required this.emailVerified,
    required this.profileImage,
    required this.notificationsEnabled,
  });

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? '',
      language: json['language'] ?? '',
      emailVerified: json['emailVerified'] ?? false,
      profileImage: json['profileImage'],
      notificationsEnabled: json['notificationsEnabled'] ?? false,
    );
  }
}