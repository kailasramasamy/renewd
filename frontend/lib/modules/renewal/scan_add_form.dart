import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/category_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import 'scan_add_controller.dart';

class ScanAddForm extends StatelessWidget {
  final ScanAddController c;
  const ScanAddForm({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ScanNameField(c: c),
        const SizedBox(height: RenewdSpacing.xl),
        _ScanCategorySection(c: c),
        const SizedBox(height: RenewdSpacing.xl),
        _ScanProviderField(c: c),
        const SizedBox(height: RenewdSpacing.xl),
        _ScanAmountField(c: c),
        const SizedBox(height: RenewdSpacing.xl),
        _ScanDateField(c: c),
        const SizedBox(height: RenewdSpacing.xl),
        _ScanFrequencySection(c: c),
        const SizedBox(height: RenewdSpacing.xl),
        _ScanAutoRenewToggle(c: c),
        const SizedBox(height: RenewdSpacing.xl),
        _ScanNotesField(c: c),
      ],
    );
  }
}

class _ScanNameField extends StatefulWidget {
  final ScanAddController c;
  const _ScanNameField({required this.c});

  @override
  State<_ScanNameField> createState() => _ScanNameFieldState();
}

class _ScanNameFieldState extends State<_ScanNameField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.c.name.value);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Name *',
            style: RenewdTextStyles.bodySmall
                .copyWith(color: RenewdColors.slate)),
        const SizedBox(height: RenewdSpacing.sm),
        TextField(
          controller: _ctrl,
          onChanged: (v) => widget.c.name.value = v,
          decoration:
              const InputDecoration(hintText: 'e.g. HDFC ERGO Car Policy'),
        ),
      ],
    );
  }
}

class _ScanCategorySection extends StatelessWidget {
  final ScanAddController c;
  const _ScanCategorySection({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category',
            style: RenewdTextStyles.bodySmall
                .copyWith(color: RenewdColors.slate)),
        const SizedBox(height: RenewdSpacing.sm),
        Obx(() => Wrap(
              spacing: RenewdSpacing.sm,
              runSpacing: RenewdSpacing.sm,
              children: RenewalCategory.values.map((cat) {
                final isSelected = c.category.value == cat;
                final color = CategoryConfig.color(cat);
                return GestureDetector(
                  onTap: () => c.category.value = cat,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: RenewdSpacing.md,
                        vertical: RenewdSpacing.sm),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.2)
                          : RenewdColors.darkSlate,
                      borderRadius: RenewdRadius.pillAll,
                      border: Border.all(
                        color: isSelected ? color : RenewdColors.steel,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CategoryConfig.icon(cat),
                            size: 14,
                            color:
                                isSelected ? color : RenewdColors.slate),
                        const SizedBox(width: RenewdSpacing.xs),
                        Text(CategoryConfig.label(cat),
                            style: RenewdTextStyles.caption.copyWith(
                                color: isSelected
                                    ? color
                                    : RenewdColors.slate)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }
}

class _ScanGroupSection extends StatefulWidget {
  final ScanAddController c;
  const _ScanGroupSection({required this.c});

  @override
  State<_ScanGroupSection> createState() => _ScanGroupSectionState();
}

class _ScanGroupSectionState extends State<_ScanGroupSection> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.c.groupName.value);
    ever(widget.c.groupName, (v) {
      if (_ctrl.text != v) _ctrl.text = v;
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _selectChip(String g) {
    final newVal = widget.c.groupName.value == g ? '' : g;
    widget.c.groupName.value = newVal;
    _ctrl.text = newVal;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Group',
            style: RenewdTextStyles.bodySmall
                .copyWith(color: RenewdColors.slate)),
        const SizedBox(height: RenewdSpacing.sm),
        Obx(() {
          final suggestions = widget.c.suggestedGroups;
          final catColor = CategoryConfig.color(widget.c.category.value);
          if (suggestions.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: RenewdSpacing.sm),
            child: Wrap(
              spacing: RenewdSpacing.sm,
              runSpacing: RenewdSpacing.sm,
              children: suggestions.map((g) {
                final isSelected = widget.c.groupName.value == g;
                return GestureDetector(
                  onTap: () => _selectChip(g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: RenewdSpacing.md,
                        vertical: RenewdSpacing.sm),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? catColor.withValues(alpha: 0.2)
                          : RenewdColors.darkSlate,
                      borderRadius: RenewdRadius.pillAll,
                      border: Border.all(
                        color: isSelected ? catColor : RenewdColors.steel,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(g,
                        style: RenewdTextStyles.caption.copyWith(
                            color: isSelected
                                ? catColor
                                : RenewdColors.slate)),
                  ),
                );
              }).toList(),
            ),
          );
        }),
        TextField(
          controller: _ctrl,
          onChanged: (v) => widget.c.groupName.value = v,
          decoration:
              const InputDecoration(hintText: 'Or type a custom group...'),
        ),
      ],
    );
  }
}

class _ScanProviderField extends StatefulWidget {
  final ScanAddController c;
  const _ScanProviderField({required this.c});

  @override
  State<_ScanProviderField> createState() => _ScanProviderFieldState();
}

class _ScanProviderFieldState extends State<_ScanProviderField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.c.providerName.value);
    ever(widget.c.providerName, (v) {
      if (_ctrl.text != v) _ctrl.text = v;
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Provider',
            style: RenewdTextStyles.bodySmall
                .copyWith(color: RenewdColors.slate)),
        const SizedBox(height: RenewdSpacing.sm),
        TextField(
          controller: _ctrl,
          onChanged: (v) => widget.c.providerName.value = v,
          decoration:
              const InputDecoration(hintText: 'e.g. HDFC ERGO'),
        ),
      ],
    );
  }
}

class _ScanAmountField extends StatefulWidget {
  final ScanAddController c;
  const _ScanAmountField({required this.c});

  @override
  State<_ScanAmountField> createState() => _ScanAmountFieldState();
}

class _ScanAmountFieldState extends State<_ScanAmountField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final initial = widget.c.amount.value?.toString() ?? '';
    _ctrl = TextEditingController(text: initial);
    ever(widget.c.amount, (v) {
      final text = v?.toString() ?? '';
      if (_ctrl.text != text) _ctrl.text = text;
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amount',
            style: RenewdTextStyles.bodySmall
                .copyWith(color: RenewdColors.slate)),
        const SizedBox(height: RenewdSpacing.sm),
        TextField(
          controller: _ctrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          onChanged: (v) => widget.c.amount.value = double.tryParse(v),
          decoration:
              const InputDecoration(prefixText: '₹ ', hintText: '0.00'),
        ),
      ],
    );
  }
}

class _ScanDateField extends StatelessWidget {
  final ScanAddController c;
  const _ScanDateField({required this.c});

  Future<void> _pickDate(BuildContext context) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: c.renewalDate.value ?? tomorrow,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
    );
    if (picked != null) c.renewalDate.value = picked;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Renewal Date *',
            style: RenewdTextStyles.bodySmall
                .copyWith(color: RenewdColors.slate)),
        const SizedBox(height: RenewdSpacing.sm),
        Obx(() => GestureDetector(
              onTap: () => _pickDate(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: RenewdSpacing.lg,
                    vertical: RenewdSpacing.md),
                decoration: BoxDecoration(
                  color: RenewdColors.darkSlate,
                  borderRadius: RenewdRadius.mdAll,
                  border: Border.all(color: RenewdColors.steel),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.calendar,
                        size: 18, color: RenewdColors.slate),
                    const SizedBox(width: RenewdSpacing.sm),
                    Text(
                      c.renewalDate.value != null
                          ? RenewdDateUtils.formatDate(c.renewalDate.value!)
                          : 'Select date',
                      style: RenewdTextStyles.body.copyWith(
                          color: c.renewalDate.value != null
                              ? null
                              : RenewdColors.slate),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _ScanFrequencySection extends StatelessWidget {
  final ScanAddController c;
  const _ScanFrequencySection({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Frequency',
                style: RenewdTextStyles.bodySmall
                    .copyWith(color: RenewdColors.slate)),
            const SizedBox(height: RenewdSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: c.frequency.value,
              decoration: const InputDecoration(),
              items: ScanAddController.frequencies.map((f) {
                return DropdownMenuItem(
                  value: f,
                  child: Text(
                      ScanAddController.frequencyLabels[f] ?? f),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) c.frequency.value = v;
              },
            ),
          ],
        ));
  }
}

class _ScanAutoRenewToggle extends StatelessWidget {
  final ScanAddController c;
  const _ScanAutoRenewToggle({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Auto-renew', style: RenewdTextStyles.body),
                Text('Automatically tracks the next cycle',
                    style: RenewdTextStyles.caption
                        .copyWith(color: RenewdColors.slate)),
              ],
            ),
            Switch(
              value: c.autoRenew.value,
              onChanged: (v) => c.autoRenew.value = v,
              activeThumbColor: RenewdColors.oceanBlue,
            ),
          ],
        ));
  }
}

class _ScanNotesField extends StatefulWidget {
  final ScanAddController c;
  const _ScanNotesField({required this.c});

  @override
  State<_ScanNotesField> createState() => _ScanNotesFieldState();
}

class _ScanNotesFieldState extends State<_ScanNotesField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.c.notes.value);
    ever(widget.c.notes, (v) {
      if (_ctrl.text != v) _ctrl.text = v;
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notes',
            style: RenewdTextStyles.bodySmall
                .copyWith(color: RenewdColors.slate)),
        const SizedBox(height: RenewdSpacing.sm),
        TextField(
          controller: _ctrl,
          onChanged: (v) => widget.c.notes.value = v,
          maxLines: 3,
          decoration:
              const InputDecoration(hintText: 'Any additional details...'),
        ),
      ],
    );
  }
}
