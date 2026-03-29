import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/routes/app_routes.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_opacity.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = <_PageData>[
    _PageData(
      icon: LucideIcons.refreshCcw,
      color: Color(0xFF3B82F6),
      title: 'Never Miss a Renewal',
      subtitle:
          'Track insurance policies, subscriptions, government docs, and utilities — all in one place.',
    ),
    _PageData(
      icon: LucideIcons.scanLine,
      color: Color(0xFF8B5CF6),
      title: 'Scan & Auto-Fill',
      subtitle:
          'Point your camera at any document. AI reads it and creates the renewal for you instantly.',
    ),
    _PageData(
      icon: LucideIcons.bell,
      color: Color(0xFFF59E0B),
      title: 'Smart Reminders',
      subtitle:
          'Get notified before renewals expire. No more late fees or lapsed policies.',
    ),
    _PageData(
      icon: LucideIcons.sparkles,
      color: Color(0xFF10B981),
      title: 'AI-Powered Insights',
      subtitle:
          'Ask questions about your spending, upcoming dues, and get personalized suggestions.',
    ),
    _PageData(
      icon: LucideIcons.shieldCheck,
      color: Color(0xFF10B981),
      title: 'Bank-Grade Security',
      subtitle:
          'Your documents are protected with AES-256 encryption. Aadhaar & PAN numbers are automatically masked. Your data stays private.',
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  void _complete() {
    Get.find<StorageService>().setOnboardingComplete();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(RenewdSpacing.lg),
                child: _currentPage < _pages.length - 1
                    ? GestureDetector(
                        onTap: _complete,
                        child: Text('Skip',
                            style: RenewdTextStyles.body
                                .copyWith(color: RenewdColors.slate)),
                      )
                    : const SizedBox(height: 24),
              ),
            ),
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) =>
                    _OnboardingPage(data: _pages[i], isDark: isDark),
              ),
            ),
            // Dots + button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  RenewdSpacing.xl, 0, RenewdSpacing.xl, RenewdSpacing.xxl),
              child: Row(
                children: [
                  // Dots
                  Row(
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 6),
                        width: i == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? _pages[_currentPage].color
                              : (isDark
                                  ? RenewdColors.steel
                                  : RenewdColors.mist),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Next / Get Started button
                  GestureDetector(
                    onTap: _next,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: _currentPage == _pages.length - 1
                            ? RenewdSpacing.xl
                            : RenewdSpacing.lg,
                        vertical: RenewdSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: _pages[_currentPage].color,
                        borderRadius: RenewdRadius.lgAll,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage == _pages.length - 1
                                ? 'Get Started'
                                : 'Next',
                            style: RenewdTextStyles.body.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_currentPage < _pages.length - 1) ...[
                            const SizedBox(width: 4),
                            const Icon(LucideIcons.arrowRight,
                                size: 18, color: Colors.white),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageData {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _PageData({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _PageData data;
  final bool isDark;

  const _OnboardingPage({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: RenewdSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon in colored circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: RenewdOpacity.light),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 52, color: data.color),
          ),
          const SizedBox(height: RenewdSpacing.xxxl),
          Text(
            data.title,
            style: RenewdTextStyles.h1.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: RenewdSpacing.md),
          Text(
            data.subtitle,
            style: RenewdTextStyles.body.copyWith(
              color: RenewdColors.slate,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
