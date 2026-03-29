import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/category_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_opacity.dart';
import '../../core/utils/currency.dart';
import '../../core/utils/date_utils.dart';
import '../../widgets/minder_button.dart';
import 'edit_renewal_controller.dart';

class EditRenewalScreen extends StatelessWidget {
  const EditRenewalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(EditRenewalController());
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => Get.back(),
        ),
        title: const Text('Edit Renewal'),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(RenewdSpacing.lg),
        child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Name *'),
                const SizedBox(height: RenewdSpacing.sm),
                TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  initialValue: c.name.value,
                  onChanged: (v) => c.name.value = v,
                  decoration:
                      const InputDecoration(hintText: 'e.g. Netflix, LIC Policy'),
                ),
                const SizedBox(height: RenewdSpacing.xl),
                _buildLabel('Category'),
                const SizedBox(height: RenewdSpacing.sm),
                _buildCategoryChips(context, c),
                const SizedBox(height: RenewdSpacing.xl),
                _buildLabel('Subcategory'),
                const SizedBox(height: RenewdSpacing.sm),
                _GroupSection(c: c),
                const SizedBox(height: RenewdSpacing.xl),
                _buildLabel('Provider'),
                const SizedBox(height: RenewdSpacing.sm),
                TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  initialValue: c.providerName.value,
                  onChanged: (v) => c.providerName.value = v,
                  decoration: const InputDecoration(hintText: 'e.g. Netflix Inc.'),
                ),
                const SizedBox(height: RenewdSpacing.xl),
                _buildLabel('Amount'),
                const SizedBox(height: RenewdSpacing.sm),
                TextFormField(
                  initialValue: c.amount.value?.toStringAsFixed(2) ?? '',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => c.amount.value = double.tryParse(v),
                  decoration:
                      InputDecoration(prefixText: '${RenewdCurrency.symbol} ', hintText: '0.00'),
                ),
                const SizedBox(height: RenewdSpacing.xl),
                _buildLabel('Renewal Date *'),
                const SizedBox(height: RenewdSpacing.sm),
                _buildDateField(context, c),
                const SizedBox(height: RenewdSpacing.xl),
                _buildLabel('Frequency'),
                const SizedBox(height: RenewdSpacing.sm),
                _buildFrequencyDropdown(c),
                if (c.isCustomFrequency) ...[
                  const SizedBox(height: RenewdSpacing.md),
                  TextFormField(
                    initialValue: c.frequencyDays.value.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        c.frequencyDays.value = int.tryParse(v) ?? 30,
                    decoration: const InputDecoration(
                        labelText: 'Every N days', hintText: '30'),
                  ),
                ],
                const SizedBox(height: RenewdSpacing.xl),
                _buildAutoRenewRow(c),
                const SizedBox(height: RenewdSpacing.xl),
                _buildLabel('Notes'),
                const SizedBox(height: RenewdSpacing.sm),
                TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  initialValue: c.notes.value,
                  onChanged: (v) => c.notes.value = v,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      hintText: 'Any additional details...'),
                ),
                const SizedBox(height: RenewdSpacing.xxl),
                RenewdButton(
                  label: 'Save Changes',
                  icon: LucideIcons.checkCircle,
                  isLoading: c.isLoading.value,
                  onPressed: c.save,
                ),
                const SizedBox(height: RenewdSpacing.xl),
              ],
            )),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: RenewdTextStyles.bodySmall.copyWith(color: RenewdColors.slate));
  }

  Widget _buildCategoryChips(BuildContext context, EditRenewalController c) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Wrap(
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
                horizontal: RenewdSpacing.md, vertical: RenewdSpacing.sm),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: RenewdOpacity.medium)
                  : isDark ? RenewdColors.darkSlate : RenewdColors.cloudGray,
              borderRadius: RenewdRadius.pillAll,
              border: Border.all(
                color: isSelected ? color : isDark ? RenewdColors.steel : RenewdColors.silver,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CategoryConfig.icon(cat),
                    size: 14,
                    color: isSelected ? color : RenewdColors.slate),
                const SizedBox(width: RenewdSpacing.xs),
                Text(CategoryConfig.label(cat),
                    style: RenewdTextStyles.caption.copyWith(
                        color: isSelected ? color : RenewdColors.slate)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateField(BuildContext context, EditRenewalController c) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _pickDate(context, c),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: RenewdSpacing.lg, vertical: RenewdSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? RenewdColors.darkSlate : RenewdColors.cloudGray,
          borderRadius: RenewdRadius.mdAll,
          border: Border.all(color: isDark ? RenewdColors.steel : RenewdColors.silver),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.calendar, size: 18, color: RenewdColors.slate),
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
    );
  }

  Widget _buildFrequencyDropdown(EditRenewalController c) {
    return DropdownButtonFormField<String>(
      initialValue: c.frequency.value,
      decoration: const InputDecoration(),
      items: EditRenewalController.frequencyLabels.entries.map((e) {
        return DropdownMenuItem(value: e.key, child: Text(e.value));
      }).toList(),
      onChanged: (v) {
        if (v != null) c.frequency.value = v;
      },
    );
  }

  Widget _buildAutoRenewRow(EditRenewalController c) {
    return Row(
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
    );
  }

  Future<void> _pickDate(BuildContext context, EditRenewalController c) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: c.renewalDate.value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) c.renewalDate.value = picked;
  }
}

class _GroupSection extends StatefulWidget {
  final EditRenewalController c;
  const _GroupSection({required this.c});

  @override
  State<_GroupSection> createState() => _GroupSectionState();
}

class _GroupSectionState extends State<_GroupSection> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.c.groupName.value);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _selectChip(String g) {
    final isSelected = widget.c.groupName.value == g;
    final newVal = isSelected ? '' : g;
    widget.c.groupName.value = newVal;
    _textController.text = newVal;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final suggestions = widget.c.suggestedSubcategories;
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
                          ? catColor.withValues(alpha: RenewdOpacity.medium)
                          : isDark ? RenewdColors.darkSlate : RenewdColors.cloudGray,
                      borderRadius: RenewdRadius.pillAll,
                      border: Border.all(
                        color: isSelected ? catColor : isDark ? RenewdColors.steel : RenewdColors.silver,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(g,
                        style: RenewdTextStyles.caption.copyWith(
                            color: isSelected ? catColor : RenewdColors.slate)),
                  ),
                );
              }).toList(),
            ),
          );
        }),
        TextField(
          textCapitalization: TextCapitalization.sentences,
          controller: _textController,
          onChanged: (v) => widget.c.groupName.value = v,
          decoration: const InputDecoration(
              hintText: 'Or type a custom subcategory...'),
        ),
      ],
    );
  }
}
