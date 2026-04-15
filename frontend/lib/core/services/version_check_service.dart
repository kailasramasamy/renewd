import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../network/api_client.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class VersionCheckService {
  static const _appVersion = '1.0.0';

  static Future<void> check() async {
    try {
      final client = Get.find<ApiClient>();
      final response = await client.safeGet(
        '/version-check?version=$_appVersion',
      );
      final body = response.body as Map<String, dynamic>;

      final forceUpdate = body['force_update'] as bool? ?? false;
      final updateAvailable = body['update_available'] as bool? ?? false;
      final message = body['message'] as String? ?? '';

      if (forceUpdate) {
        _showForceUpdateDialog(message);
      } else if (updateAvailable) {
        _showOptionalUpdateBanner(message);
      }
    } catch (_) {
      // Silently fail — don't block the app if version check fails
    }
  }

  static void _showForceUpdateDialog(String message) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(LucideIcons.alertTriangle,
                  size: 20, color: RenewdColors.coralRed),
              const SizedBox(width: RenewdSpacing.sm),
              const Text('Update Required'),
            ],
          ),
          content: Text(
            message.isNotEmpty
                ? message
                : 'Please update Renewd to continue using the app.',
            style: RenewdTextStyles.bodySmall
                .copyWith(color: RenewdColors.slate, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: _openStore,
              child: const Text('Update Now'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void _showOptionalUpdateBanner(String message) {
    Get.snackbar(
      'Update Available',
      message.isNotEmpty ? message : 'A new version of Renewd is available.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: () {
          Get.closeCurrentSnackbar();
          _openStore();
        },
        child: Text('Update',
            style: TextStyle(color: RenewdColors.oceanBlue)),
      ),
    );
  }

  static Future<void> _openStore() async {
    // iOS App Store URL (replace with actual ID after publishing)
    const iosUrl = 'https://apps.apple.com/us/app/renewd/id6761368622';
    const androidUrl =
        'https://play.google.com/store/apps/details?id=in.quartex.renewd';

    final url = GetPlatform.isIOS ? iosUrl : androidUrl;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
