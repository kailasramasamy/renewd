import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../../data/models/user_model.dart';

class AuthService extends GetxService {
  final _storage = Get.find<StorageService>();

  final Rx<UserModel?> _currentUser = Rx(null);

  UserModel? get currentUser => _currentUser.value;
  bool get isLoggedIn => _storage.readToken() != null;

  Future<AuthService> init() async {
    final userData = _storage.readUserData();
    if (userData != null) {
      _currentUser.value = UserModel.fromJson(userData);
    }
    return this;
  }

  Future<void> signIn({required String token, required UserModel user}) async {
    _storage.saveToken(token);
    _storage.saveUserData(user.toJson());
    _currentUser.value = user;
  }

  Future<void> signOut() async {
    _storage.deleteToken();
    _storage.deleteUserData();
    _currentUser.value = null;
    Get.offAllNamed('/login');
  }
}
