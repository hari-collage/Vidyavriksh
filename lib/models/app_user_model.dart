import 'dart:typed_data';

class AppUser {
  final String role;
  final String displayName;
  final String email;
  final String password;
  final String phoneNumber;
  final String courseName;
  final String subjectExpertise;
  final String bio;
  final Uint8List? profileImageBytes;

  AppUser({
    required this.role,
    required this.displayName,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.courseName,
    required this.subjectExpertise,
    required this.bio,
    required this.profileImageBytes,
  });

  AppUser copyWith({
    String? displayName,
    String? phoneNumber,
    String? courseName,
    String? subjectExpertise,
    String? bio,
    Uint8List? profileImageBytes,
  }) {
    return AppUser(
      role: role,
      displayName: displayName ?? this.displayName,
      email: email,
      password: password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      courseName: courseName ?? this.courseName,
      subjectExpertise: subjectExpertise ?? this.subjectExpertise,
      bio: bio ?? this.bio,
      profileImageBytes: profileImageBytes ?? this.profileImageBytes,
    );
  }
}
