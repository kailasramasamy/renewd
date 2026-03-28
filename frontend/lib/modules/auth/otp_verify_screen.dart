import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/minder_button.dart';
import 'auth_controller.dart';

class OtpVerifyScreen extends StatelessWidget {
  const OtpVerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AuthController>();
    final otpController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(RenewdSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: RenewdSpacing.xl),
              Text('Enter OTP',
                  style: RenewdTextStyles.h1
                      .copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: RenewdSpacing.sm),
              Obx(() => Text(
                    'We sent a code to ${c.phone.value}',
                    style: RenewdTextStyles.body
                        .copyWith(color: RenewdColors.slate),
                  )),
              const SizedBox(height: RenewdSpacing.xxl),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                autofocus: true,
                style: RenewdTextStyles.h2.copyWith(
                  letterSpacing: 8,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '------',
                  hintStyle: RenewdTextStyles.h2.copyWith(
                    letterSpacing: 8,
                    color: RenewdColors.slate,
                  ),
                  counterText: '',
                  filled: true,
                  fillColor: isDark
                      ? RenewdColors.steel
                      : RenewdColors.cloudGray,
                ),
              ),
              const SizedBox(height: RenewdSpacing.sm),
              Obx(() {
                if (c.errorMessage.value.isEmpty) {
                  return const SizedBox(height: RenewdSpacing.lg);
                }
                return Padding(
                  padding: const EdgeInsets.only(top: RenewdSpacing.sm),
                  child: Text(
                    c.errorMessage.value,
                    style: RenewdTextStyles.bodySmall
                        .copyWith(color: RenewdColors.coralRed),
                    textAlign: TextAlign.center,
                  ),
                );
              }),
              const SizedBox(height: RenewdSpacing.xl),
              Obx(() => RenewdButton(
                    label: 'Verify',
                    isLoading: c.isLoading.value,
                    onPressed: () {
                      final otp = otpController.text.trim();
                      if (otp.length == 6) {
                        c.verifyOtp(otp);
                      }
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
