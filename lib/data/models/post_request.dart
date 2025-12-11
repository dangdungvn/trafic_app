class PostRequest {
   String? userId; 
   String type;
   String content;
   PostLocation location;
   String status;

  PostRequest({
    this.userId,
    this.type = "TRAFFIC_JAM", 
    required this.content,
    required this.location,
    this.status = "PENDING",   
  });

  // Chuyển đối tượng thành JSON Map để gửi đi
  Map<String, dynamic> toJson() {
    return {
      if (userId != null) "userId": userId,
      "type": type,
      "content": content,
      "location": location.toJson(), 
      "status": status,
      // "timestamp": ... // Thường Backend tự tạo, không cần gửi
    };
  }
}

// Class con cho Location (vì Swagger nó nằm lồng bên trong)
class PostLocation {
  final double lat;
  final double lng;
  final String address;

  PostLocation({
    required this.lat,
    required this.lng,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      "lat": lat,
      "lng": lng,
      "address": address,
    };
  }
}