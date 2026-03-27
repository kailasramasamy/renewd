import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'notification_settings_controller.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(NotificationSettingsController());
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(RenewdSpacing.md),
          children: [
            _buildEnabledToggle(c),
            const SizedBox(height: RenewdSpacing.lg),
            _buildReminderDaysSection(c),
            const SizedBox(height: RenewdSpacing.lg),
            _buildDigestSection(c),
          ],
        );
      }),
    );
  }

  Widget _buildEnabledToggle(NotificationSettingsController c) {
    return Card(
      child: SwitchListTile(
        title: Text('Push Notifications', style: RenewdTextStyles.body),
        subtitle: Text(
          'Receive reminders before renewals expire',
          style: RenewdTextStyles.caption.copyWith(color: RenewdColors.slate),
        ),
        value: c.enabled.value,
        onChanged: c.toggleEnabled,
        activeTrackColor: RenewdColors.oceanBlue,
      ),
    );
  }

  Widget _buildReminderDaysSection(NotificationSettingsController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Default Reminder Days',
            style: RenewdTextStyles.h3.copyWith(color: RenewdColors.deepNavy)),
        const SizedBox(height: RenewdSpacing.xs),
        Text('Reminders are created for new renewals at these intervals',
            style: RenewdTextStyles.caption.copyWith(color: RenewdColors.slate)),
        const SizedBox(height: RenewdSpacing.sm),
        Wrap(
          spacing: RenewdSpacing.sm,
          children: NotificationSettingsController.availableDays
              .map((day) => _buildDayChip(c, day))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDayChip(NotificationSettingsController c, int day) {
    final selected = c.defaultDaysBefore.contains(day);
    final label = day == 1 ? '1 day' : '$day days';
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => c.toggleDay(day),
      selectedColor: RenewdColors.oceanBlue.withValues(alpha: 0.2),
      checkmarkColor: RenewdColors.oceanBlue,
      labelStyle: RenewdTextStyles.caption.copyWith(
        color: selected ? RenewdColors.oceanBlue : RenewdColors.slate,
      ),
    );
  }

  Widget _buildDigestSection(NotificationSettingsController c) {
    return Card(
      child: SwitchListTile(
        title: Text('Daily Digest', style: RenewdTextStyles.body),
        subtitle: Text(
          'Get a summary of upcoming renewals each morning',
          style: RenewdTextStyles.caption.copyWith(color: RenewdColors.slate),
        ),
        value: c.dailyDigestEnabled.value,
        onChanged: c.toggleDigest,
        activeTrackColor: RenewdColors.oceanBlue,
      ),
    );
  }
}
