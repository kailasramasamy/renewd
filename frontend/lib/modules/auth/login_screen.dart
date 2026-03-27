import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../widgets/minder_button.dart';
import 'auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());
    final formKey = GlobalKey<FormState>();
    final phoneController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: RenewdSpacing.xl),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const SizedBox(height: RenewdSpacing.xxl),
                  _buildLogo(isDark),
                  const SizedBox(height: RenewdSpacing.xxxl),
                  _buildWelcomeText(isDark),
                  const SizedBox(height: RenewdSpacing.xxxl),
                  _buildPhoneField(phoneController, controller, isDark),
                  _buildError(controller),
                  const SizedBox(height: RenewdSpacing.xl),
                  _buildContinueButton(formKey, phoneController, controller),
                  const SizedBox(height: RenewdSpacing.xxl),
                  _buildTerms(isDark),
                  const SizedBox(height: RenewdSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            RenewdColors.oceanBlue,
            RenewdColors.oceanBlue.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: RenewdColors.oceanBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Icon(LucideIcons.refreshCcw, size: 40, color: Colors.white),
      ),
    );
  }

  Widget _buildWelcomeText(bool isDark) {
    return Column(
      children: [
        Text(
          'Renewd',
          style: GoogleFonts.dmSans(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : RenewdColors.deepNavy,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: RenewdSpacing.sm),
        Text(
          'Never miss a renewal again',
          style: RenewdTextStyles.body.copyWith(
            color: RenewdColors.slate,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(
    TextEditingController phoneController,
    AuthController controller,
    bool isDark,
  ) {
    return TextFormField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      style: RenewdTextStyles.body.copyWith(
        color: isDark ? Colors.white : RenewdColors.deepNavy,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: 'Phone number',
        hintText: '+91 9876543210',
        prefixIcon: Icon(LucideIcons.phone, size: 20),
        filled: true,
        fillColor: isDark
            ? RenewdColors.steel.withValues(alpha: 0.3)
            : RenewdColors.cloudGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: RenewdColors.oceanBlue,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: RenewdSpacing.lg,
          vertical: RenewdSpacing.lg,
        ),
      ),
      onChanged: (v) => controller.phone.value = v,
      validator: RenewdValidators.validatePhone,
    );
  }

  Widget _buildError(AuthController controller) => Obx(() {
        if (controller.errorMessage.value.isEmpty) {
          return const SizedBox(height: RenewdSpacing.sm);
        }
        return Padding(
          padding: const EdgeInsets.only(top: RenewdSpacing.sm),
          child: Text(
            controller.errorMessage.value,
            style: RenewdTextStyles.bodySmall
                .copyWith(color: RenewdColors.coralRed),
          ),
        );
      });

  Widget _buildContinueButton(
    GlobalKey<FormState> formKey,
    TextEditingController phoneController,
    AuthController controller,
  ) =>
      Obx(() => RenewdButton(
            label: 'Continue',
            isLoading: controller.isLoading.value,
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                controller.phone.value = phoneController.text;
                controller.sendOtp();
              }
            },
          ));

  Widget _buildTerms(bool isDark) {
    return Text(
      'By continuing, you agree to our Terms of Service\nand Privacy Policy',
      textAlign: TextAlign.center,
      style: RenewdTextStyles.caption.copyWith(
        color: RenewdColors.slate.withValues(alpha: 0.7),
        height: 1.5,
      ),
    );
  }
}
