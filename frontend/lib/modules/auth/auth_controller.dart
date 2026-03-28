import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final _auth = FirebaseAuth.instance;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString phone = ''.obs;

  String? _verificationId;

  Future<void> sendOtp() async {
    final phoneNumber = phone.value.trim();
    if (phoneNumber.isEmpty) return;

    // Add country code if missing
    final formatted = phoneNumber.startsWith('+')
        ? phoneNumber
        : '+91$phoneNumber';

    isLoading.value = true;
    errorMessage.value = '';

    await _auth.verifyPhoneNumber(
      phoneNumber: formatted,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        // Auto-verification (Android only)
        await _signInWithCredential(credential);
      },
      verificationFailed: (e) {
        isLoading.value = false;
        errorMessage.value = e.message ?? 'Verification failed';
      },
      codeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        isLoading.value = false;
        Get.toNamed(AppRoutes.otpVerify);
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> verifyOtp(String otp) async {
    if (_verificationId == null) {
      errorMessage.value = 'Please request OTP first';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      if (e.code == 'invalid-verification-code') {
        errorMessage.value = 'Invalid OTP. Please try again.';
      } else {
        errorMessage.value = e.message ?? 'Verification failed';
      }
    } catch (_) {
      isLoading.value = false;
      errorMessage.value = 'Something went wrong';
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final result = await _auth.signInWithCredential(credential);
      final user = result.user;
      if (user == null) {
        errorMessage.value = 'Sign in failed';
        isLoading.value = false;
        return;
      }

      // Get Firebase ID token for backend auth
      final token = await user.getIdToken();
      final storage = Get.find<StorageService>();
      storage.saveToken(token!);
      storage.saveUserData({
        'uid': user.uid,
        'phone': user.phoneNumber,
        'name': user.displayName,
      });

      isLoading.value = false;
      showSuccessSnack('Welcome to Renewd!');
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Sign in failed';
    }
  }
}
