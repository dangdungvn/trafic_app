class LoginRequest {
  String username;
  String password;

  LoginRequest({
    required this.username,
    required this.password
  });

  // Chuyển đổi dữ liệu thành JSON để gửi đi
  Map<String, dynamic> toJson() {
    return {
      'email': username,
      'password': password,
    };
  }
}