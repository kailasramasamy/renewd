import 'package:get/get.dart';
import '../../data/models/renewal_model.dart';
import '../../data/providers/renewal_provider.dart';

class DashboardController extends GetxController {
  final _provider = RenewalProvider();

  final RxList<RenewalModel> renewals = <RenewalModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxMap<String, bool> expandedGroups = <String, bool>{}.obs;

  int get dueThisMonth {
    final now = DateTime.now();
    return renewals.where((r) {
      return r.renewalDate.month == now.month &&
          r.renewalDate.year == now.year;
    }).length;
  }

  int get totalActive => renewals.length;

  double get monthlySpend {
    return renewals
        .where((r) => r.frequency == 'monthly')
        .fold(0.0, (sum, r) => sum + (r.amount ?? 0));
  }

  int get overdueCount =>
      renewals.where((r) => r.daysRemaining < 0).length;

  int get urgentCount => renewals
      .where((r) => r.daysRemaining >= 0 && r.daysRemaining <= 3)
      .length;

  bool get hasAlerts => overdueCount > 0 || urgentCount > 0;

  Map<String, List<RenewalModel>> get groupedRenewals {
    final map = <String, List<RenewalModel>>{};
    for (final r in renewals) {
      final group = r.displayGroup;
      map.putIfAbsent(group, () => []).add(r);
    }
    for (final list in map.values) {
      list.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    }
    return map;
  }

  List<String> get sortedGroupNames {
    final groups = groupedRenewals;
    final names = groups.keys.toList();
    names.sort((a, b) {
      final aMin = groups[a]!.first.daysRemaining;
      final bMin = groups[b]!.first.daysRemaining;
      return aMin.compareTo(bMin);
    });
    return names;
  }

  List<RenewalModel> get dueSoon =>
      renewals.where((r) => r.daysRemaining >= 0 && r.daysRemaining <= 7).toList();

  void toggleGroup(String groupName) {
    expandedGroups[groupName] = !(expandedGroups[groupName] ?? true);
  }

  bool isGroupExpanded(String groupName) =>
      expandedGroups[groupName] ?? true;

  @override
  void onInit() {
    super.onInit();
    fetchRenewals();
  }

  Future<void> fetchRenewals() async {
    isLoading.value = true;
    error.value = '';
    try {
      final result = await _provider.getAll();
      renewals.assignAll(result);
      renewals.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
