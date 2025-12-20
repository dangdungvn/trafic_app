import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'location_model.dart';

class TrafficPostModel {
  final String id;
  final String userId;
  final String type;
  final String content;
  final LocationModel location;
  final String status;
  final DateTime timestamp;
  final String? userName;
  final String? avatarUrl;
  final List<String>? imageUrls;
  final int likes;
  final bool isLiked;
  final List<String> hashtags;

  TrafficPostModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.content,
    required this.location,
    required this.status,
    required this.timestamp,
    this.userName,
    this.avatarUrl,
    this.imageUrls,
    this.likes = 0,
    this.isLiked = false,
    this.hashtags = const [],
  });

  factory TrafficPostModel.fromJson(Map<String, dynamic> json) {
    // Handle nested user object
    final user = json['user'] as Map<String, dynamic>?;

    // Handle avatar URL
    String? avatarUrl =
        user?['avatarUrl'] as String? ?? json['avatarUrl'] as String?;
    if (avatarUrl != null && !avatarUrl.startsWith('http')) {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://35.192.42.207:8080';
      // Encode filename to handle special characters and spaces
      // Assuming avatars are stored in /Upload/AVATAR/ based on TRAFFICPOST pattern
      // If the path is different, this needs to be adjusted
      avatarUrl = '$baseUrl/Upload/AVATAR/${Uri.encodeComponent(avatarUrl)}';
    }

    return TrafficPostModel(
      id: json['id']?.toString() ?? '',
      userId: user?['id']?.toString() ?? json['userId']?.toString() ?? '',
      type: json['type'] as String? ?? '',
      content: json['content'] as String? ?? '',
      location: LocationModel.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      status: json['status'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      userName: user?['fullname'] as String? ?? json['userName'] as String?,
      avatarUrl: avatarUrl,
      imageUrls: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : (json['imageUrls'] != null
                ? List<String>.from(json['imageUrls'] as List)
                : null),
      likes: json['likeTotal'] as int? ?? json['likes'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      hashtags: json['hashtags'] != null
          ? List<String>.from(json['hashtags'] as List)
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'content': content,
      'location': location.toJson(),
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      if (userName != null) 'userName': userName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (imageUrls != null) 'imageUrls': imageUrls,
      'likes': likes,
      'isLiked': isLiked,
      'hashtags': hashtags,
    };
  }

  TrafficPostModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? content,
    LocationModel? location,
    String? status,
    DateTime? timestamp,
    String? userName,
    String? avatarUrl,
    List<String>? imageUrls,
    int? likes,
    bool? isLiked,
    List<String>? hashtags,
  }) {
    return TrafficPostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      content: content ?? this.content,
      location: location ?? this.location,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      hashtags: hashtags ?? this.hashtags,
    );
  }
}
