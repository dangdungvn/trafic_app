class LoginResponse {
  final String? token;
  final String? username;
  final String? fullName;
  final String? province;
  final String? relativePhone;
  final String? phoneNumber;

  LoginResponse({
    this.token,
    this.username,
    this.fullName,
    this.province,
    this.relativePhone,
    this.phoneNumber,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String?,
      username: json['username'] as String?,
      fullName: json['fullName'] as String?,
      province: json['province'] as String?,
      relativePhone: json['relativePhone'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'username': username,
      'fullName': fullName,
      'province': province,
      'relativePhone': relativePhone,
      'phoneNumber': phoneNumber,
    };
  }
}
