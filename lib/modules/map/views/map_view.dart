// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import '../controllers/map_controller.dart';

// class MapView extends GetView<MapController> {
//   const MapView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // Google Map
//         Obx(
//           () => GoogleMap(
//             onMapCreated: controller.onMapCreated,
//             initialCameraPosition: CameraPosition(
//               target: controller.center,
//               zoom: 14.0,
//             ),
//             mapType: controller.currentMapType.value,
//             trafficEnabled: controller.isTrafficEnabled.value,
//             markers: Set<Marker>.of(controller.markers),
//             polylines: Set<Polyline>.of(controller.polylines),
//             myLocationEnabled: true,
//             myLocationButtonEnabled: false, // We use custom button
//             zoomControlsEnabled: true, // We use custom buttons or gestures
//           ),
//         ),

//         // Search Bar with Suggestions
//         Positioned(
//           top: 50,
//           left: 20,
//           right: 20,
//           child: Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 15),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(30),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 10,
//                       offset: const Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: TextField(
//                   controller: controller.searchController,
//                   decoration: const InputDecoration(
//                     hintText: 'Tìm kiếm địa điểm...',
//                     border: InputBorder.none,
//                     icon: Icon(Icons.search, color: Colors.grey),
//                   ),
//                   onChanged: (value) {
//                     controller.fetchSuggestions(value);
//                   },
//                   onSubmitted: (value) {
//                     controller.searchLocation(value);
//                   },
//                 ),
//               ),
//               Obx(
//                 () => controller.placeSuggestions.isNotEmpty
//                     ? Container(
//                         margin: const EdgeInsets.only(top: 10),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(10),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 10,
//                               offset: const Offset(0, 5),
//                             ),
//                           ],
//                         ),
//                         child: ListView.builder(
//                           shrinkWrap: true,
//                           padding: EdgeInsets.zero,
//                           itemCount: controller.placeSuggestions.length,
//                           itemBuilder: (context, index) {
//                             final suggestion =
//                                 controller.placeSuggestions[index];
//                             return ListTile(
//                               title: Text(suggestion['description']),
//                               leading: const Icon(
//                                 Icons.location_on,
//                                 color: Colors.grey,
//                               ),
//                               onTap: () {
//                                 controller.selectSuggestion(suggestion);
//                                 FocusScope.of(context).unfocus();
//                               },
//                             );
//                           },
//                         ),
//                       )
//                     : const SizedBox.shrink(),
//               ),
//             ],
//           ),
//         ),

//         // Control Buttons
//         Positioned(
//           right: 10,
//           bottom: 90,
//           child: Column(
//             children: [
//               // Map Type Toggle
//               FloatingActionButton(
//                 heroTag: 'map_type',
//                 onPressed: controller.toggleMapType,
//                 backgroundColor: Colors.white,
//                 child: const Icon(Icons.layers, color: Colors.black87),
//               ),
//               const SizedBox(height: 10),

//               // Traffic Toggle
//               Obx(
//                 () => FloatingActionButton(
//                   heroTag: 'traffic',
//                   onPressed: controller.toggleTraffic,
//                   backgroundColor: controller.isTrafficEnabled.value
//                       ? Colors.blue
//                       : Colors.white,
//                   child: Icon(
//                     Icons.traffic,
//                     color: controller.isTrafficEnabled.value
//                         ? Colors.white
//                         : Colors.black87,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),

//               // My Location
//               FloatingActionButton(
//                 heroTag: 'my_location',
//                 onPressed: controller.goToMyLocation,
//                 backgroundColor: Colors.white,
//                 child: Obx(
//                   () => controller.isLoading.value
//                       ? const CircularProgressIndicator(strokeWidth: 2)
//                       : const Icon(Icons.my_location, color: Colors.black87),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/map_controller.dart';

class MapView extends GetView<MapController> {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dùng Scaffold để có cấu trúc chuẩn, tránh lỗi layout
      resizeToAvoidBottomInset: false, // Giữ các nút không bị đẩy lên khi bàn phím hiện
      body: Stack(
        children: [
          // 1. Google Map
          Obx(
            () => GoogleMap(
              onMapCreated: controller.onMapCreated,

              onCameraMove: controller.onCameraMove,

              initialCameraPosition: CameraPosition(
                target: controller.center,
                zoom: 14.0,
              ),
              mapType: controller.currentMapType.value,
              trafficEnabled: controller.isTrafficEnabled.value,
              // Tối ưu: Không cần Set<Marker>.of(), GetX tự xử lý
              markers: controller.markers, 
              polylines: controller.polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false, 
              
              // THÊM: Bấm vào map thì ẩn bàn phím và ẩn danh sách gợi ý
              onTap: (_) {
                FocusScope.of(context).unfocus();
                controller.placeSuggestions.clear();
              },
            ),
          ),

          // 2. Search Bar & Suggestions
          Positioned(
            top: MediaQuery.of(context).padding.top + 10, // Cách tai thỏ (SafeArea)
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Ô tìm kiếm
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller.searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm địa điểm...',
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      // THÊM: Nút X để xóa nhanh nội dung tìm kiếm
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          controller.searchController.clear();
                          controller.placeSuggestions.clear();
                          FocusScope.of(context).unfocus();
                        },
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    onChanged: (value) => controller.fetchSuggestions(value),
                    onSubmitted: (value) => controller.searchLocation(value),
                  ),
                ),

                // Danh sách gợi ý (Chỉ hiện khi có data)
                Obx(
                  () => controller.placeSuggestions.isNotEmpty
                      ? Container(
                          margin: const EdgeInsets.only(top: 10),
                          // THÊM: Giới hạn chiều cao danh sách gợi ý (để không che hết map)
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: controller.placeSuggestions.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final suggestion = controller.placeSuggestions[index];
                              return ListTile(
                                dense: true,
                                title: Text(
                                  suggestion['description'],
                                  style: const TextStyle(fontSize: 14),
                                ),
                                leading: const Icon(Icons.location_on, color: Colors.blue, size: 20),
                                onTap: () {
                                  controller.selectSuggestion(suggestion);
                                  FocusScope.of(context).unfocus();
                                },
                              );
                            },
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // 3. Control Buttons (Bên phải dưới)
          Positioned(
            right: 15,
            bottom: 100, 
            child: Column(
              children: [
                _buildMapBtn( 
                  icon: Icons.refresh,   
                  onTap: controller.reloadMap,
                  ),
                const SizedBox(height: 10),
                
                _buildMapBtn(
                  icon: Icons.layers,
                  onTap: controller.toggleMapType,
                ),
                const SizedBox(height: 10),
                Obx(() => _buildMapBtn(
                      icon: Icons.traffic,
                      isActive: controller.isTrafficEnabled.value,
                      onTap: controller.toggleTraffic,
                      activeColor: Colors.blue,
                    )),
                const SizedBox(height: 10),
                Obx(() => _buildMapBtn(
                      icon: Icons.my_location,
                      isLoading: controller.isLoading.value,
                      onTap: controller.goToMyLocation,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget tách riêng cho nút bấm để code gọn hơn
  Widget _buildMapBtn({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
    bool isLoading = false,
    Color activeColor = Colors.blue,
  }) {
    return FloatingActionButton(
      heroTag: null, // Tránh lỗi hero tag trùng nhau
      mini: true, // Nút nhỏ gọn hơn
      onPressed: onTap,
      backgroundColor: isActive ? activeColor : Colors.white,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
            )
          : Icon(
              icon,
              color: isActive ? Colors.white : Colors.black87,
              size: 20,
            ),
    );
  }
}