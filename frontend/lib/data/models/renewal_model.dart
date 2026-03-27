import '../../core/constants/category_config.dart';
import '../../core/utils/date_utils.dart';

class RenewalModel {
  final String id;
  final String userId;
  final String name;
  final RenewalCategory category;
  final String? provider;
  final double? amount;
  final DateTime renewalDate;
  final String? frequency;
  final int? frequencyDays;
  final bool autoRenew;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RenewalModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    this.provider,
    this.amount,
    required this.renewalDate,
    this.frequency,
    this.frequencyDays,
    required this.autoRenew,
    this.notes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  int get daysRemaining => MinderDateUtils.daysRemaining(renewalDate);

  factory RenewalModel.fromJson(Map<String, dynamic> json) => RenewalModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        name: json['name'] as String,
        category: RenewalCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => RenewalCategory.other,
        ),
        provider: json['provider'] as String?,
        amount: json['amount'] != null
            ? double.tryParse(json['amount'].toString())
            : null,
        renewalDate: DateTime.parse(json['renewal_date'] as String),
        frequency: json['frequency'] as String?,
        frequencyDays: json['frequency_days'] as int?,
        autoRenew: json['auto_renew'] as bool? ?? false,
        notes: json['notes'] as String?,
        status: json['status'] as String? ?? 'active',
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'category': category.name,
        'provider': provider,
        'amount': amount,
        'renewal_date': renewalDate.toIso8601String(),
        'frequency': frequency,
        'frequency_days': frequencyDays,
        'auto_renew': autoRenew,
        'notes': notes,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
