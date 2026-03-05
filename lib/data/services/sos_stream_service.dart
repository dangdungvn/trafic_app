import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import '../../services/storage_service.dart';
import '../models/sos_model.dart';

/// Trạng thái kết nối SSE
enum SosConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  noNetwork,
  error,
}

/// SosStreamService quản lý kết nối SSE tới /sos/stream
/// Xử lý đầy đủ: mất mạng, có lại mạng, background/foreground, token hết hạn
class SosStreamService extends GetxService with WidgetsBindingObserver {
  // ─── Reactive state ───────────────────────────────────────────────────────
  final connectionStatus = SosConnectionStatus.disconnected.obs;
  final sosList = <SosResponseDTO>[].obs;
  final lastError = ''.obs;

  // ─── Internals ────────────────────────────────────────────────────────────
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  HttpClient? _httpClient;
  StreamSubscription<String>? _sseSubscription;

  bool _hasNetwork = true;
  bool _appInForeground = true;
  bool _isConnecting = false;
  bool _disposed = false;

  // Exponential backoff
  int _retryCount = 0;
  static const int _maxRetries = 10;
  static const Duration _baseDelay = Duration(seconds: 2);

  Timer? _reconnectTimer;

  // ─── Getter shortcut ──────────────────────────────────────────────────────
  static SosStreamService get to => Get.find<SosStreamService>();

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _listenConnectivity();
    connect();
  }

  @override
  void onClose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySub?.cancel();
    _reconnectTimer?.cancel();
    _disconnect();
    super.onClose();
  }

  // ─── AppLifecycle: background / foreground ────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App về foreground
      _appInForeground = true;
      if (connectionStatus.value != SosConnectionStatus.connected &&
          _hasNetwork) {
        _scheduleReconnect(immediately: true);
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // App vào background - ngắt kết nối để tiết kiệm pin
      _appInForeground = false;
      _disconnect();
      connectionStatus.value = SosConnectionStatus.disconnected;
    }
  }

  // ─── Connectivity monitoring ──────────────────────────────────────────────

  void _listenConnectivity() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final hasNet = results.any((r) => r != ConnectivityResult.none);

      if (!_hasNetwork && hasNet) {
        // Vừa có lại mạng
        _hasNetwork = true;
        if (_appInForeground) {
          _scheduleReconnect(immediately: true);
        }
      } else if (_hasNetwork && !hasNet) {
        // Vừa mất mạng
        _hasNetwork = false;
        _disconnect();
        _reconnectTimer?.cancel();
        connectionStatus.value = SosConnectionStatus.noNetwork;
      }
    });
  }

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Khởi động kết nối (reset retry count)
  void connect() {
    if (_disposed) return;
    _retryCount = 0;
    _startSse();
  }

  /// Ngắt kết nối thủ công
  void disconnect() {
    _reconnectTimer?.cancel();
    _disconnect();
    connectionStatus.value = SosConnectionStatus.disconnected;
  }

  // ─── SSE core logic ───────────────────────────────────────────────────────

  Future<void> _startSse() async {
    if (_isConnecting || _disposed) return;
    if (!_hasNetwork) {
      connectionStatus.value = SosConnectionStatus.noNetwork;
      return;
    }
    if (!_appInForeground) return;

    _isConnecting = true;
    connectionStatus.value = _retryCount > 0
        ? SosConnectionStatus.reconnecting
        : SosConnectionStatus.connecting;

    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? '';
      final token = StorageService.to.getToken() ?? '';
      final uri = Uri.parse('$baseUrl/sos/stream');

      _httpClient = HttpClient();
      final request = await _httpClient!.getUrl(uri);
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'text/event-stream');
      request.headers.set('Cache-Control', 'no-cache');

      final response = await request.close();

      // Token hết hạn
      if (response.statusCode == 401) {
        _httpClient?.close(force: true);
        _isConnecting = false;
        await _handleUnauthorized();
        return;
      }

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      // Kết nối thành công
      _retryCount = 0;
      _isConnecting = false;
      connectionStatus.value = SosConnectionStatus.connected;
      lastError.value = '';

      // Parse SSE stream
      _sseSubscription = response
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            _onSseLine,
            onError: _onSseError,
            onDone: _onSseDone,
            cancelOnError: false,
          );
    } catch (e) {
      _isConnecting = false;
      _onSseError(e);
    }
  }

  String _sseBuffer = '';

  void _onSseLine(String line) {
    if (line.isEmpty) {
      // Blank line = end of event, parse buffer
      if (_sseBuffer.isNotEmpty) {
        _parseSseEvent(_sseBuffer.trim());
        _sseBuffer = '';
      }
      return;
    }
    // Accumulate event lines
    _sseBuffer += '$line\n';
  }

  void _parseSseEvent(String raw) {
    // SSE format:
    //   event: <type>
    //   data: <json>
    String? dataLine;
    for (final line in raw.split('\n')) {
      if (line.startsWith('data:')) {
        dataLine = line.substring(5).trim();
      }
    }
    if (dataLine == null || dataLine.isEmpty) return;

    try {
      final json = jsonDecode(dataLine) as Map<String, dynamic>;
      final sos = SosResponseDTO.fromJson(json);
      // Update or add to list
      final idx = sosList.indexWhere((s) => s.sosId == sos.sosId);
      if (idx >= 0) {
        sosList[idx] = sos;
      } else {
        sosList.insert(0, sos);
      }
    } catch (_) {
      // Bỏ qua event không parse được
    }
  }

  void _onSseError(dynamic error) {
    _sseSubscription?.cancel();
    _httpClient?.close(force: true);
    _isConnecting = false;

    if (_disposed) return;

    final errMsg = error.toString();
    lastError.value = errMsg;

    if (!_hasNetwork) {
      connectionStatus.value = SosConnectionStatus.noNetwork;
      return;
    }

    connectionStatus.value = SosConnectionStatus.error;
    _scheduleReconnect();
  }

  void _onSseDone() {
    _sseSubscription?.cancel();
    _httpClient?.close(force: true);
    _isConnecting = false;

    if (_disposed) return;
    if (!_hasNetwork) {
      connectionStatus.value = SosConnectionStatus.noNetwork;
      return;
    }
    if (!_appInForeground) return;

    // Server đóng stream - thử kết nối lại
    _scheduleReconnect();
  }

  void _disconnect() {
    _reconnectTimer?.cancel();
    _sseSubscription?.cancel();
    _sseSubscription = null;
    _httpClient?.close(force: true);
    _httpClient = null;
    _isConnecting = false;
    _sseBuffer = '';
  }

  // ─── Retry with exponential backoff ──────────────────────────────────────

  void _scheduleReconnect({bool immediately = false}) {
    if (_disposed || _reconnectTimer?.isActive == true) return;
    if (_retryCount >= _maxRetries) {
      connectionStatus.value = SosConnectionStatus.error;
      lastError.value = 'Đã thử kết nối lại $_maxRetries lần không thành công';
      return;
    }

    final delay = immediately
        ? Duration.zero
        : _baseDelay * (1 << _retryCount.clamp(0, 6)); // tối đa ~128s

    _retryCount++;
    _reconnectTimer = Timer(delay, () {
      if (!_disposed && _hasNetwork && _appInForeground) {
        _startSse();
      }
    });
  }

  // ─── Token refresh khi 401 ───────────────────────────────────────────────

  Future<void> _handleUnauthorized() async {
    if (_disposed) return;
    connectionStatus.value = SosConnectionStatus.error;
    lastError.value = 'Phiên đăng nhập hết hạn';

    final storage = StorageService.to;
    final credentials = storage.getCredentials();
    if (credentials == null) {
      Get.offAllNamed('/login');
      return;
    }

    // Thử re-login thủ công với stored credentials
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? '';
      final loginUri = Uri.parse('$baseUrl/auth/login');
      final loginClient = HttpClient();
      final req = await loginClient.postUrl(loginUri);
      req.headers.set('Content-Type', 'application/json');
      req.write(
        jsonEncode({
          'username': credentials['username'],
          'password': credentials['password'],
        }),
      );
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      loginClient.close();

      if (res.statusCode == 200) {
        final json = jsonDecode(body) as Map<String, dynamic>;
        if (json['success'] == true && json['data'] != null) {
          await storage.setToken(json['data'] as String);
          // Token mới đã lưu, thử lại stream
          _retryCount = 0;
          _scheduleReconnect(immediately: true);
          return;
        }
      }
    } catch (_) {}

    // Re-login thất bại → về màn login
    await storage.removeToken();
    await storage.clearCredentials();
    Get.offAllNamed('/login');
  }
}
