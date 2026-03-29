import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/utils/document_picker.dart' show imagesToPdf;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_opacity.dart';
import '../../widgets/minder_button.dart';
import 'scan_add_controller.dart';
import 'scan_add_form.dart';

class ScanAddScreen extends StatefulWidget {
  const ScanAddScreen({super.key});

  @override
  State<ScanAddScreen> createState() => _ScanAddScreenState();
}

class _ScanAddScreenState extends State<ScanAddScreen> {
  late final ScanAddController c;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    c = Get.put(ScanAddController());
    WidgetsBinding.instance.addPostFrameCallback((_) => _startIfNeeded());
  }

  void _startIfNeeded() {
    if (_started) return;
    final args = Get.arguments as Map<String, dynamic>?;
    final filePath = args?['filePath'] as String?;
    final fileName = args?['fileName'] as String?;
    if (filePath != null && fileName != null) {
      _started = true;
      c.uploadAndParse(filePath, fileName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isAnalyzing) {
        return _AnalyzingScreen(c: c);
      }
      if (c.extraction.value != null) {
        return _ReviewFormScreen(c: c);
      }
      return _PickerScreen(c: c);
    });
  }
}

class _PickerScreen extends StatelessWidget {
  final ScanAddController c;
  const _PickerScreen({required this.c});

  Future<void> _scanDocument(BuildContext context) async {
    try {
      final result = await FlutterDocScanner().getScannedDocumentAsImages(page: 10);
      if (result == null || result.images.isEmpty) return;
      final pdf = await imagesToPdf(result.images, 'Scan');
      await c.uploadAndParse(pdf.path, pdf.name);
    } on PlatformException catch (_) {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (file == null) return;
      final pdf = await imagesToPdf([file.path], 'Scan');
      await c.uploadAndParse(pdf.path, pdf.name);
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    final pdf = await imagesToPdf([file.path], 'Photo');
    await c.uploadAndParse(pdf.path, pdf.name);
  }

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.path == null) return;

    final ext = file.extension?.toLowerCase() ?? '';
    const allowed = ['pdf', 'jpg', 'jpeg', 'png', 'webp'];
    if (!allowed.contains(ext)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a PDF or image file')),
        );
      }
      return;
    }

    await c.uploadAndParse(file.path!, file.name);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => Get.back(),
        ),
        title: Text('Scan Document',
            style: RenewdTextStyles.h3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(RenewdSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(LucideIcons.uploadCloud,
                size: 64, color: RenewdColors.lavender),
            const SizedBox(height: RenewdSpacing.xl),
            Text(
              'Upload a document',
              style: RenewdTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: RenewdSpacing.sm),
            Text(
              'Insurance policy, bill, license — AI will extract details automatically',
              style: RenewdTextStyles.bodySmall
                  .copyWith(color: RenewdColors.slate),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: RenewdSpacing.xxl),
            _PickerOption(
              icon: LucideIcons.scanLine,
              label: 'Scan Document',
              onTap: () => _scanDocument(context),
            ),
            const SizedBox(height: RenewdSpacing.md),
            _PickerOption(
              icon: LucideIcons.image,
              label: 'Photo Library',
              onTap: () => _pickFromGallery(context),
            ),
            const SizedBox(height: RenewdSpacing.md),
            _PickerOption(
              icon: LucideIcons.folderOpen,
              label: 'Browse Files',
              onTap: () => _pickFile(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(RenewdSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? RenewdColors.darkSlate : RenewdColors.mist,
          borderRadius: RenewdRadius.xlAll,
          border: Border.all(
            color: isDark ? RenewdColors.steel : RenewdColors.silver,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: RenewdColors.lavender, size: 24),
            const SizedBox(width: RenewdSpacing.md),
            Text(label,
                style: RenewdTextStyles.body.copyWith(
                  color: isDark ? Colors.white : RenewdColors.deepNavy,
                )),
            const Spacer(),
            Icon(LucideIcons.chevronRight,
                color: RenewdColors.slate, size: 18),
          ],
        ),
      ),
    );
  }
}

class _AnalyzingScreen extends StatelessWidget {
  final ScanAddController c;
  const _AnalyzingScreen({required this.c});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(RenewdSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark ? RenewdColors.darkSlate : RenewdColors.mist,
                    borderRadius: RenewdRadius.xlAll,
                    border: Border.all(
                      color: isDark ? RenewdColors.steel : RenewdColors.silver,
                    ),
                  ),
                  child: Icon(LucideIcons.fileText,
                      size: 36, color: RenewdColors.lavender),
                ),
                const SizedBox(height: RenewdSpacing.xl),
                Text(
                  'Analyzing your document...',
                  style: RenewdTextStyles.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: RenewdSpacing.xl),
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: RenewdColors.lavender,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: RenewdSpacing.xl),
                Obx(() => Text(
                      c.analyzeStep.value,
                      style: RenewdTextStyles.body
                          .copyWith(color: RenewdColors.silver),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewFormScreen extends StatelessWidget {
  final ScanAddController c;
  const _ReviewFormScreen({required this.c});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => Get.back(),
        ),
        title: const Text('Review Details'),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(RenewdSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AiBanner(),
            const SizedBox(height: RenewdSpacing.lg),
            if (c.keyDetails.isNotEmpty) ...[
              _KeyDetailsChips(c: c),
              const SizedBox(height: RenewdSpacing.xl),
            ],
            ScanAddForm(c: c),
            const SizedBox(height: RenewdSpacing.xxl),
            Obx(() => RenewdButton(
                  label: 'Create Renewal',
                  icon: LucideIcons.checkCircle,
                  isLoading: c.isSaving.value,
                  onPressed: c.save,
                )),
            const SizedBox(height: RenewdSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _AiBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(RenewdSpacing.md),
      decoration: BoxDecoration(
        color: RenewdColors.lavender.withValues(alpha: RenewdOpacity.light),
        borderRadius: RenewdRadius.mdAll,
        border: Border.all(color: RenewdColors.lavender.withValues(alpha: RenewdOpacity.moderate)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome,
              color: RenewdColors.lavender, size: 20),
          const SizedBox(width: RenewdSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI extracted these details',
                    style: RenewdTextStyles.bodySmall.copyWith(
                        color: RenewdColors.lavender,
                        fontWeight: FontWeight.w600)),
                Text('Please review before saving',
                    style: RenewdTextStyles.caption
                        .copyWith(color: RenewdColors.lavender)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyDetailsChips extends StatelessWidget {
  final ScanAddController c;
  const _KeyDetailsChips({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Key Details',
            style:
                RenewdTextStyles.bodySmall.copyWith(color: RenewdColors.slate)),
        const SizedBox(height: RenewdSpacing.sm),
        Obx(() => Wrap(
              spacing: RenewdSpacing.sm,
              runSpacing: RenewdSpacing.sm,
              children: c.keyDetails
                  .map((d) => _DetailChip(label: d))
                  .toList(),
            )),
      ],
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  const _DetailChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: RenewdSpacing.md, vertical: RenewdSpacing.xs),
      decoration: BoxDecoration(
        color: isDark ? RenewdColors.darkSlate : RenewdColors.mist,
        borderRadius: RenewdRadius.pillAll,
        border: Border.all(
          color: isDark ? RenewdColors.steel : RenewdColors.silver,
        ),
      ),
      child: Text(label,
          style: RenewdTextStyles.caption.copyWith(color: RenewdColors.slate)),
    );
  }
}
