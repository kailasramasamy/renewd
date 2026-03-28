class PaymentModel {
  final String id;
  final String userId;
  final String renewalId;
  final double amount;
  final DateTime paidDate;
  final String? method;
  final String? referenceNumber;
  final String? receiptDocumentId;
  final DateTime createdAt;

  const PaymentModel({
    required this.id,
    required this.userId,
    required this.renewalId,
    required this.amount,
    required this.paidDate,
    this.method,
    this.referenceNumber,
    this.receiptDocumentId,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        renewalId: json['renewal_id'] as String,
        amount: double.parse(json['amount'].toString()),
        paidDate: DateTime.parse(json['paid_date'] as String),
        method: json['method'] as String?,
        referenceNumber: json['reference_number'] as String?,
        receiptDocumentId: json['receipt_document_id'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'renewal_id': renewalId,
        'amount': amount,
        'paid_date': paidDate.toIso8601String(),
        'method': method,
        'reference_number': referenceNumber,
        'receipt_document_id': receiptDocumentId,
        'created_at': createdAt.toIso8601String(),
      };
}
