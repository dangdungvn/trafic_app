class LoginRequest {
  String username;
  String password;
  String? deviceToken;

  LoginRequest({required this.username, required this.password, this.deviceToken});

  // Chuyển đổi dữ liệu thành JSON để gửi đi
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'password': password,
      'deviceToken': deviceToken,
    };

    return data;
  }
}
