import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/category_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
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
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Get.back(),
        ),
        title: const Text('Edit Renewal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(MinderSpacing.lg),
        child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Name *'),
                const SizedBox(height: MinderSpacing.sm),
                TextFormField(
                  initialValue: c.name.value,
                  onChanged: (v) => c.name.value = v,
                  decoration:
                      const InputDecoration(hintText: 'e.g. Netflix, LIC Policy'),
                ),
                const SizedBox(height: MinderSpacing.xl),
                _buildLabel('Category'),
                const SizedBox(height: MinderSpacing.sm),
                _buildCategoryChips(c),
                const SizedBox(height: MinderSpacing.xl),
                _buildLabel('Provider'),
                const SizedBox(height: MinderSpacing.sm),
                TextFormField(
                  initialValue: c.providerName.value,
                  onChanged: (v) => c.providerName.value = v,
                  decoration: const InputDecoration(hintText: 'e.g. Netflix Inc.'),
                ),
                const SizedBox(height: MinderSpacing.xl),
                _buildLabel('Amount'),
                const SizedBox(height: MinderSpacing.sm),
                TextFormField(
                  initialValue: c.amount.value?.toStringAsFixed(2) ?? '',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => c.amount.value = double.tryParse(v),
                  decoration:
                      const InputDecoration(prefixText: '₹ ', hintText: '0.00'),
                ),
                const SizedBox(height: MinderSpacing.xl),
                _buildLabel('Renewal Date *'),
                const SizedBox(height: MinderSpacing.sm),
                _buildDateField(context, c),
                const SizedBox(height: MinderSpacing.xl),
                _buildLabel('Frequency'),
                const SizedBox(height: MinderSpacing.sm),
                _buildFrequencyDropdown(c),
                if (c.isCustomFrequency) ...[
                  const SizedBox(height: MinderSpacing.md),
                  TextFormField(
                    initialValue: c.frequencyDays.value.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        c.frequencyDays.value = int.tryParse(v) ?? 30,
                    decoration: const InputDecoration(
                        labelText: 'Every N days', hintText: '30'),
                  ),
                ],
                const SizedBox(height: MinderSpacing.xl),
                _buildAutoRenewRow(c),
                const SizedBox(height: MinderSpacing.xl),
                _buildLabel('Notes'),
                const SizedBox(height: MinderSpacing.sm),
                TextFormField(
                  initialValue: c.notes.value,
                  onChanged: (v) => c.notes.value = v,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      hintText: 'Any additional details...'),
                ),
                const SizedBox(height: MinderSpacing.xxl),
                MinderButton(
                  label: 'Save Changes',
                  icon: Iconsax.tick_circle,
                  isLoading: c.isLoading.value,
                  onPressed: c.save,
                ),
                const SizedBox(height: MinderSpacing.xl),
              ],
            )),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: MinderTextStyles.bodySmall.copyWith(color: MinderColors.slate));
  }

  Widget _buildCategoryChips(EditRenewalController c) {
    return Wrap(
      spacing: MinderSpacing.sm,
      runSpacing: MinderSpacing.sm,
      children: RenewalCategory.values.map((cat) {
        final isSelected = c.category.value == cat;
        final color = CategoryConfig.color(cat);
        return GestureDetector(
          onTap: () => c.category.value = cat,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
                horizontal: MinderSpacing.md, vertical: MinderSpacing.sm),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.2)
                  : MinderColors.darkSlate,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : MinderColors.steel,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CategoryConfig.icon(cat),
                    size: 14,
                    color: isSelected ? color : MinderColors.slate),
                const SizedBox(width: MinderSpacing.xs),
                Text(CategoryConfig.label(cat),
                    style: MinderTextStyles.caption.copyWith(
                        color: isSelected ? color : MinderColors.slate)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateField(BuildContext context, EditRenewalController c) {
    return GestureDetector(
      onTap: () => _pickDate(context, c),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: MinderSpacing.lg, vertical: MinderSpacing.md),
        decoration: BoxDecoration(
          color: MinderColors.darkSlate,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MinderColors.steel),
        ),
        child: Row(
          children: [
            const Icon(Iconsax.calendar, size: 18, color: MinderColors.slate),
            const SizedBox(width: MinderSpacing.sm),
            Text(
              c.renewalDate.value != null
                  ? MinderDateUtils.formatDate(c.renewalDate.value!)
                  : 'Select date',
              style: MinderTextStyles.body.copyWith(
                  color: c.renewalDate.value != null
                      ? null
                      : MinderColors.slate),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyDropdown(EditRenewalController c) {
    return DropdownButtonFormField<String>(
      value: c.frequency.value,
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
            Text('Auto-renew', style: MinderTextStyles.body),
            Text('Automatically tracks the next cycle',
                style: MinderTextStyles.caption
                    .copyWith(color: MinderColors.slate)),
          ],
        ),
        Switch(
          value: c.autoRenew.value,
          onChanged: (v) => c.autoRenew.value = v,
          activeThumbColor: MinderColors.oceanBlue,
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
