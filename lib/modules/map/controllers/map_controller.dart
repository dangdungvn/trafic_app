import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapController extends GetxController {
  late GoogleMapController mapController;
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController searchController = TextEditingController();
  final Dio _dio = Dio();
  final String _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  final LatLng _center = const LatLng(
    21.028511,
    105.804817,
  ); // Hanoi coordinates
  LatLng get center => _center;

  // Observables for Map State
  var currentMapType = MapType.normal.obs;
  var isTrafficEnabled = false.obs;
  var markers = <Marker>{}.obs;
  var polylines = <Polyline>{}.obs;
  var isLoading = false.obs;
  var placeSuggestions = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _addDummyMarkers();
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
  }

  Future<void> fetchSuggestions(String input) async {
    if (input.isEmpty) {
      placeSuggestions.clear();
      return;
    }

    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': input,
          'key': _apiKey,
          'components': 'country:vn', // Limit to Vietnam
        },
      );
      if (response.statusCode == 200) {
        final predictions = response.data['predictions'] as List;
        placeSuggestions.value = predictions.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('Error fetching suggestions: $e');
    }
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

        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: target, zoom: 16.0),
          ),
        );

        markers.add(
          Marker(
            markerId: const MarkerId('search_result'),
            position: target,
            infoWindow: InfoWindow(title: query),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueViolet,
            ),
          ),
        );
      } else {
        Get.snackbar('Thông báo', 'Không tìm thấy địa điểm này');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tìm kiếm địa điểm: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleMapType() {
    final types = [
      MapType.normal,
      MapType.satellite,
      MapType.terrain,
      MapType.hybrid,
    ];
    final currentIndex = types.indexOf(currentMapType.value);
    currentMapType.value = types[(currentIndex + 1) % types.length];
  }

  void toggleTraffic() {
    isTrafficEnabled.value = !isTrafficEnabled.value;
  }

  Future<void> _checkLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  Future<void> goToMyLocation() async {
    try {
      isLoading.value = true;
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Error', 'Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Error', 'Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Error',
          'Location permissions are permanently denied, we cannot request permissions.',
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15.0,
          ),
        ),
      );
    } catch (e) {
      Get.snackbar('Error', 'Could not get location: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _addDummyMarkers() {
    markers.addAll([
      Marker(
        markerId: const MarkerId('traffic_jam_1'),
        position: const LatLng(21.029511, 105.805817),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Tắc đường nghiêm trọng'),
        onTap: () {
          _showMarkerDetails(
            'Tắc đường nghiêm trọng',
            'Khu vực Cầu Giấy đang tắc nghẽn do giờ cao điểm.',
          );
        },
      ),
      Marker(
        markerId: const MarkerId('police_1'),
        position: const LatLng(21.027511, 105.803817),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Chốt CSGT'),
        onTap: () {
          _showMarkerDetails('Chốt CSGT', 'Kiểm tra nồng độ cồn tại ngã tư.');
        },
      ),
      Marker(
        markerId: const MarkerId('accident_1'),
        position: const LatLng(21.028011, 105.806817),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(title: 'Tai nạn nhẹ'),
        onTap: () {
          _showMarkerDetails(
            'Tai nạn nhẹ',
            'Va chạm giữa 2 xe máy, di chuyển chậm.',
          );
        },
      ),
    ]);
  }

  void _addDummyPolyline() {
    polylines.add(
      Polyline(
        polylineId: const PolylineId('route_1'),
        points: const [
          LatLng(21.028511, 105.804817),
          LatLng(21.029511, 105.805817),
          LatLng(21.030511, 105.806817),
          LatLng(21.031511, 105.807817),
        ],
        color: Colors.blue,
        width: 5,
      ),
    );
  }

  void _showMarkerDetails(String title, String description) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4D5DFA),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Đóng'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
