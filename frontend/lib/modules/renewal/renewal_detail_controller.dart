import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/currency.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../widgets/irrelevant_doc_sheet.dart';
import '../../data/models/document_model.dart';
import '../../data/models/payment_model.dart';
import '../../data/models/renewal_model.dart';
import '../../data/providers/document_provider.dart';
import '../../data/providers/payment_provider.dart';
import '../../data/providers/renewal_provider.dart';

class RenewalDetailController extends GetxController {
  final _provider = RenewalProvider();
  final _docProvider = DocumentProvider();
  final _payProvider = PaymentProvider();

  final Rx<RenewalModel?> renewal = Rx<RenewalModel?>(null);
  final RxBool isLoading = false.obs;
  final RxList<DocumentModel> documents = <DocumentModel>[].obs;
  final RxList<PaymentModel> payments = <PaymentModel>[].obs;
  final RxList<int> reminderDays = <int>[].obs;
  final RxBool isUploading = false.obs;
  final RxBool isParsing = false.obs;
  bool dataChanged = false;

  final RxBool showPaymentPrompt = false.obs;
  DateTime? renewedForDate;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is RenewalModel) {
      renewal.value = arg;
      _fetchSupplementary();
    } else if (arg is String) {
      fetchRenewal(arg);
    }
  }

  Future<void> _fetchSupplementary() async {
    await Future.wait([fetchDocuments(), fetchPayments(), fetchReminders()]);
  }

  Future<void> fetchRenewal(String id) async {
    isLoading.value = true;
    try {
      renewal.value = await _provider.getById(id);
      await _fetchSupplementary();
    } catch (e) {
      debugPrint('fetchRenewal failed: $e');
      showErrorSnack('Failed to load renewal');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDocuments() async {
    final id = renewal.value?.id;
    if (id == null) return;
    try {
      documents.assignAll(await _docProvider.getByRenewal(id));
    } catch (e) {
      debugPrint('fetchDocuments failed: $e');
    }
  }

  Future<void> fetchPayments() async {
    final id = renewal.value?.id;
    if (id == null) return;
    try {
      payments.assignAll(await _payProvider.getByRenewal(id));
    } catch (e) {
      debugPrint('fetchPayments failed: $e');
    }
  }

  Future<void> fetchReminders() async {
    final id = renewal.value?.id;
    if (id == null) return;
    try {
      final reminders = await _provider.getReminders(id);
      final unsent = reminders
          .where((r) => r['is_sent'] != true)
          .map((r) => r['days_before'] as int)
          .toList();

      if (unsent.isEmpty) {
        const defaults = [7, 1];
        await _provider.updateReminders(id, defaults);
        reminderDays.assignAll(defaults);
      } else {
        reminderDays.assignAll(unsent);
      }
    } catch (e) {
      debugPrint('fetchReminders failed: $e');
    }
  }

  Future<void> updateReminders(List<int> days) async {
    final id = renewal.value?.id;
    if (id == null) return;
    try {
      await _provider.updateReminders(id, days);
      reminderDays.assignAll(days);
      showSuccessSnack('Reminders updated');
    } catch (e) {
      debugPrint('updateReminders failed: $e');
      showErrorSnack('Failed to update reminders');
    }
  }

  Future<void> markRenewed() async {
    final id = renewal.value?.id;
    if (id == null) return;
    isLoading.value = true;
    try {
      renewedForDate = renewal.value?.renewalDate;
      renewal.value = await _provider.markRenewed(id);
      dataChanged = true;
      showPaymentPrompt.value = true;
    } catch (e) {
      debugPrint('markRenewed failed: $e');
      showErrorSnack('Failed to mark as renewed');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logPayment({
    required double amount,
    String? method,
    String? referenceNumber,
    DateTime? paidDate,
  }) async {
    final r = renewal.value;
    if (r == null) return;
    final date = paidDate ?? DateTime.now();
    try {
      final payment = await _payProvider.create({
        'renewal_id': r.id,
        'amount': amount,
        'paid_date': date.toIso8601String().split('T')[0],
        'method': method,
        'reference_number': referenceNumber,
      });
      payments.insert(0, payment);
      showPaymentPrompt.value = false;
      showSuccessSnack('${RenewdCurrency.format(amount)} payment recorded');
    } catch (e) {
      debugPrint('logPayment failed: $e');
      showErrorSnack('Failed to log payment');
    }
  }

  void skipPaymentPrompt() {
    showPaymentPrompt.value = false;
  }

  Future<void> deleteRenewal() async {
    final id = renewal.value?.id;
    if (id == null) return;
    isLoading.value = true;
    try {
      await _provider.delete(id);
      Get.back(result: true);
    } catch (e) {
      debugPrint('deleteRenewal failed: $e');
      showErrorSnack('Failed to delete renewal');
      isLoading.value = false;
    }
  }

  Future<void> uploadDocument(String filePath, String fileName) async {
    final id = renewal.value?.id;
    if (id == null) return;
    isUploading.value = true;
    try {
      final doc = await _docProvider.upload(
        filePath: filePath,
        fileName: fileName,
        renewalId: id,
      );
      await _parseAndCheck(doc.id);
    } catch (e) {
      debugPrint('uploadDocument failed: $e');
      showErrorSnack('Upload failed');
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> _parseAndCheck(String docId) async {
    isParsing.value = true;
    try {
      final result = await _docProvider.parseDocument(docId);
      final extraction = result['extraction'] as Map<String, dynamic>?;
      final isRelevant = extraction?['is_relevant'] as bool? ?? true;
      final summary = extraction?['summary'] as String? ?? 'Document analyzed';

      if (!isRelevant) {
        isParsing.value = false;
        _showIrrelevantDocDialog(docId, summary);
      } else {
        await fetchDocuments();
        isParsing.value = false;
        showSuccessSnack(summary);
      }
    } catch (e) {
      debugPrint('_parseAndCheck failed: $e');
      await fetchDocuments();
      isParsing.value = false;
      showErrorSnack('AI analysis failed');
    }
  }

  Future<void> parseDocument(String docId) async {
    isParsing.value = true;
    try {
      await _docProvider.parseDocument(docId);
      await fetchDocuments();
    } catch (e) {
      debugPrint('parseDocument failed: $e');
      showErrorSnack('AI analysis failed');
    } finally {
      isParsing.value = false;
    }
  }

  void _showIrrelevantDocDialog(String docId, String summary) {
    Get.bottomSheet(
      IrrelevantDocSheet(
        summary: summary,
        onKeep: () {
          Get.back();
        },
        onDelete: () async {
          Get.back();
          await _docProvider.delete(docId);
          documents.removeWhere((d) => d.id == docId);
          showSuccessSnack('Document removed');
        },
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }
}
