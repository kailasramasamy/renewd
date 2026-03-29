class BannerModel {
  final String id;
  final String title;
  final String? subtitle;
  final String type;
  final String? bgColor;
  final String? bgGradientStart;
  final String? bgGradientEnd;
  final String? icon;
  final String? imageUrl;
  final String? deeplink;
  final String? externalUrl;

  const BannerModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.type,
    this.bgColor,
    this.bgGradientStart,
    this.bgGradientEnd,
    this.icon,
    this.imageUrl,
    this.deeplink,
    this.externalUrl,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String?,
        type: json['type'] as String? ?? 'info',
        bgColor: json['bg_color'] as String?,
        bgGradientStart: json['bg_gradient_start'] as String?,
        bgGradientEnd: json['bg_gradient_end'] as String?,
        icon: json['icon'] as String?,
        imageUrl: json['image_url'] as String?,
        deeplink: json['deeplink'] as String?,
        externalUrl: json['external_url'] as String?,
      );
}
