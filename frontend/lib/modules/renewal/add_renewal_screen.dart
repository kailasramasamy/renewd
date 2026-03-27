import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/category_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../widgets/minder_button.dart';
import 'add_renewal_controller.dart';

class AddRenewalScreen extends StatelessWidget {
  const AddRenewalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AddRenewalController());
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Get.back(),
        ),
        title: const Text('Add Renewal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(MinderSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NameField(c: c),
            const SizedBox(height: MinderSpacing.xl),
            _CategorySection(c: c),
            const SizedBox(height: MinderSpacing.xl),
            _ProviderField(c: c),
            const SizedBox(height: MinderSpacing.xl),
            _AmountField(c: c),
            const SizedBox(height: MinderSpacing.xl),
            _DateField(c: c),
            const SizedBox(height: MinderSpacing.xl),
            _FrequencySection(c: c),
            const SizedBox(height: MinderSpacing.xl),
            _AutoRenewToggle(c: c),
            const SizedBox(height: MinderSpacing.xl),
            _NotesField(c: c),
            const SizedBox(height: MinderSpacing.xxl),
            Obx(() => MinderButton(
                  label: 'Save Renewal',
                  icon: Iconsax.tick_circle,
                  isLoading: c.isLoading.value,
                  onPressed: c.save,
                )),
            const SizedBox(height: MinderSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  final AddRenewalController c;
  const _NameField({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Name *', style: MinderTextStyles.bodySmall.copyWith(
            color: MinderColors.slate)),
        const SizedBox(height: MinderSpacing.sm),
        TextField(
          onChanged: (v) => c.name.value = v,
          decoration: const InputDecoration(hintText: 'e.g. Netflix, LIC Policy'),
        ),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  final AddRenewalController c;
  const _CategorySection({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: MinderTextStyles.bodySmall.copyWith(
            color: MinderColors.slate)),
        const SizedBox(height: MinderSpacing.sm),
        Obx(() => Wrap(
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
            )),
      ],
    );
  }
}

class _ProviderField extends StatelessWidget {
  final AddRenewalController c;
  const _ProviderField({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Provider', style: MinderTextStyles.bodySmall.copyWith(
            color: MinderColors.slate)),
        const SizedBox(height: MinderSpacing.sm),
        TextField(
          onChanged: (v) => c.providerName.value = v,
          decoration: const InputDecoration(hintText: 'e.g. Netflix Inc.'),
        ),
      ],
    );
  }
}

class _AmountField extends StatelessWidget {
  final AddRenewalController c;
  const _AmountField({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amount', style: MinderTextStyles.bodySmall.copyWith(
            color: MinderColors.slate)),
        const SizedBox(height: MinderSpacing.sm),
        TextField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (v) => c.amount.value = double.tryParse(v),
          decoration: const InputDecoration(
              prefixText: '₹ ', hintText: '0.00'),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final AddRenewalController c;
  const _DateField({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Renewal Date *', style: MinderTextStyles.bodySmall.copyWith(
            color: MinderColors.slate)),
        const SizedBox(height: MinderSpacing.sm),
        Obx(() => GestureDetector(
              onTap: () => _pickDate(context),
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
                    Icon(Iconsax.calendar,
                        size: 18, color: MinderColors.slate),
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
            )),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: c.renewalDate.value ?? tomorrow,
      firstDate: tomorrow,
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) c.renewalDate.value = picked;
  }
}

class _FrequencySection extends StatelessWidget {
  final AddRenewalController c;
  const _FrequencySection({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Frequency', style: MinderTextStyles.bodySmall.copyWith(
                color: MinderColors.slate)),
            const SizedBox(height: MinderSpacing.sm),
            DropdownButtonFormField<String>(
              value: c.frequency.value,
              decoration: const InputDecoration(),
              items: AddRenewalController.frequencies.map((f) {
                return DropdownMenuItem(
                  value: f,
                  child: Text(AddRenewalController.frequencyLabels[f] ?? f),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) c.frequency.value = v;
              },
            ),
            if (c.isCustomFrequency) ...[
              const SizedBox(height: MinderSpacing.md),
              TextFormField(
                keyboardType: TextInputType.number,
                initialValue: c.frequencyDays.value.toString(),
                onChanged: (v) =>
                    c.frequencyDays.value = int.tryParse(v) ?? 30,
                decoration: const InputDecoration(
                    labelText: 'Every N days', hintText: '30'),
              ),
            ],
          ],
        ));
  }
}

class _AutoRenewToggle extends StatelessWidget {
  final AddRenewalController c;
  const _AutoRenewToggle({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Auto-renew',
                    style: MinderTextStyles.body),
                Text('Automatically tracks the next cycle',
                    style: MinderTextStyles.caption.copyWith(
                        color: MinderColors.slate)),
              ],
            ),
            Switch(
              value: c.autoRenew.value,
              onChanged: (v) => c.autoRenew.value = v,
              activeThumbColor: MinderColors.oceanBlue,
            ),
          ],
        ));
  }
}

class _NotesField extends StatelessWidget {
  final AddRenewalController c;
  const _NotesField({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notes', style: MinderTextStyles.bodySmall.copyWith(
            color: MinderColors.slate)),
        const SizedBox(height: MinderSpacing.sm),
        TextField(
          onChanged: (v) => c.notes.value = v,
          maxLines: 3,
          decoration: const InputDecoration(
              hintText: 'Any additional details...'),
        ),
      ],
    );
  }
}
