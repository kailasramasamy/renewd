import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/app_constants.dart';

class StorageService extends GetxService {
  late final GetStorage _box;
  final FlutterSecureStorage _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  String? _cachedToken;

  Future<StorageService> init() async {
    await GetStorage.init();
    _box = GetStorage();

    // Pre-load token into memory to avoid async reads on every request
    _cachedToken = await _secure.read(key: AppConstants.keyAuthToken);

    // Migrate plaintext token from GetStorage if present
    final legacyToken = _box.read<String>(AppConstants.keyAuthToken);
    if (legacyToken != null) {
      await _secure.write(key: AppConstants.keyAuthToken, value: legacyToken);
      _cachedToken = legacyToken;
      _box.remove(AppConstants.keyAuthToken);
    }

    return this;
  }

  Future<void> saveToken(String token) async {
    _cachedToken = token;
    await _secure.write(key: AppConstants.keyAuthToken, value: token);
  }

  String? readToken() => _cachedToken;

  Future<void> deleteToken() async {
    _cachedToken = null;
    await _secure.delete(key: AppConstants.keyAuthToken);
  }

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

  void clearAll() {
    _box.erase();
    _cachedToken = null;
    _secure.deleteAll();
  }
}
