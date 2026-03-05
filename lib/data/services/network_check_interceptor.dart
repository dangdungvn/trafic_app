import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

/// Interceptor tự động chờ khi mất mạng và retry request khi có lại mạng.
/// Đăng ký đầu tiên trong Dio interceptors để mọi request đều đi qua đây.
///
/// Dùng kết hợp onConnectivityChanged + polling fallback vì
/// onConnectivityChanged không đáng tin cậy trên iOS/Android.
class NetworkCheckInterceptor extends Interceptor {
  static const _pollInterval = Duration(seconds: 3);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isNone =
        connectivityResult.isEmpty ||
        connectivityResult.contains(ConnectivityResult.none);

    if (!isNone) {
      handler.next(options);
      return;
    }

    // Mất mạng — chờ có mạng rồi mới tiếp tục request
    var resumed = false;

    StreamSubscription<List<ConnectivityResult>>? sub;
    Timer? pollingTimer;

    void resume() {
      if (resumed) return;
      resumed = true;
      sub?.cancel();
      pollingTimer?.cancel();
      handler.next(options);
    }

    // Cách 1: lắng nghe sự kiện (nhanh hơn nếu OS fire đúng)
    sub = Connectivity().onConnectivityChanged.listen((results) {
      final hasNet =
          results.isNotEmpty && !results.contains(ConnectivityResult.none);
      if (hasNet) resume();
    });

    // Cách 2: polling fallback mỗi 3s — đề phòng onConnectivityChanged không fire
    pollingTimer = Timer.periodic(_pollInterval, (_) async {
      final results = await Connectivity().checkConnectivity();
      final hasNet =
          results.isNotEmpty && !results.contains(ConnectivityResult.none);
      if (hasNet) resume();
    });
  }
}
