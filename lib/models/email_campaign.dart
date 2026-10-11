class EmailRecipient {
  final String id;
  final String name;
  final String email;
  final String role;
  final String status;

  EmailRecipient({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'user',
    this.status = 'active',
  });

  factory EmailRecipient.fromJson(Map<String, dynamic> json) {
    return EmailRecipient(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'User',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      status: json['status'] ?? 'active',
    );
  }
}

class EmailCampaign {
  final String id;
  final String campaignId;
  final String subject;
  final String message;
  final String emailType;
  final String recipientType;
  final int recipientCount;
  final String sentByName;
  final String status;
  final int totalSent;
  final int successfulSent;
  final int failedSent;
  final DateTime createdAt;

  EmailCampaign({
    required this.id,
    required this.campaignId,
    required this.subject,
    required this.message,
    required this.emailType,
    required this.recipientType,
    required this.recipientCount,
    required this.sentByName,
    required this.status,
    required this.totalSent,
    required this.successfulSent,
    required this.failedSent,
    required this.createdAt,
  });

  factory EmailCampaign.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] ?? {};
    return EmailCampaign(
      id: json['_id'] ?? '',
      campaignId: json['campaignId'] ?? '',
      subject: json['subject'] ?? '',
      message: json['message'] ?? '',
      emailType: json['emailType'] ?? 'announcement',
      recipientType: json['recipientType'] ?? 'all',
      recipientCount: json['recipientCount'] ?? 0,
      sentByName: json['sentByName'] ?? 'Administrator',
      status: json['status'] ?? 'sent',
      totalSent: stats['total'] ?? (json['recipientCount'] ?? 0),
      successfulSent: stats['successful'] ?? 0,
      failedSent: stats['failed'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
