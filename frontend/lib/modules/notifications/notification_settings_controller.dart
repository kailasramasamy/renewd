import 'package:get/get.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/providers/notification_provider.dart';

class NotificationSettingsController extends GetxController {
  final _provider = NotificationProvider();

  final RxBool enabled = true.obs;
  final RxList<int> defaultDaysBefore = <int>[7, 1].obs;
  final RxBool dailyDigestEnabled = false.obs;
  final RxInt dailyDigestHour = 9.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  static const availableDays = [30, 14, 7, 3, 1];

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    isLoading.value = true;
    try {
      final prefs = await _provider.getPreferences();
      enabled.value = prefs['enabled'] as bool? ?? true;
      final days = prefs['default_days_before'];
      if (days is List) {
        defaultDaysBefore.value = days.cast<int>();
      }
      dailyDigestEnabled.value = prefs['daily_digest_enabled'] as bool? ?? false;
      dailyDigestHour.value = prefs['daily_digest_hour'] as int? ?? 9;
    } catch (e) {
      showErrorSnack('Failed to load preferences');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleDay(int day) {
    if (defaultDaysBefore.contains(day)) {
      defaultDaysBefore.remove(day);
    } else {
      defaultDaysBefore.add(day);
      defaultDaysBefore.sort((a, b) => b.compareTo(a));
    }
    _savePreferences();
  }

  void toggleEnabled(bool value) {
    enabled.value = value;
    _savePreferences();
  }

  void toggleDigest(bool value) {
    dailyDigestEnabled.value = value;
    _savePreferences();
  }

  Future<void> _savePreferences() async {
    isSaving.value = true;
    try {
      await _provider.updatePreferences({
        'enabled': enabled.value,
        'default_days_before': defaultDaysBefore.toList(),
        'daily_digest_enabled': dailyDigestEnabled.value,
        'daily_digest_hour': dailyDigestHour.value,
      });
    } catch (e) {
      showErrorSnack('Failed to save preferences');
    } finally {
      isSaving.value = false;
    }
  }
}
