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
      avatarUrl: user?['avatarUrl'] as String? ?? json['avatarUrl'] as String?,
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

  /// Build full image URL from filename
  String? getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;

    // Nếu đã là URL đầy đủ, return luôn
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    // Thêm base URL
    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    return '$baseUrl/uploads/$imageUrl';
  }

  /// Get full image URLs list
  List<String>? get fullImageUrls {
    if (imageUrls == null || imageUrls!.isEmpty) return null;
    return imageUrls!.map((url) => getFullImageUrl(url) ?? url).toList();
  }

  /// Get full avatar URL
  String? get fullAvatarUrl {
    if (avatarUrl == null || avatarUrl?.isEmpty == true) return null;

    // Nếu đã là URL đầy đủ, return luôn
    if (avatarUrl!.startsWith('http://') || avatarUrl!.startsWith('https://')) {
      return avatarUrl;
    }

    // Thêm base URL
    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    return '$baseUrl/uploads/$avatarUrl';
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
