import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../core/constants/category_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../data/models/renewal_model.dart';
import '../dashboard/dashboard_controller.dart';

class AnalyticsController extends GetxController {
  final _client = Get.find<ApiClient>();

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  final RxList<CategorySpend> categoryBreakdown = <CategorySpend>[].obs;
  final RxList<MonthlySpend> monthlyTrend = <MonthlySpend>[].obs;
  final RxDouble totalSpend = 0.0.obs;

  List<RenewalModel> get topRenewals {
    try {
      final dc = Get.find<DashboardController>();
      final sorted = List<RenewalModel>.from(dc.renewals);
      sorted.sort(
        (a, b) => (b.amount ?? 0).compareTo(a.amount ?? 0),
      );
      return sorted.take(5).toList();
    } catch (e) {
      debugPrint('topRenewals failed: $e');
      return [];
    }
  }

  bool get hasData =>
      categoryBreakdown.isNotEmpty || monthlyTrend.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    isLoading.value = true;
    error.value = '';
    try {
      await Future.wait([
        _fetchByCategory(),
        _fetchByMonth(),
      ]);
    } catch (e) {
      error.value = e.toString();
      debugPrint('fetchAnalytics failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchByCategory() async {
    final response = await _client.safeGet(
      ApiEndpoints.analyticsByCategory,
    );
    final body = response.body as Map<String, dynamic>;
    final list = body['categories'] as List<dynamic>? ?? [];
    double total = 0;
    final items = <CategorySpend>[];
    for (final item in list) {
      final map = item as Map<String, dynamic>;
      final amount = (map['total'] as num?)?.toDouble() ?? 0;
      total += amount;
      final catName = (map['category'] as String?) ?? 'other';
      final category = RenewalCategory.values.firstWhere(
        (e) => e.name == catName.toLowerCase(),
        orElse: () => RenewalCategory.other,
      );
      items.add(CategorySpend(category: category, amount: amount));
    }
    categoryBreakdown.assignAll(items);
    totalSpend.value = total;
  }

  Future<void> _fetchByMonth() async {
    final response = await _client.safeGet(
      ApiEndpoints.analyticsByMonth,
    );
    final body = response.body as Map<String, dynamic>;
    final list = body['months'] as List<dynamic>? ?? [];
    final items = <MonthlySpend>[];
    for (final item in list) {
      final map = item as Map<String, dynamic>;
      items.add(MonthlySpend(
        month: map['month'] as String? ?? '',
        amount: (map['total'] as num?)?.toDouble() ?? 0,
      ));
    }
    monthlyTrend.assignAll(items);
  }
}

class CategorySpend {
  final RenewalCategory category;
  final double amount;
  const CategorySpend({required this.category, required this.amount});
}

class MonthlySpend {
  final String month;
  final double amount;
  const MonthlySpend({required this.month, required this.amount});
}
