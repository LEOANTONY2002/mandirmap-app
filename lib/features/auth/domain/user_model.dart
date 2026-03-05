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
      id: json['id']?.toString() ?? '',
      fullName: (json['full_name'] ?? json['fullName'])?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber:
          (json['phone_number'] ?? json['phoneNumber'])?.toString() ?? '',
      avatarUrl: (json['avatar_url'] ?? json['avatarUrl'])?.toString(),
      language: json['language']?.toString() ?? 'ENGLISH',
      address1: (json['address_1'] ?? json['address1'])?.toString(),
      address2: (json['address_2'] ?? json['address2'])?.toString(),
      address3: (json['address_3'] ?? json['address3'])?.toString(),
      district: json['district']?.toString(),
      state: json['state']?.toString(),
    );
  }
}
