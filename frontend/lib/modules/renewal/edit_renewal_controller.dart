import 'package:get/get.dart';
import '../../core/constants/category_config.dart';
import '../../data/models/renewal_model.dart';
import '../../data/providers/renewal_provider.dart';

class EditRenewalController extends GetxController {
  final _provider = RenewalProvider();
  late final String renewalId;

  final RxString name = ''.obs;
  final RxString providerName = ''.obs;
  final RxString notes = ''.obs;
  final Rx<RenewalCategory> category = RenewalCategory.subscription.obs;
  final Rx<double?> amount = Rx<double?>(null);
  final Rx<DateTime?> renewalDate = Rx<DateTime?>(null);
  final RxString frequency = 'monthly'.obs;
  final RxInt frequencyDays = 30.obs;
  final RxBool autoRenew = false.obs;
  final RxBool isLoading = false.obs;

  static const Map<String, String> frequencyLabels = {
    'monthly': 'Monthly',
    'quarterly': 'Quarterly',
    'yearly': 'Yearly',
    'weekly': 'Weekly',
    'custom': 'Custom',
  };

  bool get isCustomFrequency => frequency.value == 'custom';

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is RenewalModel) {
      renewalId = arg.id;
      _populate(arg);
    }
  }

  void _populate(RenewalModel r) {
    name.value = r.name;
    providerName.value = r.provider ?? '';
    notes.value = r.notes ?? '';
    category.value = r.category;
    amount.value = r.amount;
    renewalDate.value = r.renewalDate;
    frequency.value = r.frequency ?? 'monthly';
    frequencyDays.value = r.frequencyDays ?? 30;
    autoRenew.value = r.autoRenew;
  }

  String? validateAndGetError() {
    if (name.value.trim().isEmpty) return 'Please enter a name for this renewal';
    if (renewalDate.value == null) return 'Please select the next renewal date';
    if (isCustomFrequency && frequencyDays.value <= 0) {
      return 'Please enter how many days between renewals';
    }
    return null;
  }

  Future<void> save() async {
    final err = validateAndGetError();
    if (err != null) {
      Get.snackbar('Missing info', err,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isLoading.value = true;
    try {
      final data = <String, dynamic>{
        'name': name.value.trim(),
        'category': category.value.name,
        'renewal_date': renewalDate.value!.toIso8601String(),
        'frequency': frequency.value,
        'auto_renew': autoRenew.value,
        'provider': providerName.value.trim().isNotEmpty
            ? providerName.value.trim()
            : null,
        'amount': amount.value,
        'notes':
            notes.value.trim().isNotEmpty ? notes.value.trim() : null,
        if (isCustomFrequency) 'frequency_days': frequencyDays.value,
      };
      await _provider.update(renewalId, data);
      Get.back(result: true);
      Get.snackbar('Updated', '${name.value.trim()} saved',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
