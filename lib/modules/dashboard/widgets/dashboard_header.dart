import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:traffic_app/widgets/loading_widget.dart';

import '../../../routes/app_pages.dart';
import '../../profile/controllers/profile_controller.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy ProfileController đã được đăng ký từ HomeBinding
    final profileController = Get.find<ProfileController>();

    return Row(
      children: [
        // Logo placeholder
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(100.r),
          ),
          child: Icon(Icons.traffic, size: 20.sp, color: Colors.black54),
        ),
        const Spacer(),
        SvgPicture.asset(
          'assets/icons/notification.svg',
          width: 32.w,
          height: 32.w,
        ),
        SizedBox(width: 20.w),
        // Map marker
        SvgPicture.asset(
          'assets/icons/warning_appbar.svg',
          width: 40.w,
          height: 40.w,
        ),
        SizedBox(width: 20.w),
        // Avatar - hiển thị từ ProfileController
        GestureDetector(
          onTap: () {
            Get.toNamed(Routes.PROFILE);
          },
          child: Hero(
            tag: 'user_avatar',
            child: Obx(() {
              final avatarUrl = profileController.currentAvatarUrl.value;
              final isLoading = profileController.isLoading.value;

              return Container(
                width: 36.w,
                height: 36.w,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                clipBehavior: Clip.antiAlias,
                child: isLoading
                    ? Center(child: LoadingWidget(width: 20.w))
                    : (avatarUrl.isEmpty
                          ? Icon(Icons.person, size: 20.sp, color: Colors.white)
                          : CachedNetworkImage(
                              imageUrl: avatarUrl,
                              fit: BoxFit.cover,
                              width: 36.w,
                              height: 36.w,
                              placeholder: (context, url) =>
                                  Center(child: LoadingWidget(width: 20.w)),
                              errorWidget: (context, url, error) => Icon(
                                Icons.person,
                                size: 20.sp,
                                color: Colors.white,
                              ),
                            )),
              );
            }),
          ),
        ),
      ],
    );
  }
}
