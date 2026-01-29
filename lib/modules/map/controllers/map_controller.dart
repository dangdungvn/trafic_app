// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:traffic_app/widgets/custom_alert.dart';

// class MapController extends GetxController {
//   late GoogleMapController mapController;
//   final Completer<GoogleMapController> _controller = Completer();
//   final TextEditingController searchController = TextEditingController();
//   final Dio _dio = Dio();
//   final String _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

//   final LatLng _center = const LatLng(
//     21.028511,
//     105.804817,
//   ); // Hanoi coordinates
//   LatLng get center => _center;

//   // Observables for Map State
//   var currentMapType = MapType.normal.obs;
//   var isTrafficEnabled = false.obs;
//   var markers = <Marker>{}.obs;
//   var polylines = <Polyline>{}.obs;
//   var isLoading = false.obs;
//   var placeSuggestions = <Map<String, dynamic>>[].obs;

//   @override
//   void onInit() {
//     super.onInit();
//     _addDummyMarkers();
//     _addDummyPolyline();
//     _checkLocationPermission();
//   }

//   @override
//   void onClose() {
//     searchController.dispose();
//     super.onClose();
//   }

//   void onMapCreated(GoogleMapController controller) {
//     if (!_controller.isCompleted) {
//       _controller.complete(controller);
//     }
//     mapController = controller;
//   }

//   Future<void> fetchSuggestions(String input) async {
//     if (input.isEmpty) {
//       placeSuggestions.clear();
//       return;
//     }

//     try {
//       final response = await _dio.get(
//         'https://maps.googleapis.com/maps/api/place/autocomplete/json',
//         queryParameters: {
//           'input': input,
//           'key': _apiKey,
//           'components': 'country:vn', // Limit to Vietnam
//         },
//       );
//       if (response.statusCode == 200) {
//         final predictions = response.data['predictions'] as List;
//         placeSuggestions.value = predictions.cast<Map<String, dynamic>>();
//       }
//     } catch (e) {
//       debugPrint('Error fetching suggestions: $e');
//     }
//   }

//   Future<void> selectSuggestion(Map<String, dynamic> suggestion) async {
//     searchController.text = suggestion['description'];
//     placeSuggestions.clear();
//     await searchLocation(suggestion['description']);
//   }

//   Future<void> searchLocation(String query) async {
//     if (query.isEmpty) return;

//     try {
//       isLoading.value = true;
//       List<Location> locations = await locationFromAddress(query);

//       if (locations.isNotEmpty) {
//         Location location = locations.first;
//         LatLng target = LatLng(location.latitude, location.longitude);

//         mapController.animateCamera(
//           CameraUpdate.newCameraPosition(
//             CameraPosition(target: target, zoom: 16.0),
//           ),
//         );

//         markers.add(
//           Marker(
//             markerId: const MarkerId('search_result'),
//             position: target,
//             infoWindow: InfoWindow(title: query),
//             icon: BitmapDescriptor.defaultMarkerWithHue(
//               BitmapDescriptor.hueViolet,
//             ),
//           ),
//         );
//       } else {
//         CustomAlert.showWarning('Không tìm thấy địa điểm này');
//       }
//     } catch (e) {
//       CustomAlert.showError('Không thể tìm kiếm địa điểm: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void toggleMapType() {
//     final types = [
//       MapType.normal,
//       MapType.satellite,
//       MapType.terrain,
//       MapType.hybrid,
//     ];
//     final currentIndex = types.indexOf(currentMapType.value);
//     currentMapType.value = types[(currentIndex + 1) % types.length];
//   }

//   void toggleTraffic() {
//     isTrafficEnabled.value = !isTrafficEnabled.value;
//   }

//   Future<void> _checkLocationPermission() async {
//     var status = await Permission.location.status;
//     if (!status.isGranted) {
//       await Permission.location.request();
//     }
//   }

//   Future<void> goToMyLocation() async {
//     try {
//       isLoading.value = true;
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         CustomAlert.showError('Dịch vụ vị trí đã bị tắt');
//         return;
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           CustomAlert.showError('Quyền truy cập vị trí bị từ chối');
//           return;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         CustomAlert.showError(
//           'Quyền vị trí bị từ chối vĩnh viễn, vui lòng cấp quyền trong cài đặt',
//         );
//         return;
//       }

//       Position position = await Geolocator.getCurrentPosition();
//       mapController.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             target: LatLng(position.latitude, position.longitude),
//             zoom: 15.0,
//           ),
//         ),
//       );
//     } catch (e) {
//       CustomAlert.showError('Không thể lấy vị trí: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void _addDummyMarkers() {
//     markers.addAll([
//       Marker(
//         markerId: const MarkerId('traffic_jam_1'),
//         position: const LatLng(21.029511, 105.805817),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//         infoWindow: const InfoWindow(title: 'Tắc đường nghiêm trọng'),
//         onTap: () {
//           _showMarkerDetails(
//             'Tắc đường nghiêm trọng',
//             'Khu vực Cầu Giấy đang tắc nghẽn do giờ cao điểm.',
//           );
//         },
//       ),
//       Marker(
//         markerId: const MarkerId('police_1'),
//         position: const LatLng(21.027511, 105.803817),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//         infoWindow: const InfoWindow(title: 'Chốt CSGT'),
//         onTap: () {
//           _showMarkerDetails('Chốt CSGT', 'Kiểm tra nồng độ cồn tại ngã tư.');
//         },
//       ),
//       Marker(
//         markerId: const MarkerId('accident_1'),
//         position: const LatLng(21.028011, 105.806817),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
//         infoWindow: const InfoWindow(title: 'Tai nạn nhẹ'),
//         onTap: () {
//           _showMarkerDetails(
//             'Tai nạn nhẹ',
//             'Va chạm giữa 2 xe máy, di chuyển chậm.',
//           );
//         },
//       ),
//     ]);
//   }

//   void _addDummyPolyline() {
//     polylines.add(
//       Polyline(
//         polylineId: const PolylineId('route_1'),
//         points: const [
//           LatLng(21.028511, 105.804817),
//           LatLng(21.029511, 105.805817),
//           LatLng(21.030511, 105.806817),
//           LatLng(21.031511, 105.807817),
//         ],
//         color: Colors.blue,
//         width: 5,
//       ),
//     );
//   }

//   void _showMarkerDetails(String title, String description) {
//     Get.bottomSheet(
//       Container(
//         padding: const EdgeInsets.all(20),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Text(description, style: const TextStyle(fontSize: 16)),
//             const SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () => Get.back(),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF4D5DFA),
//                   foregroundColor: Colors.white,
//                 ),
//                 child: const Text('Đóng'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:traffic_app/widgets/custom_alert.dart';

import '../../../data/models/traffic_post_model.dart';
import '../../../data/models/location_model.dart';

class MapController extends GetxController {
  late GoogleMapController mapController;
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController searchController = TextEditingController();
  final Dio _dio = Dio();
  final String _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  final LatLng _center = const LatLng(21.028511, 105.804817);
  LatLng get center => _center;
  final LatLng _trieuKhucCenter = const LatLng(20.984572, 105.799079);

  var currentMapType = MapType.normal.obs;
  var isTrafficEnabled = false.obs;
  var markers = <Marker>{}.obs;
  var polylines = <Polyline>{}.obs;
  var isLoading = false.obs;
  var placeSuggestions = <Map<String, dynamic>>[].obs;

  // [MỚI] Biến lưu trữ dữ liệu gốc và Icon để dùng lại (không cần load lại nhiều lần)
  List<TrafficPostModel> _cachedPosts = [];
  BitmapDescriptor? _iconTraffic;
  BitmapDescriptor? _iconAccident;
  BitmapDescriptor? _iconFlood;

  // [MỚI] Mức Zoom hiện tại và Ngưỡng ẩn/hiện
  double _currentZoom = 14.0; 
  final double _zoomThreshold = 13.5; // Zoom nhỏ hơn số này sẽ ẩn icon

  @override
  void onInit() {
    super.onInit();
    _loadHardcodedData(); // Hàm này giờ chỉ chuẩn bị dữ liệu, không add marker ngay
    _addDummyPolyline();
    _checkLocationPermission();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void onMapCreated(GoogleMapController controller) {
    if (!_controller.isCompleted) {
      _controller.complete(controller);
    }
    mapController = controller;

    Future.delayed(const Duration(seconds: 1), () {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _trieuKhucCenter, zoom: 16.5),
        ),
      );
    });
  }

  // [MỚI] Hàm lắng nghe sự kiện Camera di chuyển (Zoom vào/ra)
  // Bạn cần gắn hàm này vào onCameraMove bên file View
  void onCameraMove(CameraPosition position) {
    _currentZoom = position.zoom;
    _updateMarkersVisibility();
  }

  // [MỚI] Logic ẩn hiện Marker dựa trên Zoom
  // Trong map_controller.dart

  void _updateMarkersVisibility() {
    // Logic: Zoom nhỏ (xa) thì ẩn, Zoom lớn (gần) thì hiện
    if (_currentZoom < _zoomThreshold) {
      if (markers.isNotEmpty) {
        print("🔭 Đang ẩn icon do zoom xa ($_currentZoom)"); // Debug log
        markers.clear();
        markers.refresh(); // <--- THÊM DÒNG NÀY (Bắt buộc để UI cập nhật)
      }
    } 
    else {
      if (markers.isEmpty && _cachedPosts.isNotEmpty) {
        print("🔭 Đang hiện lại icon do zoom gần ($_currentZoom)"); // Debug log
        _generateMarkersFromCache();
        // Trong hàm _generateMarkersFromCache bạn dùng .assignAll thì nó tự refresh rồi, không cần gọi nữa
      }
    }
  }

  Future<void> _loadHardcodedData() async {
    // 1. Tạo Icon (Chỉ tạo 1 lần và lưu vào biến)
    // [MỚI] Đã giảm kích thước icon cho vừa mắt hơn
    _iconTraffic = await _createCustomMarkerBitmap(Icons.traffic_rounded, Colors.orange[800]!);
    _iconAccident = await _createCustomMarkerBitmap(Icons.car_crash_rounded, Colors.red[700]!);
    _iconFlood = await _createCustomMarkerBitmap(Icons.flood_rounded, Colors.blue[600]!);

    // 2. Lưu dữ liệu bài viết vào cache
    _cachedPosts = [
      TrafficPostModel(
        id: 'post_001',
        userId: 'user_01',
        type: 'TRAFFIC_JAM',
        content: 'Tắc đường nghiêm trọng...',
        location: LocationModel(lat: 20.985095 , lng: 105.799091, address: '54 Triều Khúc'),
        status: 'ACTIVE',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        userName: 'Phạm Văn Đức',
        avatarUrl: 'https://img.freepik.com/free-vector/smiling-young-man-illustration_1308-174669.jpg?semt=ais_hybrid&w=740&q=80',
        imageUrls: ['https://scontent.fhan2-5.fna.fbcdn.net/v/t1.15752-9/622866640_1245881140747023_1133298020947068720_n.png?_nc_cat=104&ccb=1-7&_nc_sid=0024fc&_nc_eui2=AeEDZnWpu5pdlszyAj8y9gXySH6wS1KbgFBIfrBLUpuAUNnDAqOaMXwOoKERj32DBOq367Iz4uIA23K35nNAnyxk&_nc_ohc=wgGStWxL62UQ7kNvwHa9RwX&_nc_oc=Adn6MpQHApckpKiyql35zDJqNth6xIAntktnu_YB6-4HGBCo3ahwJAQ1VeEaEzQjumI&_nc_ad=z-m&_nc_cid=0&_nc_zt=23&_nc_ht=scontent.fhan2-5.fna&oh=03_Q7cD4QFnks1Kgnj69WvUCq0VYq4f14ukwH_jsKNLU2gAaOYzAw&oe=69A2F464'],
        likes: 12,
        isLiked: true,
      ),
      TrafficPostModel(
        id: 'post_002',
        userId: 'user_02',
        type: 'ACCIDENT',
        content: 'Va chạm nhẹ giữa 2 xe...',
        location: LocationModel(lat: 20.984962, lng: 105.799214, address: 'Ngõ 66 Triều Khúc'),
        status: 'ACTIVE',
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        userName: 'Nguyễn Chí Quang',
        avatarUrl: 'https://img.freepik.com/free-vector/smiling-redhaired-boy-illustration_1308-176664.jpg?semt=ais_hybrid&w=740&q=80',
        imageUrls: ['https://scontent.fhan20-1.fna.fbcdn.net/v/t1.15752-9/623777786_2354439921686401_2412263926529047005_n.png?stp=dst-png_s552x414&_nc_cat=109&ccb=1-7&_nc_sid=0024fc&_nc_eui2=AeGyFTynQqkt-tLaqgiqaA7hFnOvGGtdfckWc68Ya119yfiRU0Io7cO45omi3f8CwVuvA_f9_d1tmiNf9BtpomuD&_nc_ohc=L8WQOiEgdxoQ7kNvwGrUgb6&_nc_oc=AdlK8nT_dW5qGzxGY5wdnfdhYdPtAD5sWMIADmTDjmkr9SySuUuZ7Tiz-AZJCUI5DVk&_nc_ad=z-m&_nc_cid=0&_nc_zt=23&_nc_ht=scontent.fhan20-1.fna&oh=03_Q7cD4QF9bUWeS7Z_2BSW1LVDWt6vJ3TDFL5vPLCYMXXKbEL_yg&oe=69A2F92B'],
        likes: 5,
        isLiked: false,
      ),
      TrafficPostModel(
        id: 'post_003',
        userId: 'user_03',
        type: 'FLOOD',
        content: 'Mưa to nước ngập...',
        location: LocationModel(lat: 20.984848, lng: 105.799320, address: 'Pandora Triều Khúc'),
        status: 'ACTIVE',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        userName: 'Lê Chí Tấn',
        avatarUrl: 'https://img.freepik.com/free-vector/smiling-young-man-illustration_1308-173524.jpg',
        imageUrls: ['https://scontent.fhan2-5.fna.fbcdn.net/v/t1.15752-9/618405205_4252968041624239_6125741913925192546_n.png?stp=dst-png_s640x640&_nc_cat=107&ccb=1-7&_nc_sid=0024fc&_nc_eui2=AeG0L_3sGDgQI_pM4yqnJ0WhNLpOUrwb0Yw0uk5SvBvRjHwqTgoW3Vf3GdDxNQyLEOVmSXFAz2WYQP2ll9qR7a8F&_nc_ohc=72aE1llLKtgQ7kNvwE9uLqF&_nc_oc=AdkTdLZltgvix6XYNXnK4jh1htAm0m0OXBmYlXGtRUAp4DoJv9X0OkaFaZngOlaG5tc&_nc_ad=z-m&_nc_cid=0&_nc_zt=23&_nc_ht=scontent.fhan2-5.fna&oh=03_Q7cD4QFHM4LtHsO9-hKCxlf1JCHlOSBsxtV45hSmOtXi7H0w7A&oe=69A2D096'],
        likes: 45,
        isLiked: false,
      ),
    ];

    // 3. Gọi hàm hiển thị lần đầu
    _generateMarkersFromCache();
  }

  // [MỚI] Hàm tạo marker từ dữ liệu đã cache
  void _generateMarkersFromCache() {
    // Nếu chưa có icon thì thôi (tránh lỗi null)
    if (_iconTraffic == null || _iconAccident == null || _iconFlood == null) return;

    final newMarkers = <Marker>{};

    for (var post in _cachedPosts) {
      BitmapDescriptor iconToUse;
      if (post.type == 'ACCIDENT') {
        iconToUse = _iconAccident!;
      } else if (post.type == 'FLOOD') {
        iconToUse = _iconFlood!;
      } else {
        iconToUse = _iconTraffic!;
      }

      newMarkers.add(
        Marker(
          markerId: MarkerId(post.id),
          position: LatLng(post.location.lat, post.location.lng),
          icon: iconToUse,
          onTap: () {
            _showPostDetail(post);
          },
        ),
      );
    }
    
    // Cập nhật lên bản đồ
    markers.assignAll(newMarkers);
  }

  // [MỚI] Đã điều chỉnh kích thước nhỏ lại
  Future<BitmapDescriptor> _createCustomMarkerBitmap(IconData iconData, Color color) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    
    final String fontFamily = iconData.fontFamily ?? 'MaterialIcons';
    final iconStr = String.fromCharCode(iconData.codePoint);
    
    textPainter.text = TextSpan(
      text: iconStr,
      style: TextStyle(
        letterSpacing: 0.0,
        fontSize: 60.0, // [GIẢM] Giảm từ 120 xuống 60 cho vừa mắt
        fontFamily: fontFamily,
        package: iconData.fontPackage,
        color: color,
        shadows: const [
           Shadow(blurRadius: 3.0, color: Colors.black45, offset: Offset(2.0, 2.0)),
        ]
      ),
    );
    
    textPainter.layout();
    
    // Căn giữa
    final double size = 80.0; // [GIẢM] Khung ảnh giảm xuống 80x80
    final double offsetX = (size - textPainter.width) / 2;
    final double offsetY = (size - textPainter.height) / 2;
    
    textPainter.paint(canvas, Offset(offsetX, offsetY));
    
    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData == null) return BitmapDescriptor.defaultMarker;
    return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
  }

  // --- CÁC HÀM CŨ GIỮ NGUYÊN ---
  void _showPostDetail(TrafficPostModel post) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(post.avatarUrl ?? 'https://i.pravatar.cc/150'),
                    radius: 24,
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.userName ?? 'Người dùng', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(_formatTimeAgo(post.timestamp), style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[100]!),
                    ),
                    child: Text(post.type, style: TextStyle(color: Colors.red[800], fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(post.content, style: const TextStyle(fontSize: 15, height: 1.4)),
              const SizedBox(height: 12),
              if (post.imageUrls != null && post.imageUrls!.isNotEmpty)
                Container(
                  height: 200,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(image: NetworkImage(post.imageUrls!.first), fit: BoxFit.cover),
                  ),
                ),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.blue, size: 18),
                  const SizedBox(width: 4),
                  Expanded(child: Text(post.location.address, style: const TextStyle(color: Colors.blue, fontStyle: FontStyle.italic), overflow: TextOverflow.ellipsis)),
                ],
              ),
              const Divider(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(icon: Icons.thumb_up_outlined, label: '${post.likes} Hữu ích', color: Colors.grey[700]!),
                  _buildActionButton(icon: Icons.comment_outlined, label: 'Bình luận', color: Colors.grey[700]!),
                  _buildActionButton(icon: Icons.share_outlined, label: 'Chia sẻ', color: Colors.grey[700]!),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color}) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [Icon(icon, color: color, size: 20), const SizedBox(width: 6), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500))],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inDays > 0) return '${difference.inDays} ngày trước';
    if (difference.inHours > 0) return '${difference.inHours} giờ trước';
    if (difference.inMinutes > 0) return '${difference.inMinutes} phút trước';
    return 'Vừa xong';
  }

  void toggleMapType() {
    final types = [MapType.normal, MapType.satellite, MapType.terrain, MapType.hybrid];
    final currentIndex = types.indexOf(currentMapType.value);
    currentMapType.value = types[(currentIndex + 1) % types.length];
  }

  void toggleTraffic() => isTrafficEnabled.value = !isTrafficEnabled.value;

  Future<void> fetchSuggestions(String input) async {
    if (input.isEmpty) { placeSuggestions.clear(); return; }
    try {
      final response = await _dio.get('https://maps.googleapis.com/maps/api/place/autocomplete/json', queryParameters: {'input': input, 'key': _apiKey, 'components': 'country:vn'});
      if (response.statusCode == 200) {
        final predictions = response.data['predictions'] as List;
        placeSuggestions.value = predictions.cast<Map<String, dynamic>>();
      }
    } catch (e) { debugPrint('Error fetching suggestions: $e'); }
  }

  Future<void> selectSuggestion(Map<String, dynamic> suggestion) async {
    searchController.text = suggestion['description'];
    placeSuggestions.clear();
    await searchLocation(suggestion['description']);
  }

  Future<void> searchLocation(String query) async {
    if (query.isEmpty) return;
    try {
      isLoading.value = true;
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng target = LatLng(location.latitude, location.longitude);
        mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 16.0)));
        
        // Thêm marker search riêng biệt (vẫn dùng marker đỏ)
        markers.add(Marker(markerId: const MarkerId('search_result'), position: target, infoWindow: InfoWindow(title: query), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet)));
      } else {
        CustomAlert.showWarning('Không tìm thấy địa điểm này');
      }
    } catch (e) {
      CustomAlert.showError('Không thể tìm kiếm địa điểm: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _checkLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) await Permission.location.request();
  }

  Future<void> goToMyLocation() async {
    try {
      isLoading.value = true;
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) { CustomAlert.showError('Dịch vụ vị trí đã bị tắt'); return; }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) { CustomAlert.showError('Quyền truy cập vị trí bị từ chối'); return; }
      }
      if (permission == LocationPermission.deniedForever) { CustomAlert.showError('Quyền vị trí bị từ chối vĩnh viễn, vui lòng cấp quyền trong cài đặt'); return; }
      Position position = await Geolocator.getCurrentPosition();
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 15.0)));
    } catch (e) {
      CustomAlert.showError('Không thể lấy vị trí: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _addDummyPolyline() {
    polylines.add(Polyline(polylineId: const PolylineId('route_1'), points: const [LatLng(21.028511, 105.804817), LatLng(21.029511, 105.805817), LatLng(21.030511, 105.806817), LatLng(21.031511, 105.807817)], color: Colors.blue, width: 5));
  }

  // Hàm làm mới lại toàn bộ bản đồ
  Future<void> reloadMap() async {
    isLoading.value = true;
    print("🔄 Đang tải lại bản đồ...");

    try {
      // 1. Xóa sạch marker cũ
      markers.clear();
      
      // 2. Load lại dữ liệu (giả lập trễ 1 chút cho giống thật)
      await Future.delayed(const Duration(milliseconds: 500));
      await _loadHardcodedData();
      
      // 3. Đưa camera về vị trí mặc định (Triều Khúc)
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _trieuKhucCenter, zoom: 16.5),
        ),
      );
      
      CustomAlert.showSuccess("Đã cập nhật dữ liệu giao thông");
    } catch (e) {
      print("Lỗi reload: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

