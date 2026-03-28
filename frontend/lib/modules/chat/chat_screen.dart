import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'chat_controller.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ChatController());
    final textCtrl = TextEditingController();
    final scrollCtrl = ScrollController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    void send() {
      final text = textCtrl.text;
      if (text.trim().isEmpty) return;
      textCtrl.clear();
      c.sendMessage(text);
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollCtrl.hasClients) {
          scrollCtrl.animateTo(scrollCtrl.position.maxScrollExtent + 100,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(LucideIcons.sparkles, size: 18, color: RenewdColors.oceanBlue),
            const SizedBox(width: RenewdSpacing.sm),
            const Text('Renewd AI'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (c.messages.isEmpty) return _EmptyChat();
              return ListView.builder(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                controller: scrollCtrl,
                padding: const EdgeInsets.all(RenewdSpacing.lg),
                itemCount: c.messages.length + (c.isLoading.value ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == c.messages.length) return _TypingIndicator();
                  return _MessageBubble(
                    message: c.messages[i],
                    isDark: isDark,
                  );
                },
              );
            }),
          ),
          _InputBar(
            controller: textCtrl,
            isDark: isDark,
            onSend: send,
            isLoading: c.isLoading,
          ),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RenewdSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.messageCircle,
                size: 48, color: RenewdColors.slate),
            const SizedBox(height: RenewdSpacing.lg),
            Text('Ask Renewd AI',
                style: RenewdTextStyles.h3
                    .copyWith(color: RenewdColors.slate)),
            const SizedBox(height: RenewdSpacing.sm),
            Text(
              'Try asking about your renewals, spending, or upcoming due dates',
              textAlign: TextAlign.center,
              style: RenewdTextStyles.bodySmall
                  .copyWith(color: RenewdColors.slate),
            ),
            const SizedBox(height: RenewdSpacing.xl),
            Wrap(
              spacing: RenewdSpacing.sm,
              runSpacing: RenewdSpacing.sm,
              alignment: WrapAlignment.center,
              children: _suggestions
                  .map((s) => _SuggestionChip(label: s))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  static const _suggestions = [
    'What renewals are due this week?',
    'How much am I spending monthly?',
    'Show my insurance renewals',
    'Which renewal is most expensive?',
  ];
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  const _SuggestionChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final c = Get.find<ChatController>();
        c.sendMessage(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: RenewdSpacing.md,
          vertical: RenewdSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: RenewdColors.oceanBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: RenewdColors.oceanBlue.withValues(alpha: 0.2),
          ),
        ),
        child: Text(label,
            style: RenewdTextStyles.caption
                .copyWith(color: RenewdColors.oceanBlue)),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDark;
  const _MessageBubble({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: RenewdSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: RenewdSpacing.lg,
          vertical: RenewdSpacing.md,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? RenewdColors.oceanBlue
              : isDark
                  ? RenewdColors.darkSlate
                  : RenewdColors.cloudGray,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: isUser
            ? Text(
                message.text,
                style: RenewdTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  height: 1.4,
                ),
              )
            : MarkdownBody(
                data: message.text,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: RenewdTextStyles.bodySmall.copyWith(
                    color: isDark ? RenewdColors.warmWhite : RenewdColors.deepNavy,
                    height: 1.5,
                  ),
                  strong: RenewdTextStyles.bodySmall.copyWith(
                    color: isDark ? Colors.white : RenewdColors.deepNavy,
                    fontWeight: FontWeight.w700,
                  ),
                  listBullet: RenewdTextStyles.bodySmall.copyWith(
                    color: isDark ? RenewdColors.warmWhite : RenewdColors.deepNavy,
                  ),
                  listBulletPadding: const EdgeInsets.only(right: 8),
                  blockSpacing: 8,
                ),
              ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: RenewdSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: RenewdSpacing.lg,
          vertical: RenewdSpacing.md,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? RenewdColors.darkSlate
              : RenewdColors.cloudGray,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: RenewdColors.oceanBlue,
              ),
            ),
            const SizedBox(width: RenewdSpacing.sm),
            Text('Thinking...',
                style: RenewdTextStyles.caption
                    .copyWith(color: RenewdColors.slate)),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final VoidCallback onSend;
  final RxBool isLoading;

  const _InputBar({
    required this.controller,
    required this.isDark,
    required this.onSend,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          RenewdSpacing.lg, RenewdSpacing.sm, RenewdSpacing.sm, RenewdSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? RenewdColors.charcoal : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? RenewdColors.darkBorder : RenewdColors.mist,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onSend(),
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: 'Ask anything...',
                  hintStyle: RenewdTextStyles.bodySmall
                      .copyWith(color: RenewdColors.slate),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Obx(() => IconButton(
                  onPressed: isLoading.value ? null : onSend,
                  icon: Icon(LucideIcons.send, size: 20),
                  color: RenewdColors.oceanBlue,
                )),
          ],
        ),
      ),
    );
  }
}
