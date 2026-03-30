import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_opacity.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/snackbar_helper.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _client = Get.find<ApiClient>();
  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = true;
  bool _handledDeeplink = false;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    try {
      final res = await _client.safeGet('/support');
      final body = res.body as Map<String, dynamic>;
      setState(() {
        _tickets = (body['tickets'] as List).cast<Map<String, dynamic>>();
        _isLoading = false;
      });

      // Auto-open ticket if navigated with a ticket ID
      if (!_handledDeeplink) {
        final ticketId = Get.arguments as String?;
        if (ticketId != null && ticketId.isNotEmpty) {
          _handledDeeplink = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.to(() => _TicketDetailScreen(ticketId: ticketId));
          });
        }
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          tooltip: 'Go back',
          onPressed: () => Get.back(),
        ),
        title: const Text('Support'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'support_fab',
        tooltip: 'New ticket',
        onPressed: () async {
          final result = await Get.to(() => const _CreateTicketScreen());
          if (result == true) _fetchTickets();
        },
        backgroundColor: RenewdColors.oceanBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tickets.isEmpty
              ? _buildEmpty()
              : _buildList(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RenewdSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.lifeBuoy, size: 48, color: RenewdColors.slate),
            const SizedBox(height: RenewdSpacing.lg),
            Text('No tickets yet',
                style: RenewdTextStyles.body.copyWith(color: RenewdColors.slate)),
            const SizedBox(height: RenewdSpacing.xs),
            Text('Tap + to report a bug, request a feature, or ask a question.',
                textAlign: TextAlign.center,
                style: RenewdTextStyles.caption.copyWith(
                    color: RenewdColors.slate, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _fetchTickets,
      child: ListView.builder(
        padding: const EdgeInsets.all(RenewdSpacing.lg),
        itemCount: _tickets.length,
        itemBuilder: (_, i) => _TicketCard(
          ticket: _tickets[i],
          onTap: () async {
            await Get.to(() => _TicketDetailScreen(ticketId: _tickets[i]['id'] as String));
            _fetchTickets();
          },
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final VoidCallback onTap;

  const _TicketCard({required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = ticket['status'] as String;
    final type = ticket['type'] as String;
    final adminReplies = ticket['admin_replies'] as int? ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: RenewdSpacing.sm),
        padding: const EdgeInsets.all(RenewdSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? RenewdColors.darkSlate : Colors.white,
          borderRadius: RenewdRadius.lgAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _TypeBadge(type: type),
                const SizedBox(width: RenewdSpacing.sm),
                _StatusBadge(status: status),
                const Spacer(),
                if (adminReplies > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: RenewdSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: RenewdColors.oceanBlue.withValues(alpha: RenewdOpacity.light),
                      borderRadius: RenewdRadius.pillAll,
                    ),
                    child: Text('$adminReplies reply',
                        style: RenewdTextStyles.caption.copyWith(
                            color: RenewdColors.oceanBlue)),
                  ),
              ],
            ),
            const SizedBox(height: RenewdSpacing.sm),
            Text(ticket['subject'] as String,
                style: RenewdTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: RenewdSpacing.xs),
            Text(
              ticket['description'] as String,
              style: RenewdTextStyles.bodySmall.copyWith(color: RenewdColors.slate),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: RenewdSpacing.sm),
            Text(
              _formatTime(ticket['created_at'] as String?),
              style: RenewdTextStyles.caption.copyWith(
                  color: RenewdColors.slate),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    final dt = DateTime.tryParse(timestamp);
    if (dt == null) return '';
    final local = dt.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${local.day}/${local.month}/${local.year}';
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'bug': RenewdColors.coralRed,
      'feedback': RenewdColors.oceanBlue,
      'feature': RenewdColors.lavender,
      'question': RenewdColors.amber,
    };
    final color = colors[type] ?? RenewdColors.slate;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: RenewdSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: RenewdOpacity.medium),
        borderRadius: RenewdRadius.pillAll,
      ),
      child: Text(type,
          style: RenewdTextStyles.caption.copyWith(color: color)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'open': RenewdColors.coralRed,
      'in_progress': RenewdColors.amber,
      'resolved': RenewdColors.emerald,
      'closed': RenewdColors.slate,
    };
    final color = colors[status] ?? RenewdColors.slate;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: RenewdSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: RenewdOpacity.medium),
        borderRadius: RenewdRadius.pillAll,
      ),
      child: Text(status.replaceAll('_', ' '),
          style: RenewdTextStyles.caption.copyWith(color: color)),
    );
  }
}

// ─── Create Ticket ───────────────────────────────────

class _CreateTicketScreen extends StatefulWidget {
  const _CreateTicketScreen();

  @override
  State<_CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<_CreateTicketScreen> {
  final _client = Get.find<ApiClient>();
  String _type = 'feedback';
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_subjectCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) {
      showErrorSnack('Please fill in subject and description');
      return;
    }
    setState(() => _sending = true);
    try {
      await _client.safePost('/support', {
        'type': _type,
        'subject': _subjectCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'device_info': '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
      });
    } catch (_) {
      // Ignore errors — ticket may still have been created
    }
    if (!mounted) return;
    showSuccessSnack('Ticket submitted');
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Get.back(),
        ),
        title: const Text('New Ticket'),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(RenewdSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type', style: RenewdTextStyles.bodySmall.copyWith(color: RenewdColors.slate)),
            const SizedBox(height: RenewdSpacing.sm),
            Wrap(
              spacing: RenewdSpacing.sm,
              runSpacing: RenewdSpacing.sm,
              children: ['bug', 'feedback', 'feature', 'question'].map((t) {
                final selected = _type == t;
                final colors = {
                  'bug': RenewdColors.coralRed,
                  'feedback': RenewdColors.oceanBlue,
                  'feature': RenewdColors.lavender,
                  'question': RenewdColors.amber,
                };
                final icons = {
                  'bug': LucideIcons.bug,
                  'feedback': LucideIcons.messageCircle,
                  'feature': LucideIcons.lightbulb,
                  'question': LucideIcons.helpCircle,
                };
                final color = colors[t]!;
                return GestureDetector(
                  onTap: () => setState(() => _type = t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: RenewdSpacing.md, vertical: RenewdSpacing.sm),
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withValues(alpha: RenewdOpacity.medium)
                          : RenewdColors.steel,
                      borderRadius: RenewdRadius.pillAll,
                      border: Border.all(
                        color: selected ? color : RenewdColors.darkBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icons[t], size: 14, color: selected ? color : RenewdColors.slate),
                        const SizedBox(width: RenewdSpacing.xs),
                        Text(t[0].toUpperCase() + t.substring(1),
                            style: RenewdTextStyles.caption.copyWith(
                                color: selected ? color : RenewdColors.slate)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: RenewdSpacing.xl),
            Text('Subject', style: RenewdTextStyles.bodySmall.copyWith(color: RenewdColors.slate)),
            const SizedBox(height: RenewdSpacing.sm),
            TextField(
              controller: _subjectCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Brief summary of your issue'),
            ),
            const SizedBox(height: RenewdSpacing.xl),
            Text('Description', style: RenewdTextStyles.bodySmall.copyWith(color: RenewdColors.slate)),
            const SizedBox(height: RenewdSpacing.sm),
            TextField(
              controller: _descCtrl,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Describe the issue in detail...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: RenewdSpacing.xxl),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _sending ? null : _submit,
                child: _sending
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Submit Ticket'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Ticket Detail ───────────────────────────────────

class _TicketDetailScreen extends StatefulWidget {
  final String ticketId;
  const _TicketDetailScreen({required this.ticketId});

  @override
  State<_TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<_TicketDetailScreen> {
  final _client = Get.find<ApiClient>();
  final _replyCtrl = TextEditingController();
  Map<String, dynamic>? _ticket;
  List<Map<String, dynamic>> _replies = [];
  bool _isLoading = true;
  bool _sending = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _fetch() async {
    try {
      final res = await _client.safeGet('/support/${widget.ticketId}');
      final body = res.body as Map<String, dynamic>;
      setState(() {
        _ticket = body['ticket'] as Map<String, dynamic>;
        _replies = (body['replies'] as List).cast<Map<String, dynamic>>();
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendReply() async {
    if (_replyCtrl.text.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _sending = true);
    try {
      await _client.safePost('/support/${widget.ticketId}/reply', {
        'message': _replyCtrl.text.trim(),
      });
      _replyCtrl.clear();
      await _fetch();
    } catch (_) {
      showErrorSnack('Failed to send reply');
    }
    setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => Get.back(),
          ),
          title: Text(_ticket?['subject'] as String? ?? 'Ticket'),
        ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.all(RenewdSpacing.lg),
                    children: [
                      // Ticket info
                      Container(
                        padding: const EdgeInsets.all(RenewdSpacing.lg),
                        decoration: BoxDecoration(
                          color: isDark ? RenewdColors.darkSlate : Colors.white,
                          borderRadius: RenewdRadius.lgAll,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _TypeBadge(type: _ticket!['type'] as String),
                                const SizedBox(width: RenewdSpacing.sm),
                                _StatusBadge(status: _ticket!['status'] as String),
                              ],
                            ),
                            const SizedBox(height: RenewdSpacing.md),
                            Text(_ticket!['description'] as String,
                                style: RenewdTextStyles.caption
                                    .copyWith(height: 1.5, color: RenewdColors.slate)),
                          ],
                        ),
                      ),
                      const SizedBox(height: RenewdSpacing.lg),
                      // Replies
                      ..._replies.map((r) => _ReplyBubble(reply: r)),
                    ],
                  ),
                ),
                // Reply input
                Container(
                  padding: const EdgeInsets.all(RenewdSpacing.lg),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: RenewdColors.darkBorder, width: 0.5)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _replyCtrl,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Type a reply...',
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: RenewdSpacing.sm),
                        IconButton(
                          onPressed: _sending ? null : _sendReply,
                          icon: _sending
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(LucideIcons.send, size: 20),
                          color: RenewdColors.oceanBlue,
                          tooltip: 'Send reply',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    ),
    );
  }
}

class _ReplyBubble extends StatelessWidget {
  final Map<String, dynamic> reply;
  const _ReplyBubble({required this.reply});

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    final dt = DateTime.tryParse(timestamp);
    if (dt == null) return '';
    final local = dt.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '${local.day}/${local.month} $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final sender = reply['sender'] as String? ?? 'user';
    final isAdmin = sender == 'admin';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: RenewdSpacing.md),
        padding: const EdgeInsets.all(RenewdSpacing.md),
        decoration: BoxDecoration(
          color: isAdmin
              ? (isDark ? RenewdColors.steel : RenewdColors.cloudGray)
              : RenewdColors.oceanBlue,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isAdmin ? 4 : 16),
            bottomRight: Radius.circular(isAdmin ? 16 : 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: isAdmin ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isAdmin) ...[
                  Icon(LucideIcons.headphones, size: 12, color: RenewdColors.oceanBlue),
                  const SizedBox(width: 4),
                ],
                Text(
                  isAdmin ? 'Support Team' : 'You',
                  style: RenewdTextStyles.caption.copyWith(
                    color: isAdmin ? RenewdColors.oceanBlue : Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              reply['message'] as String,
              style: RenewdTextStyles.bodySmall.copyWith(
                color: isAdmin ? null : Colors.white,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(reply['created_at'] as String?),
              style: RenewdTextStyles.caption.copyWith(
                color: isAdmin
                    ? RenewdColors.slate
                    : Colors.white.withValues(alpha: RenewdOpacity.half),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
