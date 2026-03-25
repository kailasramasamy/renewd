import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/app_constants.dart';

class StorageService extends GetxService {
  late final GetStorage _box;

  Future<StorageService> init() async {
    await GetStorage.init();
    _box = GetStorage();
    return this;
  }

  void saveToken(String token) =>
      _box.write(AppConstants.keyAuthToken, token);

  String? readToken() => _box.read<String>(AppConstants.keyAuthToken);

  void deleteToken() => _box.remove(AppConstants.keyAuthToken);

  void saveUserData(Map<String, dynamic> data) =>
      _box.write(AppConstants.keyUserData, jsonEncode(data));

  Map<String, dynamic>? readUserData() {
    final raw = _box.read<String>(AppConstants.keyUserData);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  void deleteUserData() => _box.remove(AppConstants.keyUserData);

  bool get isOnboardingComplete =>
      _box.read<bool>(AppConstants.keyOnboardingComplete) ?? false;

  void setOnboardingComplete() =>
      _box.write(AppConstants.keyOnboardingComplete, true);

  void clearAll() => _box.erase();
}
