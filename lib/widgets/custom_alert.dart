import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AlertType { success, error, warning, info }

class CustomAlert {
  static void show({
    required String message,
    required AlertType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (_isOverlayAvailable()) {
      Get.rawSnackbar(
        messageText: _AlertWidget(message: message, type: type),
        backgroundColor: Colors.transparent,
        boxShadows: [],
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.zero,
        borderRadius: 8,
        snackPosition: SnackPosition.TOP,
        duration: duration,
        animationDuration: const Duration(milliseconds: 300),
      );
    } else {
      _showFallbackSnackBar(message: message, type: type, duration: duration);
    }
  }

  /// Check if Overlay widget is available in the current context
  static bool _isOverlayAvailable() {
    final context = Get.overlayContext;
    if (context == null) return false;

    try {
      final overlay = Overlay.maybeOf(context);
      return overlay != null;
    } catch (e) {
      return false;
    }
  }

  /// Fallback method using ScaffoldMessenger with matching UI
  static void _showFallbackSnackBar({
    required String message,
    required AlertType type,
    required Duration duration,
  }) {
    final context = Get.context;
    if (context == null) return;

    try {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: _AlertWidget(
            message: message,
            type: type,
            showCloseButton: false, // ScaffoldMessenger handles dismiss
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          padding: EdgeInsets.zero,
          duration: duration,
          dismissDirection: DismissDirection.up,
          // showCloseIcon: true,
        ),
      );
    } catch (e) {
      // If ScaffoldMessenger also fails, silently ignore
      debugPrint('CustomAlert: Failed to show alert - $e');
    }
  }

  static void showSuccess(String message, {Duration? duration}) {
    show(
      message: message,
      type: AlertType.success,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  static void showError(String message, {Duration? duration}) {
    show(
      message: message,
      type: AlertType.error,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  static void showWarning(String message, {Duration? duration}) {
    show(
      message: message,
      type: AlertType.warning,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  static void showInfo(String message, {Duration? duration}) {
    show(
      message: message,
      type: AlertType.info,
      duration: duration ?? const Duration(seconds: 3),
    );
  }
}

class _AlertWidget extends StatelessWidget {
  final String message;
  final AlertType type;
  final bool showCloseButton;

  const _AlertWidget({
    required this.message,
    required this.type,
    this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getIcon(), size: 16, color: _getIconColor()),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.2,
                color: _getTextColor(),
              ),
            ),
          ),
          if (showCloseButton)
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.close, size: 16, color: _getIconColor()),
              ),
            ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case AlertType.success:
        return const Color(0xFFEAF7F0); // Light green
      case AlertType.error:
        return const Color(0xFFFDEDEF); // Light red (from Figma)
      case AlertType.warning:
        return const Color(0xFFFFF3CD); // Light yellow
      case AlertType.info:
        return const Color(0xFFE3F2FD); // Light blue
    }
  }

  IconData _getIcon() {
    switch (type) {
      case AlertType.success:
        return Icons.check_circle;
      case AlertType.error:
        return Icons.cancel;
      case AlertType.warning:
        return Icons.warning;
      case AlertType.info:
        return Icons.info;
    }
  }

  Color _getIconColor() {
    switch (type) {
      case AlertType.success:
        return const Color(0xFF4CAF50); // Green
      case AlertType.error:
        return const Color(0xFFE53B4C); // Red (from Figma)
      case AlertType.warning:
        return const Color(0xFFF57C00); // Orange
      case AlertType.info:
        return const Color(0xFF2196F3); // Blue
    }
  }

  Color _getTextColor() {
    switch (type) {
      case AlertType.success:
        return const Color(0xFF2E7D32); // Dark green
      case AlertType.error:
        return const Color(0xFFCB1B2C); // Dark red (from Figma)
      case AlertType.warning:
        return const Color(0xFFE65100); // Dark orange
      case AlertType.info:
        return const Color(0xFF1565C0); // Dark blue
    }
  }
}
