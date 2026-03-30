import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../core/constants/category_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../data/models/banner_model.dart';
import '../../data/models/renewal_model.dart';
import '../../data/providers/renewal_provider.dart';

class DashboardController extends GetxController with WidgetsBindingObserver {
  final _provider = RenewalProvider();
  final _client = Get.find<ApiClient>();

  final RxList<RenewalModel> renewals = <RenewalModel>[].obs;
  final RxList<BannerModel> banners = <BannerModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxInt unreadNotificationCount = 0.obs;
  final RxMap<String, bool> expandedCategories = <String, bool>{}.obs;
  final RxMap<String, bool> expandedSubGroups = <String, bool>{}.obs;

  Map<RenewalCategory, Map<String, List<RenewalModel>>>? _cachedGrouped;
  bool _groupedDirty = true;

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

  List<RenewalModel> get filteredRenewals {
    final q = searchQuery.value.toLowerCase().trim();
    if (q.isEmpty) return renewals;
    return renewals.where((r) =>
        r.name.toLowerCase().contains(q) ||
        (r.provider?.toLowerCase().contains(q) ?? false) ||
        CategoryConfig.label(r.category).toLowerCase().contains(q)).toList();
  }

  List<RenewalModel> get dueSoon =>
      renewals.where((r) => r.daysRemaining >= 0 && r.daysRemaining <= 7).toList();

  void _invalidateGroupedCache() => _groupedDirty = true;

  /// Two-level grouping: Category → Group → Items (cached)
  Map<RenewalCategory, Map<String, List<RenewalModel>>> get categoryGrouped {
    if (!_groupedDirty && _cachedGrouped != null) return _cachedGrouped!;
    final map = <RenewalCategory, Map<String, List<RenewalModel>>>{};
    for (final r in renewals) {
      final cat = r.category;
      final group = r.displayGroup;
      map.putIfAbsent(cat, () => {});
      map[cat]!.putIfAbsent(group, () => []).add(r);
    }
    for (final catMap in map.values) {
      for (final list in catMap.values) {
        list.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
      }
    }
    _cachedGrouped = map;
    _groupedDirty = false;
    return map;
  }

  /// Categories sorted by most urgent first
  List<RenewalCategory> get sortedCategories {
    final grouped = categoryGrouped;
    final cats = grouped.keys.toList();
    cats.sort((a, b) {
      final aMin = _minDaysForCategory(grouped[a]!);
      final bMin = _minDaysForCategory(grouped[b]!);
      return aMin.compareTo(bMin);
    });
    return cats;
  }

  int _minDaysForCategory(Map<String, List<RenewalModel>> groups) {
    int min = 999999;
    for (final list in groups.values) {
      if (list.first.daysRemaining < min) min = list.first.daysRemaining;
    }
    return min;
  }

  void toggleCategory(RenewalCategory cat) {
    final key = cat.name;
    expandedCategories[key] = !(expandedCategories[key] ?? true);
  }

  bool isCategoryExpanded(RenewalCategory cat) =>
      expandedCategories[cat.name] ?? true;

  void toggleSubGroup(String key) {
    expandedSubGroups[key] = !(expandedSubGroups[key] ?? false);
  }

  bool isSubGroupExpanded(String key) =>
      expandedSubGroups[key] ?? false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    ever(renewals, (_) => _invalidateGroupedCache());
    ever(searchQuery, (_) => _invalidateGroupedCache());
    fetchRenewals();
    fetchUnreadCount();
    fetchBanners();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchRenewals();
    }
  }

  Future<void> fetchBanners() async {
    try {
      final response = await _client.safeGet(ApiEndpoints.banners);
      final body = response.body as Map<String, dynamic>;
      final list = body['banners'] as List<dynamic>? ?? [];
      banners.assignAll(
          list.map((e) => BannerModel.fromJson(e as Map<String, dynamic>)));
    } catch (e) {
      debugPrint('fetchBanners failed: $e');
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final response =
          await _client.safeGet(ApiEndpoints.notificationUnreadCount);
      final body = response.body as Map<String, dynamic>;
      unreadNotificationCount.value = body['count'] as int? ?? 0;
    } catch (e) {
      debugPrint('fetchUnreadCount failed: $e');
    }
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
