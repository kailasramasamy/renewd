import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class RenewdFormLabel extends StatelessWidget {
  final String label;
  final bool required;

  const RenewdFormLabel({
    super.key,
    required this.label,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: RenewdTextStyles.bodySmall
                .copyWith(color: RenewdColors.slate)),
        if (required)
          Text(' *',
              style: RenewdTextStyles.bodySmall
                  .copyWith(color: RenewdColors.coralRed)),
      ],
    );
  }
}
