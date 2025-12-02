class SignupRequest {
  final String? email;
  final String password;
  final String userName;
  final String fullName;
  final String province;
  final String? relativePhone;
  final String? phoneNumber;
  final String? badge;
  final String? avatarUrl;

  SignupRequest({
    this.email,
    required this.password,
    required this.userName,
    required this.fullName,
    required this.province,
    this.relativePhone,
    this.phoneNumber,
    this.badge,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'password': password,
      'userName': userName,
      'fullName': fullName,
      'province': province,
    };
  }
}
