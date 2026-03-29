import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class PdfViewerScreen extends StatefulWidget {
  final String url;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? _localPath;
  bool _isLoading = true;
  String? _error;
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  Future<void> _downloadPdf() async {
    try {
      final token = Get.find<StorageService>().readToken();
      final response = await http.get(
        Uri.parse(widget.url),
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );
      if (response.statusCode != 200) {
        setState(() {
          _error = 'Failed to load document';
          _isLoading = false;
        });
        return;
      }
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/viewer_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(response.bodyBytes);
      setState(() {
        _localPath = file.path;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load document';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => Get.back(),
        ),
        title: Text(widget.title, overflow: TextOverflow.ellipsis),
        actions: [
          if (_totalPages > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: RenewdTextStyles.caption
                      .copyWith(color: RenewdColors.slate),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.fileX, size: 48, color: RenewdColors.slate),
            const SizedBox(height: 12),
            Text(_error!, style: RenewdTextStyles.body
                .copyWith(color: RenewdColors.slate)),
          ],
        ),
      );
    }
    return PDFView(
      filePath: _localPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      onPageChanged: (page, total) {
        setState(() {
          _currentPage = page ?? 0;
          _totalPages = total ?? 0;
        });
      },
      onRender: (pages) {
        setState(() => _totalPages = pages ?? 0);
      },
    );
  }
}
