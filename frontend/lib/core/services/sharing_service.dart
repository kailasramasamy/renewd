import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../../app/routes/app_routes.dart';

class SharingService extends GetxService with WidgetsBindingObserver {
  StreamSubscription? _subscription;

  /// Pending shared file to process after app finishes navigating
  Map<String, String>? pendingShare;

  Future<SharingService> init() async {
    // Handle files shared while app is running
    _subscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen(_handleSharedFiles);

    // Handle files shared when app was closed — store for later
    final initial = await ReceiveSharingIntent.instance.getInitialMedia();
    if (initial.isNotEmpty) {
      _storePendingShare(initial);
    }

    WidgetsBinding.instance.addObserver(this);
    return this;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndNavigate();
    }
  }

  void _checkAndNavigate() {
    _channel.invokeMethod<String>('getSharedData').then((json) {
      if (json == null || json.isEmpty) return;
      try {
        final list = jsonDecode(json) as List<dynamic>;
        if (list.isNotEmpty) {
          final item = list.first as Map<String, dynamic>;
          final path = item['path'] as String?;
          if (path != null) {
            final name = path.split('/').last;
            _channel.invokeMethod('clearSharedData');
            Get.toNamed(
              AppRoutes.scanAdd,
              arguments: {'filePath': path, 'fileName': name},
            );
          }
        }
      } catch (_) {}
    }).catchError((_) {});
  }

  /// Called by SplashController after navigation to home is complete
  Future<void> processPendingShare() async {
    // Also check App Group UserDefaults (from native share extension)
    if (pendingShare == null) {
      await _checkAppGroupSharedData();
    }

    if (pendingShare == null) return;
    final share = pendingShare!;
    pendingShare = null;
    Get.toNamed(
      AppRoutes.scanAdd,
      arguments: share,
    );
    ReceiveSharingIntent.instance.reset();
  }

  static const _channel = MethodChannel('com.quartex.renewd/share');

  Future<void> _checkAppGroupSharedData() async {
    try {
      final json = await _channel.invokeMethod<String>('getSharedData');
      if (json == null || json.isEmpty) return;
      final list = jsonDecode(json) as List<dynamic>;
      if (list.isNotEmpty) {
        final item = list.first as Map<String, dynamic>;
        final path = item['path'] as String?;
        if (path != null) {
          final name = path.split('/').last;
          pendingShare = {'filePath': path, 'fileName': name};
          await _channel.invokeMethod('clearSharedData');
        }
      }
    } catch (_) {}
  }

  void _storePendingShare(List<SharedMediaFile> files) {
    if (files.isEmpty) return;
    final file = files.first;
    final path = file.path;
    final name = path.split('/').last;

    final ext = name.split('.').last.toLowerCase();
    const allowed = ['pdf', 'jpg', 'jpeg', 'png', 'webp'];
    if (!allowed.contains(ext)) return;

    pendingShare = {'filePath': path, 'fileName': name};
  }

  void _handleSharedFiles(List<SharedMediaFile> files) {
    if (files.isEmpty) return;

    final file = files.first;
    final path = file.path;
    final name = path.split('/').last;

    // Only accept PDFs and images
    final ext = name.split('.').last.toLowerCase();
    const allowed = ['pdf', 'jpg', 'jpeg', 'png', 'webp'];
    if (!allowed.contains(ext)) return;

    // Navigate to scan screen with the file
    Get.toNamed(
      AppRoutes.scanAdd,
      arguments: {'filePath': path, 'fileName': name},
    );

    // Reset intent so it doesn't trigger again
    ReceiveSharingIntent.instance.reset();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    super.onClose();
  }
}
