class DocumentModel {
  final String id;
  final String userId;
  final String? renewalId;
  final String fileUrl;
  final String fileName;
  final int fileSize;
  final String mimeType;
  final String? docType;
  final String? ocrText;
  final bool isCurrent;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final DateTime createdAt;

  const DocumentModel({
    required this.id,
    required this.userId,
    this.renewalId,
    required this.fileUrl,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    this.docType,
    this.ocrText,
    required this.isCurrent,
    this.issueDate,
    this.expiryDate,
    required this.createdAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        renewalId: json['renewal_id'] as String?,
        fileUrl: json['file_url'] as String,
        fileName: json['file_name'] as String,
        fileSize: json['file_size'] as int,
        mimeType: json['mime_type'] as String,
        docType: json['doc_type'] as String?,
        ocrText: json['ocr_text'] as String?,
        isCurrent: json['is_current'] as bool? ?? true,
        issueDate: json['issue_date'] != null
            ? DateTime.parse(json['issue_date'] as String)
            : null,
        expiryDate: json['expiry_date'] != null
            ? DateTime.parse(json['expiry_date'] as String)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'renewal_id': renewalId,
        'file_url': fileUrl,
        'file_name': fileName,
        'file_size': fileSize,
        'mime_type': mimeType,
        'doc_type': docType,
        'ocr_text': ocrText,
        'is_current': isCurrent,
        'issue_date': issueDate?.toIso8601String(),
        'expiry_date': expiryDate?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}
