import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class PickedDocument {
  final String path;
  final String name;

  PickedDocument({required this.path, required this.name});
}

String _cleanName(String prefix) {
  final now = DateTime.now();
  final date =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  return '${prefix}_$date';
}

/// Compress image to JPEG at given quality, max width 1200px
Future<Uint8List> _compressImage(String imagePath, {int quality = 70, int maxWidth = 1200}) async {
  final bytes = await File(imagePath).readAsBytes();
  var image = img.decodeImage(bytes);
  if (image == null) return bytes;

  if (image.width > maxWidth) {
    image = img.copyResize(image, width: maxWidth);
  }

  return Uint8List.fromList(img.encodeJpg(image, quality: quality));
}

/// Combine multiple images into a single compressed PDF
Future<PickedDocument> imagesToPdf(List<String> imagePaths, String namePrefix) async {
  final pdfDoc = pw.Document();

  for (final path in imagePaths) {
    final compressed = await _compressImage(path);
    final image = pw.MemoryImage(compressed);
    pdfDoc.addPage(
      pw.Page(
        build: (context) => pw.Center(
          child: pw.Image(image, fit: pw.BoxFit.contain),
        ),
      ),
    );
  }

  final tempDir = await getTemporaryDirectory();
  final pdfName = '${_cleanName(namePrefix)}.pdf';
  final pdfFile = File('${tempDir.path}/$pdfName');
  await pdfFile.writeAsBytes(await pdfDoc.save());

  return PickedDocument(path: pdfFile.path, name: pdfName);
}

Future<PickedDocument?> showDocumentPicker(BuildContext context) async {
  return showModalBottomSheet<PickedDocument>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const _PickerSheet(),
  );
}

class _PickerSheet extends StatelessWidget {
  const _PickerSheet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(RenewdSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: RenewdColors.slate.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: RenewdSpacing.lg),
            Text('Add Document',
                style:
                    RenewdTextStyles.h3.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: RenewdSpacing.lg),
            _Option(
              icon: LucideIcons.scanLine,
              label: 'Scan Document',
              subtitle: 'Auto-detect edges, multi-page PDF',
              color: RenewdColors.oceanBlue,
              isDark: isDark,
              onTap: () => _scanDocument(context),
            ),
            const SizedBox(height: RenewdSpacing.sm),
            _Option(
              icon: LucideIcons.image,
              label: 'Photo Library',
              subtitle: 'Choose from gallery',
              color: RenewdColors.emerald,
              isDark: isDark,
              onTap: () => _pickFromGallery(context),
            ),
            const SizedBox(height: RenewdSpacing.sm),
            _Option(
              icon: LucideIcons.folderOpen,
              label: 'Browse Files',
              subtitle: 'Files, Dropbox, Google Drive',
              color: RenewdColors.lavender,
              isDark: isDark,
              onTap: () => _pickFromFiles(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanDocument(BuildContext context) async {
    try {
      final result = await FlutterDocScanner().getScannedDocumentAsImages(page: 10);
      if (result == null || result.images.isEmpty || !context.mounted) return;

      // Convert all scanned pages into a single compressed PDF
      final pdf = await imagesToPdf(result.images, 'Scan');
      if (!context.mounted) return;
      Navigator.of(context).pop(pdf);
    } on Exception catch (_) {
      if (!context.mounted) return;
      // Fallback to camera → single page PDF
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image == null || !context.mounted) return;
      final pdf = await imagesToPdf([image.path], 'Scan');
      if (!context.mounted) return;
      Navigator.of(context).pop(pdf);
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null || !context.mounted) return;
    // Convert to compressed PDF
    final pdf = await imagesToPdf([image.path], 'Photo');
    if (!context.mounted) return;
    Navigator.of(context).pop(pdf);
  }

  Future<void> _pickFromFiles(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
    );
    if (result == null || result.files.isEmpty || !context.mounted) return;
    final file = result.files.first;
    if (file.path == null) return;

    // If already PDF, use directly
    if (file.extension?.toLowerCase() == 'pdf') {
      Navigator.of(context).pop(PickedDocument(
        path: file.path!,
        name: file.name,
      ));
      return;
    }

    // Convert image to compressed PDF
    final pdf = await imagesToPdf([file.path!], 'File');
    if (!context.mounted) return;
    Navigator.of(context).pop(pdf);
  }
}

class _Option extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _Option({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(RenewdSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? RenewdColors.steel : RenewdColors.cloudGray,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: RenewdSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: RenewdTextStyles.body
                          .copyWith(fontWeight: FontWeight.w500)),
                  Text(subtitle,
                      style: RenewdTextStyles.caption
                          .copyWith(color: RenewdColors.slate)),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight,
                color: RenewdColors.slate, size: 16),
          ],
        ),
      ),
    );
  }
}
