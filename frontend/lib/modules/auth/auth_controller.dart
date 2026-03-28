import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final _auth = FirebaseAuth.instance;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString phone = ''.obs;

  String? _verificationId;

  // ─── Phone OTP ──────────────────────────────────────

  Future<void> sendOtp() async {
    final phoneNumber = phone.value.trim();
    if (phoneNumber.isEmpty) return;

    final formatted =
        phoneNumber.startsWith('+') ? phoneNumber : '+91$phoneNumber';

    isLoading.value = true;
    errorMessage.value = '';

    await _auth.verifyPhoneNumber(
      phoneNumber: formatted,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
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
      errorMessage.value = e.code == 'invalid-verification-code'
          ? 'Invalid OTP. Please try again.'
          : (e.message ?? 'Verification failed');
    } catch (_) {
      isLoading.value = false;
      errorMessage.value = 'Something went wrong';
    }
  }

  // ─── Google Sign-In ─────────────────────────────────

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();
      final googleUser = await googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await _signInWithCredential(credential);
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Google sign-in failed';
      debugPrint('[Auth] Google error: $e');
    }
  }

  // ─── Apple Sign-In ──────────────────────────────────

  Future<void> signInWithApple() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      await _signInWithCredential(oauthCredential);
    } catch (e) {
      isLoading.value = false;
      if (e.toString().contains('canceled')) return; // user cancelled
      errorMessage.value = 'Apple sign-in failed';
      debugPrint('[Auth] Apple error: $e');
    }
  }

  // ─── Common ─────────────────────────────────────────

  Future<void> _signInWithCredential(AuthCredential credential) async {
    try {
      final result = await _auth.signInWithCredential(credential);
      final user = result.user;
      if (user == null) {
        errorMessage.value = 'Sign in failed';
        isLoading.value = false;
        return;
      }

      final token = await user.getIdToken();
      final storage = Get.find<StorageService>();
      storage.saveToken(token!);
      storage.saveUserData({
        'uid': user.uid,
        'phone': user.phoneNumber,
        'email': user.email,
        'name': user.displayName,
        'photo': user.photoURL,
      });

      isLoading.value = false;
      showSuccessSnack('Welcome to Renewd!');
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Sign in failed';
      debugPrint('[Auth] Credential error: $e');
    }
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
