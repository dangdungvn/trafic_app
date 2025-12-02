class ProfileRequest {
  int? id;
  String? username;
  String? fullName;
  String? email;
  String? province;
  String? phoneNumber; 
  String? avatarUrl;
  int? roleId;

  ProfileRequest({
    this.id,
    this.username,
    this.fullName,
    this.email,
    this.province,
    this.phoneNumber,
    this.avatarUrl,
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
      roleId: json['roleId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'province': province,
      'phoneNumber': phoneNumber,
      // 'avatarUrl': avatarUrl,  
    };
  }
}