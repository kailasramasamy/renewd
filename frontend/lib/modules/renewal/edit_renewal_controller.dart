import 'package:get/get.dart';
import '../../core/constants/category_config.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/models/renewal_model.dart';
import '../../data/providers/renewal_provider.dart';

class EditRenewalController extends GetxController {
  final _provider = RenewalProvider();
  late final String renewalId;

  final RxString name = ''.obs;
  final RxString providerName = ''.obs;
  final RxString notes = ''.obs;
  final Rx<RenewalCategory> category = RenewalCategory.subscription.obs;
  final RxString groupName = ''.obs;
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

  List<String> get suggestedGroups =>
      CategoryConfig.suggestedGroups(category.value);

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
    groupName.value = r.groupName ?? '';
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
      showErrorSnack(err);
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
        'group_name': groupName.value.trim().isNotEmpty
            ? groupName.value.trim()
            : null,
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
      showSuccessSnack('${name.value.trim()} saved');
    } catch (e) {
      showErrorSnack('Failed to update renewal');
    } finally {
      isLoading.value = false;
    }
  }
}
