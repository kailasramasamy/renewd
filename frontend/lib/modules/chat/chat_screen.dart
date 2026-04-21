import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_opacity.dart';
import '../dashboard/dashboard_controller.dart';
import 'chat_controller.dart';
import 'chat_empty_state.dart';
import 'chat_tokens.dart';

// ─── Shared bubble helpers ───────────────────────────────────────────────────

BoxDecoration _aiBubbleDeco(bool isDark) => BoxDecoration(
      color: isDark ? RenewdColors.darkSlate : Colors.white,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(RenewdRadius.lg),
        bottomLeft: Radius.circular(RenewdRadius.lg),
        bottomRight: Radius.circular(RenewdRadius.lg),
      ),
      border: Border.all(
          color: isDark ? RenewdColors.darkBorder : RenewdColors.mist),
    );

Widget _aiEyebrow() => Padding(
      padding: const EdgeInsets.only(
          left: RenewdSpacing.xs, bottom: RenewdSpacing.xs),
      child: Text(
        '✦ RENEWD AI',
        style: RenewdTextStyles.sectionHeader
            .copyWith(color: RenewdColors.lavender, fontSize: 10),
      ),
    );

// ─── Screen ──────────────────────────────────────────────────────────────────

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ChatController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    void send() {
      final text = c.textController.text;
      if (text.trim().isEmpty) return;
      c.textController.clear();
      c.sendMessage(text);
      Future.delayed(const Duration(milliseconds: 100), () {
        if (c.scrollController.hasClients) {
          c.scrollController.animateTo(
            c.scrollController.position.maxScrollExtent + 100,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: _ChatAppBar(isDark: isDark),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (c.messages.isEmpty) {
                  return ChatEmptyState(
                      isDark: isDark, onSuggestion: c.sendMessage);
                }
                return ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  controller: c.scrollController,
                  padding: const EdgeInsets.fromLTRB(RenewdSpacing.lg,
                      RenewdSpacing.lg, RenewdSpacing.lg, RenewdSpacing.xl),
                  itemCount:
                      c.messages.length + (c.isLoading.value ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i == c.messages.length) {
                      return _TypingIndicator(isDark: isDark);
                    }
                    return _MessageBubble(
                        message: c.messages[i], isDark: isDark);
                  },
                );
              }),
            ),
            _Composer(
                controller: c.textController,
                isDark: isDark,
                onSend: send,
                isLoading: c.isLoading),
          ],
        ),
      ),
    );
  }
}

// ─── App Bar ─────────────────────────────────────────────────────────────────

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDark;
  const _ChatAppBar({required this.isDark});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  DashboardController? _dc() {
    try { return Get.find<DashboardController>(); } catch (_) { return null; }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: RenewdSpacing.lg,
      title: Row(children: [
        ShaderMask(
          shaderCallback: (b) => kChatGradient.createShader(b),
          child: const Icon(LucideIcons.sparkles, size: 20, color: Colors.white),
        ),
        const SizedBox(width: RenewdSpacing.sm),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Renewd AI',
              style: RenewdTextStyles.subtitle.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark ? RenewdColors.warmWhite : RenewdColors.deepNavy,
              )),
          Obx(() {
            final count = _dc()?.renewals.length ?? 0;
            return Row(children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: RenewdColors.teal, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Text(
                'online · knows $count renewal${count == 1 ? '' : 's'}',
                style: RenewdTextStyles.caption
                    .copyWith(color: RenewdColors.warmGray),
              ),
            ]);
          }),
        ]),
      ]),
    );
  }
}

// ─── Message Bubbles ─────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDark;
  const _MessageBubble({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isUser) _aiEyebrow(),
          Container(
            margin: const EdgeInsets.only(bottom: RenewdSpacing.md),
            padding: const EdgeInsets.symmetric(
                horizontal: RenewdSpacing.lg, vertical: RenewdSpacing.md),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78),
            decoration: isUser
                ? const BoxDecoration(
                    gradient: kChatGradient,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(RenewdRadius.lg),
                      topRight: Radius.circular(RenewdRadius.lg),
                      bottomLeft: Radius.circular(RenewdRadius.lg),
                      bottomRight: Radius.circular(4),
                    ),
                  )
                : _aiBubbleDeco(isDark),
            child: isUser
                ? Text(message.text,
                    style: RenewdTextStyles.bodySmall
                        .copyWith(color: Colors.white, height: 1.4))
                : MarkdownBody(
                    data: message.text,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: RenewdTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? RenewdColors.warmWhite
                              : RenewdColors.deepNavy,
                          height: 1.5),
                      strong: RenewdTextStyles.bodySmall.copyWith(
                          color: isDark ? Colors.white : RenewdColors.deepNavy,
                          fontWeight: FontWeight.w700),
                      listBullet: RenewdTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? RenewdColors.warmWhite
                              : RenewdColors.deepNavy),
                      listBulletPadding: const EdgeInsets.only(right: 8),
                      blockSpacing: 8,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final bool isDark;
  const _TypingIndicator({required this.isDark});

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _aiEyebrow(),
            Container(
              margin: const EdgeInsets.only(bottom: RenewdSpacing.md),
              padding: const EdgeInsets.symmetric(
                  horizontal: RenewdSpacing.lg, vertical: RenewdSpacing.md),
              decoration: _aiBubbleDeco(isDark),
              child: const _BouncingDots(),
            ),
          ],
        ),
      );
}

class _BouncingDots extends StatefulWidget {
  const _BouncingDots();

  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _ctrls;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(3, (i) {
      final c = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 600));
      Future.delayed(Duration(milliseconds: i * 150),
          () { if (mounted) c.repeat(reverse: true); });
      return c;
    });
    _anims = _ctrls
        .map((c) => Tween<double>(begin: 0, end: -6)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
          (i) => AnimatedBuilder(
            animation: _anims[i],
            builder: (_, __) => Transform.translate(
              offset: Offset(0, _anims[i].value),
              child: Container(
                width: 7,
                height: 7,
                margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                decoration: const BoxDecoration(
                    gradient: kChatGradient, shape: BoxShape.circle),
              ),
            ),
          ),
        ),
      );
}

// ─── Composer ────────────────────────────────────────────────────────────────

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final VoidCallback onSend;
  final RxBool isLoading;

  const _Composer({
    required this.controller,
    required this.isDark,
    required this.onSend,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) => ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            color: (isDark ? RenewdColors.charcoal : Colors.white)
                .withValues(alpha: RenewdOpacity.heavy),
            padding: const EdgeInsets.fromLTRB(RenewdSpacing.lg,
                RenewdSpacing.sm, RenewdSpacing.lg, RenewdSpacing.sm),
            child: SafeArea(
              top: false,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? RenewdColors.darkSlate
                      : RenewdColors.softWhite,
                  borderRadius: RenewdRadius.pillAll,
                  border: Border.all(
                      color: isDark
                          ? RenewdColors.darkBorder
                          : RenewdColors.mist),
                ),
                child: Row(children: [
                  const SizedBox(width: RenewdSpacing.lg),
                  ShaderMask(
                    shaderCallback: (b) => kChatGradient.createShader(b),
                    child: const Icon(LucideIcons.sparkles,
                        size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: RenewdSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onSubmitted: (_) => onSend(),
                      textInputAction: TextInputAction.send,
                      style: RenewdTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? RenewdColors.warmWhite
                              : RenewdColors.deepNavy),
                      decoration: InputDecoration(
                        hintText: 'Ask about your renewals...',
                        hintStyle: RenewdTextStyles.bodySmall
                            .copyWith(color: RenewdColors.warmGray),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: RenewdSpacing.md),
                      ),
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (_, value, __) => Obx(() {
                      final active = !isLoading.value &&
                          value.text.trim().isNotEmpty;
                      return Padding(
                        padding: const EdgeInsets.all(4),
                        child: GestureDetector(
                          onTap: active ? onSend : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: active ? kChatGradient : null,
                              color: active
                                  ? null
                                  : (isDark
                                      ? RenewdColors.steel
                                      : RenewdColors.cloudGray),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(LucideIcons.arrowUp,
                                size: 18,
                                color:
                                    active ? Colors.white : RenewdColors.slate),
                          ),
                        ),
                      );
                    }),
                  ),
                ]),
              ),
            ),
          ),
        ),
      );
}
