import 'dart:async';
import 'package:get/get.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../../app/routes/app_routes.dart';

class SharingService extends GetxService {
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

    return this;
  }

  /// Called by SplashController after navigation to home is complete
  void processPendingShare() {
    if (pendingShare == null) return;
    final share = pendingShare!;
    pendingShare = null;
    Get.toNamed(
      AppRoutes.scanAdd,
      arguments: share,
    );
    ReceiveSharingIntent.instance.reset();
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
    _subscription?.cancel();
    super.onClose();
  }
}
