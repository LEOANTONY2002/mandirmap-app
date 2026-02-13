class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? avatarUrl;
  final String language;
  final String? address1;
  final String? address2;
  final String? address3;
  final String? district;
  final String? state;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.avatarUrl,
    required this.language,
    this.address1,
    this.address2,
    this.address3,
    this.district,
    this.state,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'] ?? json['fullName'],
      email: json['email'],
      phoneNumber: json['phone_number'] ?? json['phoneNumber'],
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
      language: json['language'] ?? 'ENGLISH',
      address1: json['address_1'] ?? json['address1'],
      address2: json['address_2'] ?? json['address2'],
      address3: json['address_3'] ?? json['address3'],
      district: json['district'],
      state: json['state'],
    );
  }
}
