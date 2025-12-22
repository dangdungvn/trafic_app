import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../data/models/traffic_post_model.dart';
import 'like_icon.dart';

class PostItem extends StatelessWidget {
  final TrafficPostModel post;
  final VoidCallback onLike;
  final VoidCallback onReport;

  const PostItem({
    super.key,
    required this.post,
    required this.onLike,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF04060F).withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 60,
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image/Map Area
          Container(
            height: 180.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12.r),
              image: post.imageUrls != null && post.imageUrls!.isNotEmpty
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(post.imageUrls!.first),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: post.imageUrls == null || post.imageUrls!.isEmpty
                ? Center(
                    child: Icon(
                      Icons.location_on,
                      size: 48.w,
                      color: Colors.grey[400],
                    ),
                  )
                : null,
          ),
          SizedBox(height: 12.h),
          // User Info
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                  image: post.avatarUrl != null
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(post.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: post.avatarUrl == null
                    ? Icon(Icons.person, size: 24.w, color: Colors.grey[600])
                    : null,
              ),
              SizedBox(width: 12.w),
              Text(
                post.userName ?? 'Người dùng',
                style: TextStyle(
                  fontSize: 15.2.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1C1C1E),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Content
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF616161),
                height: 1.4,
              ),
              children: [
                TextSpan(text: "${post.content} "),
                if (post.hashtags.isNotEmpty)
                  TextSpan(
                    text: post.hashtags.join(" "),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4D5DFA),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onLike,
                child: Row(
                  children: [
                    LikeIcon(isLiked: post.isLiked),
                    SizedBox(width: 8.w),
                    Text(
                      post.likes.toString(),
                      style: TextStyle(
                        fontSize: 14.4.sp,
                        fontWeight: FontWeight.w600,
                        color: post.isLiked
                            ? const Color(0xFF4D5DFA)
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onReport,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: const Color(0xFFF75555)),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    "Báo cáo".tr,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF75555),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
