import 'package:get/get.dart';
import '../../core/services/auth_service.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/models/user_model.dart';
import '../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final _authService = Get.find<AuthService>();
  final _provider = AuthProvider();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString phone = ''.obs;

  Future<void> sendOtp() async {
    if (phone.value.isEmpty) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await _provider.sendOtp(phone.value);
      Get.toNamed(AppRoutes.otpVerify);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(String otp) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _provider.verifyOtp(
        phone: phone.value,
        otp: otp,
      );
      final token = result['token'] as String;
      final user = UserModel.fromJson(
        result['user'] as Map<String, dynamic>,
      );
      await _authService.signIn(token: token, user: user);
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
