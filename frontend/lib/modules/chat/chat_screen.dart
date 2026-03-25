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
          'Minder AI',
          style: MinderTextStyles.h3.copyWith(color: MinderColors.lavender),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Ask me anything about your renewals',
                style:
                    MinderTextStyles.body.copyWith(color: MinderColors.slate),
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
          horizontal: MinderSpacing.lg,
          vertical: MinderSpacing.md,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: MinderColors.mist),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Ask Minder AI...',
                ),
              ),
            ),
            const SizedBox(width: MinderSpacing.sm),
            IconButton(
              onPressed: () {},
              icon: const Icon(Iconsax.send_1),
              color: MinderColors.oceanBlue,
            ),
          ],
        ),
      );
}
