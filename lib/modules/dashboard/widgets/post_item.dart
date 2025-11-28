import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import 'like_icon.dart';

class PostItem extends StatelessWidget {
  final Post post;
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
              image: DecorationImage(
                image: NetworkImage(post.mapImageUrl),
                fit: BoxFit.cover,
              ),
            ),
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
                  image: DecorationImage(
                    image: NetworkImage(post.avatarUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                post.name,
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
                TextSpan(
                  text: post.tags,
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
                    Obx(() => LikeIcon(isLiked: post.isLiked.value)),
                    SizedBox(width: 8.w),
                    Obx(
                      () => Text(
                        post.likes.value.toString(),
                        style: TextStyle(
                          fontSize: 14.4.sp,
                          fontWeight: FontWeight.w600,
                          color: post.isLiked.value
                              ? const Color(0xFF4D5DFA)
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: post.isReported.value ? null : onReport,
                child: Obx(
                  () => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: post.isReported.value
                          ? Colors.green.withOpacity(0.1)
                          : Colors.transparent,
                      border: Border.all(
                        color: post.isReported.value
                            ? Colors.green
                            : const Color(0xFFF75555),
                      ),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      post.isReported.value ? "Đã báo cáo" : "Báo cáo",
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: post.isReported.value
                            ? Colors.green
                            : const Color(0xFFF75555),
                      ),
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
