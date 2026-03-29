import 'package:get/get.dart';
import '../../data/models/premium_config_model.dart';
import '../../data/providers/premium_provider.dart';
import 'auth_service.dart';

class PremiumService extends GetxService {
  final _provider = PremiumProvider();
  final Rx<PremiumConfigModel?> _config = Rx(null);

  PremiumConfigModel? get config => _config.value;

  bool get isPremium => Get.find<AuthService>().currentUser?.isPremium ?? false;

  Future<PremiumService> init() async {
    await fetchConfig();
    return this;
  }

  Future<void> fetchConfig() async {
    try {
      _config.value = await _provider.getConfig();
    } catch (_) {
      // Use defaults if fetch fails
    }
  }

  bool canCreateRenewal(int currentCount) {
    if (isPremium) return true;
    final limit = _config.value?.freeRenewalLimit ?? 5;
    return currentCount < limit;
  }

  int get freeRenewalLimit => _config.value?.freeRenewalLimit ?? 5;

  bool isFeatureAvailable(String feature) {
    final cfg = _config.value;
    if (cfg == null) return isPremium;
    return cfg.isFeatureAvailable(feature, isPremium: isPremium);
  }

  PremiumPricing get pricing =>
      _config.value?.pricing ??
      const PremiumPricing(monthly: 99, yearly: 799, currency: 'INR');
}
