import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

enum StatusType { safe, warning, urgent, critical }

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType status;

  const StatusBadge({
    super.key,
    required this.label,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorForStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: RenewdTextStyles.caption.copyWith(color: color),
      ),
    );
  }

  Color _colorForStatus(StatusType status) {
    switch (status) {
      case StatusType.safe:
        return RenewdColors.emerald;
      case StatusType.warning:
        return RenewdColors.amber;
      case StatusType.urgent:
        return RenewdColors.tangerine;
      case StatusType.critical:
        return RenewdColors.coralRed;
    }
  }
}
