import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:traffic_app/widgets/custom_alert.dart';
import '../../../data/models/traffic_post_model.dart';
import '../../../data/models/location_model.dart'; // Đảm bảo đã import LocationModel
import '../../../data/repositories/traffic_post_repository.dart';
import '../../../services/storage_service.dart';
import '../widgets/report_bottom_sheet.dart';

class DashboardController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  // final TrafficPostRepository _postRepository = TrafficPostRepository(); // Tạm thời không dùng
  final StorageService _storageService = Get.find<StorageService>();

  // State management
  final posts = <TrafficPostModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = ''.obs;

  // Pagination
  int currentPage = 0;
  final int pageSize = 10;
  String currentLocation = '';

  @override
  void onInit() {
    super.onInit();
    _initializeLocation();
  }

  void _initializeLocation() async {
    final prefs = _storageService;
    currentLocation = prefs.getString('userProvince') ?? 'Hà Nội';
    await loadPosts(refresh: true);
  }

  /// Load danh sách bài viết (DỮ LIỆU GIẢ)
  Future<void> loadPosts({bool refresh = false}) async {
    if (refresh) {
      currentPage = 0;
      hasMore.value = true;
      errorMessage.value = '';
      isLoading.value = true; // Bật loading
      posts.clear();
    } else {
      if (!hasMore.value) return;
      isLoadingMore.value = true;
    }

    try {
      // 1. Giả lập độ trễ mạng 1 giây để thấy vòng quay loading
      await Future.delayed(const Duration(seconds: 1));

      // 2. TẠO DỮ LIỆU CỨNG (HARDCODE)
      final List<TrafficPostModel> dummyData = [
        TrafficPostModel(
          id: 'post_1',
          userId: 'user_01',
          type: 'TRAFFIC_JAM', // Tắc đường
          content: 'Tắc đường kinh khủng ở ngã tư Nguyễn Trãi, mọi người nên tránh đường này nhé.',
          location: LocationModel(
            lat: 20.993433, 
            lng: 105.805825, 
            address: 'Ngã tư Nguyễn Trãi - Khuất Duy Tiến'
          ),
          status: 'ACTIVE',
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)), // 15 phút trước
          userName: 'Nguyễn Mạnh Công',
          avatarUrl: 'https://img.freepik.com/free-vector/smiling-young-man-illustration_1308-174669.jpg?semt=ais_hybrid&w=740&q=80',
          imageUrls: ['https://scontent.fhan2-5.fna.fbcdn.net/v/t1.15752-9/622866640_1245881140747023_1133298020947068720_n.png?_nc_cat=104&ccb=1-7&_nc_sid=0024fc&_nc_eui2=AeEDZnWpu5pdlszyAj8y9gXySH6wS1KbgFBIfrBLUpuAUNnDAqOaMXwOoKERj32DBOq367Iz4uIA23K35nNAnyxk&_nc_ohc=wgGStWxL62UQ7kNvwHa9RwX&_nc_oc=Adn6MpQHApckpKiyql35zDJqNth6xIAntktnu_YB6-4HGBCo3ahwJAQ1VeEaEzQjumI&_nc_ad=z-m&_nc_cid=0&_nc_zt=23&_nc_ht=scontent.fhan2-5.fna&oh=03_Q7cD4QFnks1Kgnj69WvUCq0VYq4f14ukwH_jsKNLU2gAaOYzAw&oe=69A2F464'], 
          likes: 25,
          isLiked: true,
        ),
        TrafficPostModel(
          id: 'post_2',
          userId: 'user_02',
          type: 'ACCIDENT', // Tai nạn
          content: 'Có va chạm giữa 2 xe máy, công an đang giải quyết. Đi chậm thôi các bác.',
          location: LocationModel(
            lat: 21.028511, 
            lng: 105.804817, 
            address: 'Cầu Giấy, Hà Nội'
          ),
          status: 'ACTIVE',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)), // 2 giờ trước
          userName: 'Lê Chí Đức',
          avatarUrl: 'https://img.freepik.com/free-vector/smiling-redhaired-boy-illustration_1308-176664.jpg?semt=ais_hybrid&w=740&q=80',
          imageUrls: ['https://scontent.fhan20-1.fna.fbcdn.net/v/t1.15752-9/623777786_2354439921686401_2412263926529047005_n.png?stp=dst-png_s552x414&_nc_cat=109&ccb=1-7&_nc_sid=0024fc&_nc_eui2=AeGyFTynQqkt-tLaqgiqaA7hFnOvGGtdfckWc68Ya119yfiRU0Io7cO45omi3f8CwVuvA_f9_d1tmiNf9BtpomuD&_nc_ohc=L8WQOiEgdxoQ7kNvwGrUgb6&_nc_oc=AdlK8nT_dW5qGzxGY5wdnfdhYdPtAD5sWMIADmTDjmkr9SySuUuZ7Tiz-AZJCUI5DVk&_nc_ad=z-m&_nc_cid=0&_nc_zt=23&_nc_ht=scontent.fhan20-1.fna&oh=03_Q7cD4QF9bUWeS7Z_2BSW1LVDWt6vJ3TDFL5vPLCYMXXKbEL_yg&oe=69A2F92B'], 
          likes: 10,
          isLiked: false,
        ),
      ];

      // 3. Gán dữ liệu vào biến posts
      if (refresh) {
        posts.value = dummyData;
        
        // Vì là hardcode chỉ có 2 bài nên ta set hasMore = false luôn để không load thêm nữa
        hasMore.value = false; 
      } else {
        // Logic load more (nếu bạn muốn giả lập thêm thì append vào đây)
        posts.addAll(dummyData);
        hasMore.value = false; 
      }

    } catch (e) {
      errorMessage.value = e.toString();
      if (refresh) {
        CustomAlert.showError("Lỗi tải dữ liệu giả: $e");
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMore() async {
    // Với dữ liệu hardcode, ta tạm tắt load more hoặc chỉ load nếu còn cờ hasMore
    if (!isLoadingMore.value && hasMore.value) {
      await loadPosts(refresh: false);
    }
  }

  @override
  Future<void> refresh() async {
    await loadPosts(refresh: true);
  }

  void changeLocation(String location) {
    if (location != currentLocation) {
      currentLocation = location;
      _storageService.setString('userProvince', location);
      loadPosts(refresh: true);
    }
  }

  void toggleLike(TrafficPostModel post) {
    final index = posts.indexWhere((p) => p.id == post.id);
    if (index != -1) {
      // Logic giả lập like
      final currentPost = posts[index];
      // Nếu Model của bạn có hàm copyWith thì dùng, không thì tạo mới
      // Ở đây giả sử Model có copyWith (như file traffic_post_model.dart bạn gửi trước đó)
      // Nếu lỗi chỗ này, hãy kiểm tra lại file Model xem có hàm copyWith chưa.
      
      // Cách sửa thủ công nếu không có copyWith:
      /*
      final updatedPost = TrafficPostModel(
         id: currentPost.id,
         userId: currentPost.userId,
         // ... copy hết các trường cũ ...
         likes: currentPost.isLiked ? currentPost.likes - 1 : currentPost.likes + 1,
         isLiked: !currentPost.isLiked,
      );
      */
      
      // Giả sử có copyWith:
      /* final updatedPost = posts[index].copyWith(
        likes: post.isLiked ? post.likes - 1 : post.likes + 1,
        isLiked: !post.isLiked,
      );
      posts[index] = updatedPost;
      */
      
      // Vì tôi không thấy hàm copyWith trong code bạn gửi gần nhất, 
      // nên tôi chỉ in ra console để tránh lỗi biên dịch:
      print("Đã like bài: ${post.id} (Logic UI cần cập nhật tùy theo Model)");
    }
  }

  void reportPost(TrafficPostModel post) {
    Get.bottomSheet(
      ReportBottomSheet(
        onReport: (reason) async {
          await Future.delayed(const Duration(seconds: 1));
          Get.back();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            CustomAlert.showSuccess("Đã báo cáo bài viết: $reason");
          });
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