import 'dart:async';
import 'package:get/get.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../../app/routes/app_routes.dart';

class SharingService extends GetxService {
  StreamSubscription? _subscription;

  Future<SharingService> init() async {
    // Handle files shared while app is running
    _subscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen(_handleSharedFiles);

    // Handle files shared when app was closed
    final initial = await ReceiveSharingIntent.instance.getInitialMedia();
    if (initial.isNotEmpty) {
      // Delay to let the app finish initializing
      Future.delayed(const Duration(seconds: 1), () {
        _handleSharedFiles(initial);
      });
    }

    return this;
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
    _subscription?.cancel();
    super.onClose();
  }
}
