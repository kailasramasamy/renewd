import 'package:get/get.dart';
import '../../data/models/renewal_model.dart';
import '../../data/providers/renewal_provider.dart';

class RenewalDetailController extends GetxController {
  final _provider = RenewalProvider();

  final Rx<RenewalModel?> renewal = Rx<RenewalModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is RenewalModel) {
      renewal.value = arg;
    } else if (arg is String) {
      fetchRenewal(arg);
    }
  }

  Future<void> fetchRenewal(String id) async {
    isLoading.value = true;
    try {
      renewal.value = await _provider.getById(id);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markRenewed() async {
    final id = renewal.value?.id;
    if (id == null) return;
    isLoading.value = true;
    try {
      renewal.value = await _provider.markRenewed(id);
      Get.snackbar('Renewed', 'Next renewal date updated',
          snackPosition: SnackPosition.BOTTOM);
      Get.back(result: true);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteRenewal() async {
    final id = renewal.value?.id;
    if (id == null) return;
    isLoading.value = true;
    try {
      await _provider.delete(id);
      Get.back(result: true);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      isLoading.value = false;
    }
  }
}
