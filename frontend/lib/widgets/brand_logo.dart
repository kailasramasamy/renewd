import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/constants/category_config.dart';
import '../data/models/renewal_model.dart';

class BrandLogo extends StatelessWidget {
  final RenewalModel renewal;
  final double size;

  const BrandLogo({super.key, required this.renewal, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final catColor = CategoryConfig.color(renewal.category);

    if (renewal.logoUrl != null && renewal.logoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.25),
        child: CachedNetworkImage(
          imageUrl: renewal.logoUrl!,
          width: size,
          height: size,
          fit: BoxFit.contain,
          placeholder: (_, _) => _FallbackIcon(
            category: renewal.category,
            color: catColor,
            size: size,
          ),
          errorWidget: (_, _, _) => _FallbackIcon(
            category: renewal.category,
            color: catColor,
            size: size,
          ),
        ),
      );
    }

    return _FallbackIcon(
      category: renewal.category,
      color: catColor,
      size: size,
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  final RenewalCategory category;
  final Color color;
  final double size;

  const _FallbackIcon({
    required this.category,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Icon(
        CategoryConfig.icon(category),
        size: size * 0.45,
        color: color,
      ),
    );
  }
}
