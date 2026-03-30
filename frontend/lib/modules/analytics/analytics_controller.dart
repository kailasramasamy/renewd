import 'package:get/get.dart';
import '../../core/constants/category_config.dart';
import '../../data/models/renewal_model.dart';
import '../dashboard/dashboard_controller.dart';

class AnalyticsController extends GetxController {
  List<RenewalModel> get _renewals {
    try {
      return Get.find<DashboardController>().renewals;
    } catch (_) {
      return [];
    }
  }

  bool get hasData => _renewals.isNotEmpty;

  double _annualCost(RenewalModel r) {
    final amount = r.amount ?? 0;
    switch (r.frequency) {
      case 'monthly': return amount * 12;
      case 'quarterly': return amount * 4;
      case 'yearly': return amount;
      case 'weekly': return amount * 52;
      case 'custom':
        final days = r.frequencyDays ?? 365;
        return amount * (365 / days);
      default: return amount;
    }
  }

  double get totalAnnualSpend =>
      _renewals.fold(0.0, (sum, r) => sum + _annualCost(r));

  double get monthlySpend =>
      _renewals.where((r) => r.frequency == 'monthly')
          .fold(0.0, (sum, r) => sum + (r.amount ?? 0));

  double get yearlySpend =>
      _renewals.where((r) => r.frequency == 'yearly')
          .fold(0.0, (sum, r) => sum + (r.amount ?? 0));

  List<CategorySpend> get categoryBreakdown {
    final map = <RenewalCategory, _CatAccum>{};
    for (final r in _renewals) {
      map.putIfAbsent(r.category, () => _CatAccum());
      map[r.category]!.count++;
      map[r.category]!.annual += _annualCost(r);
    }
    final items = map.entries
        .map((e) => CategorySpend(
              category: e.key,
              annualCost: e.value.annual,
              count: e.value.count,
            ))
        .toList();
    items.sort((a, b) => b.annualCost.compareTo(a.annualCost));
    return items;
  }

  List<RenewalModel> get topRenewals {
    final sorted = List<RenewalModel>.from(_renewals);
    sorted.sort((a, b) => _annualCost(b).compareTo(_annualCost(a)));
    return sorted.take(5).toList();
  }

  double annualCostOf(RenewalModel r) => _annualCost(r);

  String frequencyLabel(String? freq) {
    switch (freq) {
      case 'monthly': return '/mo';
      case 'quarterly': return '/qtr';
      case 'yearly': return '/yr';
      case 'weekly': return '/wk';
      default: return '';
    }
  }
}

class CategorySpend {
  final RenewalCategory category;
  final double annualCost;
  final int count;
  const CategorySpend({required this.category, required this.annualCost, required this.count});
}

class _CatAccum {
  int count = 0;
  double annual = 0;
}
