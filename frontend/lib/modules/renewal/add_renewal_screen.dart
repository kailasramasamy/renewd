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
import '../../core/widgets/currency_converter.dart';
import '../../core/utils/haptics.dart';
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
          icon: Icon(LucideIcons.arrowLeft),
          tooltip: 'Go back',
          onPressed: () => Get.back(),
        ),
        title: const Text('Add Renewal'),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(RenewdSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NameField(c: c),
            const SizedBox(height: RenewdSpacing.xl),
            _CategorySection(c: c),
            const SizedBox(height: RenewdSpacing.xl),
            _GroupSection(c: c),
            const SizedBox(height: RenewdSpacing.xl),
            _ProviderField(c: c),
            const SizedBox(height: RenewdSpacing.xl),
            _AmountField(c: c),
            const SizedBox(height: RenewdSpacing.xl),
            _DateField(c: c),
            const SizedBox(height: RenewdSpacing.xl),
            _FrequencySection(c: c),
            const SizedBox(height: RenewdSpacing.xl),
            _AutoRenewToggle(c: c),
            const SizedBox(height: RenewdSpacing.xl),
            _NotesField(c: c),
            const SizedBox(height: RenewdSpacing.xxl),
            Obx(() => RenewdButton(
                  label: 'Save Renewal',
                  icon: LucideIcons.checkCircle,
                  isLoading: c.isLoading.value,
                  onPressed: () {
                    RenewdHaptics.success();
                    c.save();
                  },
                )),
            const SizedBox(height: RenewdSpacing.xl),
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
        Text('Name *', style: RenewdTextStyles.bodySmall.copyWith(
            color: RenewdColors.slate)),
        const SizedBox(height: RenewdSpacing.sm),
        TextField(
          textCapitalization: TextCapitalization.sentences,
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
        Text('Category', style: RenewdTextStyles.bodySmall.copyWith(
            color: RenewdColors.slate)),
        const SizedBox(height: RenewdSpacing.sm),
        Obx(() => Wrap(
              spacing: RenewdSpacing.sm,
              runSpacing: RenewdSpacing.sm,
              children: RenewalCategory.values.map((cat) {
                final isSelected = c.category.value == cat;
                final color = CategoryConfig.color(cat);
                return GestureDetector(
                  onTap: () {
                    RenewdHaptics.selection();
                    c.category.value = cat;
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: RenewdSpacing.md, vertical: RenewdSpacing.sm),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: RenewdOpacity.medium)
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
        Text('Provider', style: RenewdTextStyles.bodySmall.copyWith(
            color: RenewdColors.slate)),
        const SizedBox(height: RenewdSpacing.sm),
        TextField(
          textCapitalization: TextCapitalization.sentences,
          onChanged: (v) => c.providerName.value = v,
          decoration: const InputDecoration(hintText: 'e.g. Netflix Inc.'),
        ),
      ],
    );
  }
}

class _AmountField extends StatefulWidget {
  final AddRenewalController c;
  const _AmountField({required this.c});

  @override
  State<_AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<_AmountField> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      widget.c.amount.value = double.tryParse(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amount', style: RenewdTextStyles.bodySmall.copyWith(
            color: RenewdColors.slate)),
        const SizedBox(height: RenewdSpacing.sm),
        TextField(
          controller: _controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
              prefixText: '${RenewdCurrency.symbol} ', hintText: '0.00'),
        ),
        CurrencyConverter(amountController: _controller),
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
        Text('Renewal Date *', style: RenewdTextStyles.bodySmall.copyWith(
            color: RenewdColors.slate)),
        const SizedBox(height: RenewdSpacing.sm),
        Obx(() => GestureDetector(
              onTap: () => _pickDate(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: RenewdSpacing.lg, vertical: RenewdSpacing.md),
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
            Text('Frequency', style: RenewdTextStyles.bodySmall.copyWith(
                color: RenewdColors.slate)),
            const SizedBox(height: RenewdSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: c.frequency.value,
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
              const SizedBox(height: RenewdSpacing.md),
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
                    style: RenewdTextStyles.body),
                Text('Automatically tracks the next cycle',
                    style: RenewdTextStyles.caption.copyWith(
                        color: RenewdColors.slate)),
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

class _GroupSection extends StatefulWidget {
  final AddRenewalController c;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subcategory', style: RenewdTextStyles.bodySmall.copyWith(
            color: RenewdColors.slate)),
        const SizedBox(height: RenewdSpacing.sm),
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
                          : RenewdColors.darkSlate,
                      borderRadius: RenewdRadius.pillAll,
                      border: Border.all(
                        color: isSelected ? catColor : RenewdColors.steel,
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

class _NotesField extends StatelessWidget {
  final AddRenewalController c;
  const _NotesField({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notes', style: RenewdTextStyles.bodySmall.copyWith(
            color: RenewdColors.slate)),
        const SizedBox(height: RenewdSpacing.sm),
        TextField(
          textCapitalization: TextCapitalization.sentences,
          onChanged: (v) => c.notes.value = v,
          maxLines: 3,
          decoration: const InputDecoration(
              hintText: 'Any additional details...'),
        ),
      ],
    );
  }
}
