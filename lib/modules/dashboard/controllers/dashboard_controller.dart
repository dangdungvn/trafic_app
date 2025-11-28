import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/report_bottom_sheet.dart';

class Post {
  final String id;
  final String name;
  final String avatarUrl;
  final String content;
  final String tags;
  final String mapImageUrl;
  RxInt likes;
  RxBool isLiked;
  RxBool isReported;

  Post({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.content,
    required this.tags,
    required this.mapImageUrl,
    required int likes,
    required bool isLiked,
    bool isReported = false,
  }) : likes = likes.obs,
       isLiked = isLiked.obs,
       isReported = isReported.obs;
}

class DashboardController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  final posts = <Post>[
    Post(
      id: '1',
      name: "Phan Văn Tùng",
      avatarUrl: "https://i.pravatar.cc/150?img=3",
      content:
          "Kẹt xe nghiêm trọng trên đường Cộng Hòa hướng về trung tâm thành phố. Mọi người nên tìm lộ trình thay thế!",
      tags: "#ketxe #giaothong",
      mapImageUrl:
          "https://media.istockphoto.com/id/148421596/vi/anh/k%E1%BA%B9t-xe-h%C3%A0ng-gh%E1%BA%BF.jpg?s=2048x2048&w=is&k=20&c=hE43uh9pW9-nujy4jEpO4zfHKOA9aQsP3Buit7V-J2U=",
      likes: 23,
      isLiked: true,
    ),
    Post(
      id: '2',
      name: "Nguyễn Thị Hương",
      avatarUrl: "https://i.pravatar.cc/150?img=5",
      content: "Đường Nguyễn Văn Linh đang thi công, di chuyển chậm.",
      tags: "#thicong #canhbao",
      mapImageUrl:
          "https://media.istockphoto.com/id/148421596/vi/anh/k%E1%BA%B9t-xe-h%C3%A0ng-gh%E1%BA%BF.jpg?s=2048x2048&w=is&k=20&c=hE43uh9pW9-nujy4jEpO4zfHKOA9aQsP3Buit7V-J2U=",
      likes: 15,
      isLiked: false,
    ),
    Post(
      id: '3',
      name: "Nguyễn Thị Hương",
      avatarUrl: "https://i.pravatar.cc/150?img=5",
      content: "Đường Nguyễn Văn Linh đang thi công, di chuyển chậm.",
      tags: "#thicong #canhbao",
      mapImageUrl:
          "https://media.istockphoto.com/id/148421596/vi/anh/k%E1%BA%B9t-xe-h%C3%A0ng-gh%E1%BA%BF.jpg?s=2048x2048&w=is&k=20&c=hE43uh9pW9-nujy4jEpO4zfHKOA9aQsP3Buit7V-J2U=",
      likes: 15,
      isLiked: false,
    ),
    Post(
      id: '4',
      name: "Nguyễn Thị Hương",
      avatarUrl: "https://i.pravatar.cc/150?img=5",
      content: "Đường Nguyễn Văn Linh đang thi công, di chuyển chậm.",
      tags: "#thicong #canhbao",
      mapImageUrl:
          "https://media.istockphoto.com/id/148421596/vi/anh/k%E1%BA%B9t-xe-h%C3%A0ng-gh%E1%BA%BF.jpg?s=2048x2048&w=is&k=20&c=hE43uh9pW9-nujy4jEpO4zfHKOA9aQsP3Buit7V-J2U=",
      likes: 15,
      isLiked: false,
    ),
    Post(
      id: '5',
      name: "Nguyễn Thị Hương",
      avatarUrl: "https://i.pravatar.cc/150?img=5",
      content: "Đường Nguyễn Văn Linh đang thi công, di chuyển chậm.",
      tags: "#thicong #canhbao",
      mapImageUrl:
          "https://media.istockphoto.com/id/148421596/vi/anh/k%E1%BA%B9t-xe-h%C3%A0ng-gh%E1%BA%BF.jpg?s=2048x2048&w=is&k=20&c=hE43uh9pW9-nujy4jEpO4zfHKOA9aQsP3Buit7V-J2U=",
      likes: 15,
      isLiked: false,
    ),
  ].obs;

  void toggleLike(Post post) {
    if (post.isLiked.value) {
      post.likes.value--;
      post.isLiked.value = false;
    } else {
      post.likes.value++;
      post.isLiked.value = true;
    }
  }

  void reportPost(Post post) {
    if (post.isReported.value) return;

    Get.bottomSheet(
      ReportBottomSheet(
        onReport: (reason) async {
          // Simulate network request
          await Future.delayed(const Duration(seconds: 1));

          post.isReported.value = true;
          Get.back(); // Close bottom sheet

          if (Get.context != null) {
            ScaffoldMessenger.of(Get.context!).showSnackBar(
              SnackBar(
                content: Text(
                  "Đã báo cáo bài viết: $reason",
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
