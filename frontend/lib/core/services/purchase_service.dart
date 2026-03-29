import 'dart:async';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../utils/snackbar_helper.dart';
import 'premium_service.dart';
import 'storage_service.dart';

class PurchaseService extends GetxService {
  final _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final RxList<ProductDetails> products = <ProductDetails>[].obs;
  final RxBool isPurchasing = false.obs;
  final RxBool isRestoring = false.obs;
  final RxBool isAvailable = false.obs;

  static const _productIds = {
    'renewd_monthly',
    'renewd_yearly',
    'renewd_lifetime',
  };

  Future<PurchaseService> init() async {
    try {
      isAvailable.value = await _iap.isAvailable();
    } catch (_) {
      isAvailable.value = false;
    }
    if (!isAvailable.value) return this;

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: (_) {},
    );

    await fetchProducts();
    return this;
  }

  Future<void> fetchProducts() async {
    if (!isAvailable.value) return;
    final premiumService = Get.find<PremiumService>();
    final config = premiumService.config;

    // Use product IDs from admin config if available
    final ids = config != null
        ? {
            config.iapProducts['monthly'] ?? 'renewd_monthly',
            config.iapProducts['yearly'] ?? 'renewd_yearly',
            config.iapProducts['lifetime'] ?? 'renewd_lifetime',
          }
        : _productIds;

    final response = await _iap.queryProductDetails(ids);
    products.assignAll(response.productDetails);
  }

  ProductDetails? get monthlyProduct =>
      _findProduct('renewd_monthly', 'monthly');

  ProductDetails? get yearlyProduct =>
      _findProduct('renewd_yearly', 'yearly');

  ProductDetails? get lifetimeProduct =>
      _findProduct('renewd_lifetime', 'lifetime');

  ProductDetails? _findProduct(String defaultId, String configKey) {
    final config = Get.find<PremiumService>().config;
    final id = config?.iapProducts[configKey] ?? defaultId;
    return products.cast<ProductDetails?>().firstWhere(
          (p) => p?.id == id,
          orElse: () => null,
        );
  }

  Future<void> purchase(ProductDetails product) async {
    isPurchasing.value = true;
    final isSubscription = product.id != 'renewd_lifetime';
    final purchaseParam = PurchaseParam(productDetails: product);

    if (isSubscription) {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  Future<void> restorePurchases() async {
    isRestoring.value = true;
    try {
      await _iap.restorePurchases();
    } catch (_) {
      showErrorSnack('Failed to restore purchases');
    } finally {
      isRestoring.value = false;
    }
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      _handlePurchase(purchase);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    switch (purchase.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        // Complete the purchase on the store side
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        _syncPremiumStatus(true);
        isPurchasing.value = false;
        if (purchase.status == PurchaseStatus.purchased) {
          showSuccessSnack('Welcome to Premium!');
        } else {
          showSuccessSnack('Premium restored!');
          isRestoring.value = false;
        }
      case PurchaseStatus.error:
        isPurchasing.value = false;
        isRestoring.value = false;
        if (purchase.error?.message != null) {
          showErrorSnack('Purchase failed. Please try again.');
        }
      case PurchaseStatus.canceled:
        isPurchasing.value = false;
      case PurchaseStatus.pending:
        // Payment is pending (e.g. waiting for approval)
        break;
    }
  }

  void _syncPremiumStatus(bool isPro) {
    final storage = Get.find<StorageService>();
    final userData = storage.readUserData();
    if (userData != null) {
      userData['is_premium'] = isPro;
      storage.saveUserData(userData);
    }
    Get.find<PremiumService>().fetchConfig();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
