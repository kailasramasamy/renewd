import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'chat_controller.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ChatController());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Renewd AI',
          style: RenewdTextStyles.h3.copyWith(color: RenewdColors.lavender),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Ask me anything about your renewals',
                style:
                    RenewdTextStyles.body.copyWith(color: RenewdColors.slate),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: RenewdSpacing.lg,
          vertical: RenewdSpacing.md,
        ),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          border: const Border(
            top: BorderSide(color: RenewdColors.mist),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Ask Renewd AI...',
                ),
              ),
            ),
            const SizedBox(width: RenewdSpacing.sm),
            IconButton(
              onPressed: () {},
              icon: const Icon(Iconsax.send_1),
              color: RenewdColors.oceanBlue,
            ),
          ],
        ),
      );
}
