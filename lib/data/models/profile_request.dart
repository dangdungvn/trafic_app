class ProfileRequest {
  int? id;
  String? username;
  String? fullName;
  String? email;
  String? province;
  String? phoneNumber; 
  String? avatarUrl;
  String? relativePhone;
  int? roleId;

  ProfileRequest({
    this.id,
    this.username,
    this.fullName,
    this.email,
    this.province,
    this.phoneNumber,
    this.avatarUrl,
    this.relativePhone,
    this.roleId,
  });

  factory ProfileRequest.fromJson(Map<String, dynamic> json) {
    return ProfileRequest(
      id: json['id'],
      username: json['username'],
      fullName: json['fullName'], 
      email: json['email'],
      province: json['province'],
      phoneNumber: json['phoneNumber'], 
      avatarUrl: json['avatarUrl'],
      relativePhone: json['relativePhone'],
      roleId: json['roleId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'fullName': fullName,
      'email': email,
      'province': province,
    };

    // 2. Kiểm tra an toàn: Chỉ đóng gói SĐT nếu nó không rỗng
    if (phoneNumber != null && phoneNumber!.trim().isNotEmpty) {
      data['phoneNumber'] = phoneNumber;
    }

    // 3. Tương tự với SĐT người thân
    if (relativePhone != null && relativePhone!.trim().isNotEmpty) {
      data['relativePhone'] = relativePhone;
    }

    return data;
  }
}