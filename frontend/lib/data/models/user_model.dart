class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final bool isPremium;
  final DateTime? premiumExpiresAt;
  final String defaultCurrency;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    required this.isPremium,
    this.premiumExpiresAt,
    this.defaultCurrency = 'INR',
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        isPremium: json['is_premium'] as bool? ?? false,
        premiumExpiresAt: json['premium_expires_at'] != null
            ? DateTime.tryParse(json['premium_expires_at'] as String)
            : null,
        defaultCurrency: json['default_currency'] as String? ?? 'INR',
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'avatar_url': avatarUrl,
        'is_premium': isPremium,
        'premium_expires_at': premiumExpiresAt?.toIso8601String(),
        'default_currency': defaultCurrency,
        'created_at': createdAt.toIso8601String(),
      };

  UserModel copyWith({
    String? name,
    String? phone,
    String? avatarUrl,
    bool? isPremium,
    DateTime? premiumExpiresAt,
    String? defaultCurrency,
  }) =>
      UserModel(
        id: id,
        name: name ?? this.name,
        email: email,
        phone: phone ?? this.phone,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isPremium: isPremium ?? this.isPremium,
        premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
        defaultCurrency: defaultCurrency ?? this.defaultCurrency,
        createdAt: createdAt,
      );
}
