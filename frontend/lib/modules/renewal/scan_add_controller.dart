import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/category_config.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/models/document_model.dart';
import '../../data/providers/document_provider.dart';
import '../../data/providers/renewal_provider.dart';
import '../../widgets/irrelevant_doc_sheet.dart';

class ScanAddController extends GetxController {
  final _docProvider = DocumentProvider();
  final _renewalProvider = RenewalProvider();

  final RxBool isUploading = false.obs;
  final RxBool isParsing = false.obs;
  final RxBool isSaving = false.obs;
  final RxString analyzeStep = ''.obs;
  final Rx<DocumentModel?> document = Rx(null);
  final Rx<Map<String, dynamic>?> extraction = Rx(null);

  final RxString name = ''.obs;
  final Rx<RenewalCategory> category = RenewalCategory.other.obs;
  final RxString groupName = ''.obs;
  final RxString providerName = ''.obs;
  final Rx<double?> amount = Rx(null);
  final Rx<DateTime?> renewalDate = Rx(null);
  final RxString frequency = 'yearly'.obs;
  final RxBool autoRenew = false.obs;
  final RxString notes = ''.obs;
  final RxList<String> keyDetails = <String>[].obs;

  bool get isAnalyzing => isUploading.value || isParsing.value;

  static const List<String> frequencies = [
    'monthly', 'quarterly', 'yearly', 'weekly',
  ];

  static const Map<String, String> frequencyLabels = {
    'monthly': 'Monthly', 'quarterly': 'Quarterly',
    'yearly': 'Yearly', 'weekly': 'Weekly',
  };

  List<String> get suggestedGroups =>
      CategoryConfig.suggestedGroups(category.value);

  Future<void> uploadAndParse(String filePath, String fileName) async {
    isUploading.value = true;
    analyzeStep.value = 'Uploading document...';
    try {
      final doc = await _docProvider.upload(
        filePath: filePath,
        fileName: fileName,
      );
      document.value = doc;
      isUploading.value = false;
      isParsing.value = true;
      analyzeStep.value = 'Reading document with AI...';
      final result = await _docProvider.parseDocument(doc.id);
      analyzeStep.value = 'Extracting details...';
      final ext = result['extraction'] as Map<String, dynamic>?;
      final isRelevant = ext?['is_relevant'] as bool? ?? true;

      if (!isRelevant) {
        await _handleIrrelevantDoc(doc.id, ext?['summary'] as String? ?? 'Not a renewal document');
        return;
      }

      _prefillFromExtraction(ext);
      extraction.value = ext;
    } catch (e) {
      showErrorSnack('Failed to analyze document');
    } finally {
      isUploading.value = false;
      isParsing.value = false;
    }
  }

  Future<void> _handleIrrelevantDoc(String docId, String summary) async {
    final completer = Completer<bool>();
    Get.bottomSheet(
      IrrelevantDocSheet(
        summary: summary,
        onKeep: () {
          Get.back();
          completer.complete(true);
        },
        onDelete: () {
          Get.back();
          completer.complete(false);
        },
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
    final keep = await completer.future;
    if (!keep) {
      await _docProvider.delete(docId);
      document.value = null;
      Get.back();
    }
  }

  void _prefillFromExtraction(Map<String, dynamic>? ext) {
    if (ext == null) return;
    _prefillBasicFields(ext);
    _prefillDateAndDetails(ext);
  }

  void _prefillBasicFields(Map<String, dynamic> ext) {
    final provider = ext['provider'] as String?;
    final docType = ext['document_type'] as String?;
    if (provider != null) {
      name.value = '$provider ${_humanDocType(docType)}';
      providerName.value = provider;
    }
    category.value = _detectCategory(docType, provider);
    groupName.value = _detectGroup(docType, provider, ext);
    frequency.value = _defaultFrequency(category.value);
    final summary = ext['summary'] as String?;
    if (summary != null) notes.value = summary;
  }

  void _prefillDateAndDetails(Map<String, dynamic> ext) {
    if (ext['amount'] != null) {
      amount.value = (ext['amount'] as num).toDouble();
    }
    final expiry = ext['expiry_date'] as String?;
    if (expiry != null) renewalDate.value = DateTime.tryParse(expiry);
    final details = ext['key_details'] as List<dynamic>?;
    if (details != null) {
      keyDetails.assignAll(details.map((e) => e.toString()));
    }
  }

  RenewalCategory _detectCategory(String? docType, String? provider) {
    if (docType == 'policy' || docType == 'certificate') {
      return RenewalCategory.insurance;
    }
    if (docType == 'invoice' || docType == 'receipt') {
      return RenewalCategory.utility;
    }
    if (docType == 'id') return RenewalCategory.government;
    return _detectCategoryFromProvider(provider);
  }

  RenewalCategory _detectCategoryFromProvider(String? provider) {
    final p = (provider ?? '').toLowerCase();
    if (p.contains('insurance') || p.contains('ergo') ||
        p.contains('lombard') || p.contains('lic')) {
      return RenewalCategory.insurance;
    }
    if (p.contains('netflix') || p.contains('amazon') ||
        p.contains('spotify') || p.contains('hotstar')) {
      return RenewalCategory.subscription;
    }
    return RenewalCategory.other;
  }

  String _detectGroup(
    String? docType,
    String? provider,
    Map<String, dynamic> ext,
  ) {
    final summary = (ext['summary'] as String? ?? '').toLowerCase();
    final insuranceGroup = _detectInsuranceGroup(summary);
    if (insuranceGroup != null) return insuranceGroup;
    final utilityGroup = _detectUtilityGroup(summary);
    if (utilityGroup != null) return utilityGroup;
    return CategoryConfig.label(_detectCategory(docType, provider));
  }

  String? _detectInsuranceGroup(String summary) {
    if (summary.contains('car') || summary.contains('vehicle') ||
        summary.contains('motor')) {
      return 'Car Insurance';
    }
    if (summary.contains('health') || summary.contains('medical') ||
        summary.contains('mediclaim')) {
      return 'Health Insurance';
    }
    if (summary.contains('life')) return 'Life Insurance';
    if (summary.contains('home') || summary.contains('property')) {
      return 'Home Insurance';
    }
    if (summary.contains('travel')) return 'Travel Insurance';
    return null;
  }

  String? _detectUtilityGroup(String summary) {
    if (summary.contains('electric')) return 'Electricity';
    if (summary.contains('water')) return 'Water';
    if (summary.contains('gas')) return 'Gas';
    if (summary.contains('internet') || summary.contains('broadband')) {
      return 'Internet';
    }
    return null;
  }

  String _humanDocType(String? docType) {
    switch (docType) {
      case 'policy': return 'Policy';
      case 'receipt': return 'Receipt';
      case 'certificate': return 'Certificate';
      case 'invoice': return 'Invoice';
      case 'id': return 'ID';
      default: return 'Document';
    }
  }

  String _defaultFrequency(RenewalCategory cat) {
    switch (cat) {
      case RenewalCategory.utility: return 'monthly';
      case RenewalCategory.subscription: return 'monthly';
      default: return 'yearly';
    }
  }

  String? validateAndGetError() {
    if (name.value.trim().isEmpty) return 'Please enter a name';
    if (renewalDate.value == null) return 'Please select the renewal date';
    return null;
  }

  Future<void> save() async {
    final error = validateAndGetError();
    if (error != null) {
      showErrorSnack(error);
      return;
    }
    isSaving.value = true;
    try {
      final renewal = await _renewalProvider.create(_buildRenewalData());
      if (document.value != null) {
        await _docProvider.linkToRenewal(document.value!.id, renewal.id);
      }
      Get.back(result: true);
      showSuccessSnack('${name.value.trim()} added from document');
    } catch (e) {
      showErrorSnack('Failed to save renewal');
    } finally {
      isSaving.value = false;
    }
  }

  Map<String, dynamic> _buildRenewalData() => {
    'name': name.value.trim(),
    'category': category.value.name,
    'renewal_date': renewalDate.value!.toIso8601String(),
    'frequency': frequency.value,
    'auto_renew': autoRenew.value,
    if (groupName.value.trim().isNotEmpty) 'group_name': groupName.value.trim(),
    if (providerName.value.trim().isNotEmpty) 'provider': providerName.value.trim(),
    if (amount.value != null) 'amount': amount.value,
    if (notes.value.trim().isNotEmpty) 'notes': notes.value.trim(),
  };
}
