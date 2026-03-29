import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_opacity.dart';

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            leading: IconButton(
              icon: Icon(LucideIcons.arrowLeft),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _HeroBanner(isDark: isDark),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(RenewdSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: RenewdSpacing.md),
                ..._features.map((f) => _FeatureCard(feature: f, isDark: isDark)),
                const SizedBox(height: RenewdSpacing.lg),
                _SecuritySection(isDark: isDark),
                const SizedBox(height: RenewdSpacing.xxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final bool isDark;
  const _HeroBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A5F),
            Color(0xFF3B82F6),
            Color(0xFF7C3AED),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              RenewdSpacing.xl, RenewdSpacing.lg, RenewdSpacing.xl, RenewdSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: RenewdOpacity.medium),
                      borderRadius: RenewdRadius.lgAll,
                    ),
                    child: Icon(LucideIcons.refreshCcw,
                        size: 24, color: Colors.white),
                  ),
                  const SizedBox(width: RenewdSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Renewd',
                          style: RenewdTextStyles.h1
                              .copyWith(color: Colors.white)),
                      Text('Never miss a renewal again',
                          style: RenewdTextStyles.bodySmall
                              .copyWith(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final _features = <_FeatureData>[
  _FeatureData(
    icon: LucideIcons.shieldCheck,
    color: RenewdColors.oceanBlue,
    title: 'Track All Renewals',
    subtitle: 'Insurance, subscriptions, government docs, utilities — everything in one place.',
    graphic: _GraphicType.cards,
  ),
  _FeatureData(
    icon: LucideIcons.bell,
    color: RenewdColors.tangerine,
    title: 'Smart Reminders',
    subtitle: 'Get notified 7 days and 1 day before expiry. Never pay a late fee again.',
    graphic: _GraphicType.timeline,
  ),
  _FeatureData(
    icon: LucideIcons.scanLine,
    color: RenewdColors.lavender,
    title: 'Scan & Auto-Fill',
    subtitle: 'Point your camera at any document. AI reads it and creates the renewal for you.',
    graphic: _GraphicType.scan,
  ),
  _FeatureData(
    icon: LucideIcons.fileText,
    color: RenewdColors.teal,
    title: 'Document Vault',
    subtitle: 'Store policy documents, receipts, and certificates. Search across all your files.',
    graphic: _GraphicType.vault,
  ),
  _FeatureData(
    icon: LucideIcons.layers,
    color: RenewdColors.rose,
    title: 'Organized by Category',
    subtitle: 'Browse by insurance, subscription, utility, or membership. See spending at a glance.',
    graphic: _GraphicType.categories,
  ),
];

enum _GraphicType { cards, timeline, scan, vault, categories }

class _FeatureData {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final _GraphicType graphic;

  const _FeatureData({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.graphic,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureData feature;
  final bool isDark;

  const _FeatureCard({required this.feature, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: RenewdSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? RenewdColors.darkSlate : Colors.white,
        borderRadius: RenewdRadius.xlAll,
      ),
      child: Column(
        children: [
          // Graphic area
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: feature.color.withValues(alpha: RenewdOpacity.subtle),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16)),
            ),
            child: _buildGraphic(feature),
          ),
          // Text area
          Padding(
            padding: const EdgeInsets.all(RenewdSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: feature.color.withValues(alpha: RenewdOpacity.light),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(feature.icon, size: 20, color: feature.color),
                ),
                const SizedBox(width: RenewdSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(feature.title,
                          style: RenewdTextStyles.body
                              .copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(feature.subtitle,
                          style: RenewdTextStyles.bodySmall
                              .copyWith(color: RenewdColors.slate, height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphic(_FeatureData f) {
    switch (f.graphic) {
      case _GraphicType.cards:
        return _CardsGraphic(color: f.color);
      case _GraphicType.timeline:
        return _TimelineGraphic(color: f.color);
      case _GraphicType.scan:
        return _ScanGraphic(color: f.color);
      case _GraphicType.vault:
        return _VaultGraphic(color: f.color);
      case _GraphicType.categories:
        return _CategoriesGraphic(color: f.color);
    }
  }
}

// ─── Mini graphics ────────────────────────────────────

class _CardsGraphic extends StatelessWidget {
  final Color color;
  const _CardsGraphic({required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final offset = (i - 1) * 8.0;
          final scale = i == 1 ? 1.0 : 0.85;
          return Transform.translate(
            offset: Offset(0, offset.abs()),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 80,
                height: 100,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: i == 1 ? RenewdOpacity.moderate : RenewdOpacity.medium),
                  borderRadius: RenewdRadius.mdAll,
                  border: Border.all(
                    color: color.withValues(alpha: i == 1 ? RenewdOpacity.half : RenewdOpacity.medium),
                  ),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: RenewdOpacity.moderate),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 50, height: 6,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: RenewdOpacity.moderate),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 30, height: 6,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: RenewdOpacity.medium),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TimelineGraphic extends StatelessWidget {
  final Color color;
  const _TimelineGraphic({required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _timelineDot(color, '30d', false),
          _timelineLine(color),
          _timelineDot(color, '7d', false),
          _timelineLine(color),
          _timelineDot(color, '1d', true),
          _timelineLine(color),
          Icon(LucideIcons.bell, size: 20, color: color),
        ],
      ),
    );
  }

  Widget _timelineDot(Color c, String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: active ? 20 : 14,
          height: active ? 20 : 14,
          decoration: BoxDecoration(
            color: active ? c : c.withValues(alpha: RenewdOpacity.medium),
            shape: BoxShape.circle,
            border: Border.all(color: c, width: 2),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
              fontSize: 10,
              color: c.withValues(alpha: RenewdOpacity.heavy),
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            )),
      ],
    );
  }

  Widget _timelineLine(Color c) {
    return Container(
      width: 32,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: c.withValues(alpha: RenewdOpacity.moderate),
    );
  }
}

class _ScanGraphic extends StatelessWidget {
  final Color color;
  const _ScanGraphic({required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Document
          Container(
            width: 90,
            height: 110,
            decoration: BoxDecoration(
              color: color.withValues(alpha: RenewdOpacity.medium),
              borderRadius: RenewdRadius.smAll,
              border: Border.all(color: color.withValues(alpha: RenewdOpacity.moderate)),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(5, (i) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  width: i == 0 ? 50 : (i == 4 ? 30 : 60),
                  height: 4,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: RenewdOpacity.medium),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              )),
            ),
          ),
          // Scan line
          Positioned(
            top: 30,
            child: Container(
              width: 100,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0),
                    color,
                    color.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          // Sparkle
          Positioned(
            right: 0,
            top: 10,
            child: Icon(LucideIcons.sparkles, size: 24, color: color),
          ),
        ],
      ),
    );
  }
}

class _VaultGraphic extends StatelessWidget {
  final Color color;
  const _VaultGraphic({required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(3, (i) {
          return Transform.translate(
            offset: Offset(0, i * -8.0),
            child: Container(
              width: 100 - i * 10,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1 + i * 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: color.withValues(alpha: 0.2 + i * 0.1),
                ),
              ),
              child: i == 2
                  ? Center(
                      child: Icon(LucideIcons.fileText,
                          size: 24, color: color),
                    )
                  : null,
            ),
          );
        }),
      ),
    );
  }
}

class _CategoriesGraphic extends StatelessWidget {
  final Color color;
  const _CategoriesGraphic({required this.color});

  @override
  Widget build(BuildContext context) {
    final colors = [
      RenewdColors.oceanBlue,
      RenewdColors.lavender,
      RenewdColors.tangerine,
      RenewdColors.emerald,
    ];
    final icons = [
      LucideIcons.shieldCheck,
      LucideIcons.refreshCcw,
      LucideIcons.zap,
      LucideIcons.crown,
    ];
    return Center(
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List.generate(4, (i) {
          return Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors[i].withValues(alpha: RenewdOpacity.medium),
              borderRadius: RenewdRadius.lgAll,
            ),
            child: Icon(icons[i], size: 24, color: colors[i]),
          );
        }),
      ),
    );
  }
}

// ─── Coming Soon ──────────────────────────────────────

class _SecuritySection extends StatelessWidget {
  final bool isDark;
  const _SecuritySection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(RenewdSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? RenewdColors.darkSlate : Colors.white,
        borderRadius: RenewdRadius.xlAll,
        border: Border.all(
          color: RenewdColors.emerald.withValues(alpha: RenewdOpacity.medium),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: RenewdColors.emerald.withValues(alpha: RenewdOpacity.light),
              borderRadius: RenewdRadius.lgAll,
            ),
            child: Icon(LucideIcons.shieldCheck,
                size: 24, color: RenewdColors.emerald),
          ),
          const SizedBox(height: RenewdSpacing.lg),
          Text('Your Data is Secure',
              style: RenewdTextStyles.h3
                  .copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: RenewdSpacing.md),
          _SecurityItem(
            icon: LucideIcons.lock,
            title: 'AES-256 Encryption',
            subtitle: 'All documents encrypted at rest using military-grade encryption',
          ),
          _SecurityItem(
            icon: LucideIcons.globe,
            title: 'Encrypted in Transit',
            subtitle: 'All data transferred over HTTPS/TLS secure connections',
          ),
          _SecurityItem(
            icon: LucideIcons.eyeOff,
            title: 'PII Masking',
            subtitle: 'Aadhaar and PAN numbers are automatically masked',
          ),
          _SecurityItem(
            icon: LucideIcons.cloudOff,
            title: 'Private Cloud Storage',
            subtitle: 'Documents stored in your own private S3 vault',
          ),
        ],
      ),
    );
  }
}

class _SecurityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SecurityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: RenewdSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: RenewdColors.emerald),
          const SizedBox(width: RenewdSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: RenewdTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: RenewdTextStyles.caption
                        .copyWith(color: RenewdColors.slate)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

