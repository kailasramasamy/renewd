import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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

    return Scaffold(
      backgroundColor: RenewdColors.softWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(RenewdSpacing.xl),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: RenewdSpacing.xxxl),
                _buildHeader(),
                const SizedBox(height: RenewdSpacing.xxl),
                _buildPhoneField(phoneController, controller),
                const SizedBox(height: RenewdSpacing.sm),
                _buildError(controller),
                const SizedBox(height: RenewdSpacing.xl),
                _buildContinueButton(formKey, phoneController, controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Renewd',
            style: GoogleFonts.dmSans(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: RenewdColors.oceanBlue,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: RenewdSpacing.sm),
          Text('Track all your renewals in one place.',
              style: RenewdTextStyles.body.copyWith(color: RenewdColors.slate)),
        ],
      );

  Widget _buildPhoneField(
    TextEditingController phoneController,
    AuthController controller,
  ) =>
      TextFormField(
        controller: phoneController,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          labelText: 'Phone number',
          hintText: '+91 9876543210',
          prefixIcon: Icon(Icons.phone_outlined),
        ),
        onChanged: (v) => controller.phone.value = v,
        validator: RenewdValidators.validatePhone,
      );

  Widget _buildError(AuthController controller) => Obx(() {
        if (controller.errorMessage.value.isEmpty) return const SizedBox.shrink();
        return Text(
          controller.errorMessage.value,
          style: RenewdTextStyles.bodySmall.copyWith(color: RenewdColors.coralRed),
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
}
