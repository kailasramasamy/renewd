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
      backgroundColor: MinderColors.softWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(MinderSpacing.xl),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: MinderSpacing.xxxl),
                _buildHeader(),
                const SizedBox(height: MinderSpacing.xxl),
                _buildPhoneField(phoneController, controller),
                const SizedBox(height: MinderSpacing.sm),
                _buildError(controller),
                const SizedBox(height: MinderSpacing.xl),
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
            'Minder',
            style: GoogleFonts.dmSans(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: MinderColors.oceanBlue,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: MinderSpacing.sm),
          Text('Track all your renewals in one place.',
              style: MinderTextStyles.body.copyWith(color: MinderColors.slate)),
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
        validator: MinderValidators.validatePhone,
      );

  Widget _buildError(AuthController controller) => Obx(() {
        if (controller.errorMessage.value.isEmpty) return const SizedBox.shrink();
        return Text(
          controller.errorMessage.value,
          style: MinderTextStyles.bodySmall.copyWith(color: MinderColors.coralRed),
        );
      });

  Widget _buildContinueButton(
    GlobalKey<FormState> formKey,
    TextEditingController phoneController,
    AuthController controller,
  ) =>
      Obx(() => MinderButton(
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
