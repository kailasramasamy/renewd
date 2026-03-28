import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/routes/app_routes.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';

class NotificationInboxScreen extends StatelessWidget {
  const NotificationInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(_InboxController());
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => Get.back(),
        ),
        title: const Text('Notifications'),
        actions: [
          Obx(() => c.notifications.any((n) => n['is_read'] != true)
              ? TextButton(
                  onPressed: c.markAllRead,
                  child: Text('Mark all read',
                      style: RenewdTextStyles.caption
                          .copyWith(color: RenewdColors.oceanBlue)),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.notifications.isEmpty) {
          return _EmptyState();
        }
        return ListView.builder(
          padding: const EdgeInsets.all(RenewdSpacing.lg),
          itemCount: c.notifications.length,
          itemBuilder: (context, i) => _NotificationTile(
            notification: c.notifications[i],
            onTap: () => c.onTap(c.notifications[i]),
          ),
        );
      }),
    );
  }
}

class _InboxController extends GetxController {
  final _client = Get.find<ApiClient>();
  final RxList<Map<String, dynamic>> notifications =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final response =
          await _client.safeGet(ApiEndpoints.notificationLog);
      final body = response.body as Map<String, dynamic>;
      final list = body['notifications'] as List<dynamic>? ?? [];
      notifications.assignAll(list.cast<Map<String, dynamic>>());
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> markAllRead() async {
    try {
      await _client.safePut(ApiEndpoints.notificationMarkAllRead, {});
      for (final n in notifications) {
        n['is_read'] = true;
      }
      notifications.refresh();
    } catch (_) {}
  }

  Future<void> onTap(Map<String, dynamic> notification) async {
    // Mark as read
    if (notification['is_read'] != true) {
      final id = notification['id'] as String;
      await _client.safePut(ApiEndpoints.notificationMarkRead(id), {});
      notification['is_read'] = true;
      notifications.refresh();
    }

    // Navigate to renewal if linked
    final renewalId = notification['renewal_id'] as String?;
    if (renewalId != null) {
      Get.toNamed(AppRoutes.renewalDetail, arguments: renewalId);
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isRead = notification['is_read'] == true;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final type = notification['type'] as String? ?? 'reminder';
    final createdAt = DateTime.tryParse(
        notification['created_at'] as String? ?? '');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: RenewdSpacing.sm),
        padding: const EdgeInsets.all(RenewdSpacing.lg),
        decoration: BoxDecoration(
          color: isDark
              ? (isRead ? RenewdColors.charcoal : RenewdColors.darkSlate)
              : (isRead ? Colors.white : RenewdColors.cloudGray),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _iconColor(type).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon(type), size: 18, color: _iconColor(type)),
            ),
            const SizedBox(width: RenewdSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification['title'] as String? ?? '',
                    style: RenewdTextStyles.bodySmall.copyWith(
                      fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification['body'] as String? ?? '',
                    style: RenewdTextStyles.caption
                        .copyWith(color: RenewdColors.slate),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (createdAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      RenewdDateUtils.formatDate(createdAt),
                      style: RenewdTextStyles.caption.copyWith(
                        color: RenewdColors.slate,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: RenewdColors.oceanBlue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _icon(String type) {
    switch (type) {
      case 'reminder': return LucideIcons.bell;
      case 'digest': return LucideIcons.calendar;
      default: return LucideIcons.bell;
    }
  }

  Color _iconColor(String type) {
    switch (type) {
      case 'reminder': return RenewdColors.tangerine;
      case 'digest': return RenewdColors.oceanBlue;
      default: return RenewdColors.slate;
    }
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.bellOff, size: 48, color: RenewdColors.slate),
          const SizedBox(height: RenewdSpacing.lg),
          Text('No notifications yet',
              style: RenewdTextStyles.body
                  .copyWith(color: RenewdColors.slate)),
          const SizedBox(height: RenewdSpacing.xs),
          Text('Reminders will appear here',
              style: RenewdTextStyles.caption
                  .copyWith(color: RenewdColors.slate)),
        ],
      ),
    );
  }
}
