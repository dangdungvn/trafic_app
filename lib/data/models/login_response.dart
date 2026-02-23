class LoginResponse {
  final String token;
  final String username;
  final String fullName;
  final String province;
  final String? relativePhone;

  LoginResponse({
    required this.token,
    required this.username,
    required this.fullName,
    required this.province,
    this.relativePhone,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      username: json['username'] as String,
      fullName: json['fullName'] as String,
      province: json['province'] as String,
      relativePhone: json['relativePhone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'username': username,
      'fullName': fullName,
      'province': province,
      'relativePhone': relativePhone,
    };
  }
}
