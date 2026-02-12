class UserModel {
  final String id;
  final String firebaseUid;
  final String fullName;
  final String? email;
  final String phoneNumber;
  final String? avatarUrl;
  final String language;

  UserModel({
    required this.id,
    required this.firebaseUid,
    required this.fullName,
    this.email,
    required this.phoneNumber,
    this.avatarUrl,
    required this.language,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firebaseUid: json['firebaseUid'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      avatarUrl: json['avatarUrl'],
      language: json['language'],
    );
  }
}
