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
    debugPrint('[SharingService] init started');

    // Handle files shared while app is running
    _subscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen((files) {
      debugPrint('[SharingService] stream received ${files.length} files');
      for (final f in files) {
        debugPrint('[SharingService] stream file: ${f.path} type=${f.type} mimeType=${f.mimeType}');
      }
      _handleSharedFiles(files);
    });

    // Handle files shared when app was closed — store for later
    final initial = await ReceiveSharingIntent.instance.getInitialMedia();
    debugPrint('[SharingService] initial media: ${initial.length} files');
    for (final f in initial) {
      debugPrint('[SharingService] initial file: ${f.path} type=${f.type} mimeType=${f.mimeType}');
    }
    if (initial.isNotEmpty) {
      _storePendingShare(initial);
    }

    WidgetsBinding.instance.addObserver(this);
    return this;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('[SharingService] app resumed, checking App Group');
      _checkAndNavigate();
    }
  }

  void _checkAndNavigate() {
    _channel.invokeMethod<String>('getSharedData').then((json) {
      debugPrint('[SharingService] resume check, App Group data: $json');
      if (json == null || json.isEmpty) return;
      try {
        final list = jsonDecode(json) as List<dynamic>;
        if (list.isNotEmpty) {
          final item = list.first as Map<String, dynamic>;
          final path = item['path'] as String?;
          if (path != null) {
            final name = path.split('/').last;
            debugPrint('[SharingService] navigating to scanAdd with $path');
            _channel.invokeMethod('clearSharedData');
            Get.toNamed(
              AppRoutes.scanAdd,
              arguments: {'filePath': path, 'fileName': name},
            );
          }
        }
      } catch (e) {
        debugPrint('[SharingService] Error parsing shared data: $e');
      }
    }).catchError((e) {
      debugPrint('[SharingService] Channel error: $e');
    });
  }

  /// Called by SplashController after navigation to home is complete
  void processPendingShare() {
    debugPrint('[SharingService] processPendingShare called, pending=$pendingShare');

    // Also check App Group UserDefaults (from native share extension)
    if (pendingShare == null) {
      _checkAppGroupSharedData();
    }

    if (pendingShare == null) return;
    final share = pendingShare!;
    pendingShare = null;
    debugPrint('[SharingService] navigating to scanAdd with $share');
    Get.toNamed(
      AppRoutes.scanAdd,
      arguments: share,
    );
    ReceiveSharingIntent.instance.reset();
  }

  static const _channel = MethodChannel('com.quartex.renewd/share');

  void _checkAppGroupSharedData() {
    // Try reading from NSUserDefaults via App Group
    _channel.invokeMethod<String>('getSharedData').then((json) {
      debugPrint('[SharingService] App Group data: $json');
      if (json == null || json.isEmpty) return;
      try {
        final list = jsonDecode(json) as List<dynamic>;
        if (list.isNotEmpty) {
          final item = list.first as Map<String, dynamic>;
          final path = item['path'] as String?;
          if (path != null) {
            final name = path.split('/').last;
            pendingShare = {'filePath': path, 'fileName': name};
            debugPrint('[SharingService] Found shared data from App Group: $pendingShare');
            // Clear it
            _channel.invokeMethod('clearSharedData');
          }
        }
      } catch (e) {
        debugPrint('[SharingService] Error parsing App Group data: $e');
      }
    }).catchError((e) {
      debugPrint('[SharingService] App Group channel not available: $e');
    });
  }

  void _storePendingShare(List<SharedMediaFile> files) {
    if (files.isEmpty) return;
    final file = files.first;
    final path = file.path;
    final name = path.split('/').last;

    final ext = name.split('.').last.toLowerCase();
    debugPrint('[SharingService] _storePendingShare: name=$name ext=$ext path=$path');
    const allowed = ['pdf', 'jpg', 'jpeg', 'png', 'webp'];
    if (!allowed.contains(ext)) {
      debugPrint('[SharingService] _storePendingShare: REJECTED ext=$ext');
      return;
    }

    pendingShare = {'filePath': path, 'fileName': name};
    debugPrint('[SharingService] _storePendingShare: STORED pendingShare=$pendingShare');
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
