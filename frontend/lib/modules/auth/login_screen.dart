import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AuthController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: RenewdSpacing.xl),
            child: Column(
              children: [
                const SizedBox(height: RenewdSpacing.xl),
                _Logo(isDark: isDark),
                const SizedBox(height: RenewdSpacing.xxxl),
                _SocialButtons(c: c, isDark: isDark),
                const SizedBox(height: RenewdSpacing.xl),
                _OrDivider(isDark: isDark),
                const SizedBox(height: RenewdSpacing.xl),
                _PhoneSection(c: c, isDark: isDark),
                const SizedBox(height: RenewdSpacing.xxl),
                _Terms(),
                const SizedBox(height: RenewdSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final bool isDark;
  const _Logo({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: RenewdColors.oceanBlue,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(LucideIcons.refreshCcw, size: 36, color: Colors.white),
        ),
        const SizedBox(height: RenewdSpacing.lg),
        Text(
          'Renewd',
          style: GoogleFonts.manrope(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : RenewdColors.deepNavy,
          ),
        ),
        const SizedBox(height: RenewdSpacing.xs),
        Text('Never miss a renewal again',
            style: RenewdTextStyles.bodySmall
                .copyWith(color: RenewdColors.slate)),
      ],
    );
  }
}

class _SocialButtons extends StatelessWidget {
  final AuthController c;
  final bool isDark;
  const _SocialButtons({required this.c, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (Platform.isIOS) ...[
          _SocialButton(
            icon: Icons.apple,
            label: 'Continue with Apple',
            bgColor: isDark ? Colors.white : Colors.black,
            textColor: isDark ? Colors.black : Colors.white,
            onTap: c.signInWithApple,
          ),
          const SizedBox(height: RenewdSpacing.sm),
        ],
        _SocialButton(
          googleLogo: true,
          label: 'Continue with Google',
          bgColor: isDark ? RenewdColors.darkSlate : Colors.white,
          textColor: isDark ? Colors.white : RenewdColors.deepNavy,
          borderColor: isDark ? RenewdColors.darkBorder : RenewdColors.mist,
          onTap: c.signInWithGoogle,
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData? icon;
  final bool googleLogo;
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const _SocialButton({
    this.icon,
    this.googleLogo = false,
    required this.label,
    required this.bgColor,
    required this.textColor,
    this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: RenewdRadius.lgAll,
          border: borderColor != null
              ? Border.all(color: borderColor!)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(icon, size: 22, color: textColor),
            if (googleLogo)
              Text('G',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4285F4),
                  )),
            const SizedBox(width: RenewdSpacing.md),
            Text(label,
                style: RenewdTextStyles.body.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  final bool isDark;
  const _OrDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark ? RenewdColors.darkBorder : RenewdColors.mist;
    return Row(
      children: [
        Expanded(child: Container(height: 0.5, color: color)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: RenewdSpacing.lg),
          child: Text('or',
              style: RenewdTextStyles.caption
                  .copyWith(color: RenewdColors.slate)),
        ),
        Expanded(child: Container(height: 0.5, color: color)),
      ],
    );
  }
}

class _PhoneSection extends StatelessWidget {
  final AuthController c;
  final bool isDark;
  const _PhoneSection({required this.c, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: c.phoneController,
          keyboardType: TextInputType.phone,
          style: RenewdTextStyles.body.copyWith(
            color: isDark ? Colors.white : RenewdColors.deepNavy,
          ),
          decoration: InputDecoration(
            hintText: 'Enter your phone number',
            hintStyle: RenewdTextStyles.body
                .copyWith(color: RenewdColors.slate),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.phone, size: 18,
                      color: RenewdColors.slate),
                  const SizedBox(width: 8),
                  Text(c.dialCode,
                      style: RenewdTextStyles.body.copyWith(
                        color: isDark ? Colors.white : RenewdColors.deepNavy,
                      )),
                ],
              ),
            ),
          ),
          onChanged: (v) => c.phone.value = v,
          onSubmitted: (_) => c.sendOtp(),
        ),
        Obx(() {
          if (c.errorMessage.value.isEmpty) {
            return const SizedBox(height: RenewdSpacing.md);
          }
          return Padding(
            padding: const EdgeInsets.only(top: RenewdSpacing.sm),
            child: Text(c.errorMessage.value,
                style: RenewdTextStyles.caption
                    .copyWith(color: RenewdColors.coralRed)),
          );
        }),
        const SizedBox(height: RenewdSpacing.md),
        Obx(() => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: c.isLoading.value ? null : c.sendOtp,
                child: c.isLoading.value
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Continue with Phone'),
              ),
            )),
      ],
    );
  }
}

class _Terms extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
