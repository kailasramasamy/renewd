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
          style: GoogleFonts.plusJakartaSans(
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
                  style: GoogleFonts.plusJakartaSans(
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
