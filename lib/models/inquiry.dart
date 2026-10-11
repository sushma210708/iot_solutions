class InquiryResponse {
  final String message;
  final String subject;
  final String senderName;
  final String senderRole;
  final DateTime sentAt;
  final bool emailSent;
  final String emailProvider;
  final String emailError;

  InquiryResponse({
    required this.message,
    this.subject = '',
    this.senderName = 'Green Fusion Team',
    this.senderRole = 'admin',
    required this.sentAt,
    this.emailSent = true,
    this.emailProvider = '',
    this.emailError = '',
  });

  factory InquiryResponse.fromJson(Map<String, dynamic> json) {
    return InquiryResponse(
      message: json['message'] ?? '',
      subject: json['subject'] ?? '',
      senderName: json['senderName'] ?? 'Green Fusion Team',
      senderRole: json['senderRole'] ?? 'admin',
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : DateTime.now(),
      emailSent: json['emailSent'] == true,
      emailProvider: json['emailProvider'] ?? '',
      emailError: json['emailError'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'subject': subject,
    'senderName': senderName,
    'senderRole': senderRole,
    'sentAt': sentAt.toIso8601String(),
    'emailSent': emailSent,
    'emailProvider': emailProvider,
    'emailError': emailError,
  };
}

class Inquiry {
  final String id;
  final String inquiryId;
  final String name;
  final String email;
  final String phone;
  final String message;
  final String status;
  final String internalNotes;
  final bool emailNotificationSent;
  final String emailNotificationError;
  final String emailNotificationProvider;
  final DateTime createdAt;
  final List<InquiryResponse> responses;

  Inquiry({
    required this.id,
    required this.inquiryId,
    required this.name,
    required this.email,
    required this.phone,
    required this.message,
    required this.status,
    this.internalNotes = '',
    this.emailNotificationSent = false,
    this.emailNotificationError = '',
    this.emailNotificationProvider = '',
    required this.createdAt,
    this.responses = const [],
  });

  bool get hasCompanyReply => responses.isNotEmpty;
  InquiryResponse? get latestResponse => responses.isNotEmpty ? responses.last : null;

  factory Inquiry.fromJson(Map<String, dynamic> json) {
    bool emailSent = false;
    String emailError = '';
    String emailProvider = '';

    if (json['emailNotification'] != null && json['emailNotification'] is Map) {
      emailSent = json['emailNotification']['sent'] == true;
      emailError = json['emailNotification']['error'] ?? '';
      emailProvider = json['emailNotification']['provider'] ?? '';
    }

    String rawId = json['_id'] ?? '';
    String inqId = json['inquiryId'] ?? (rawId.isNotEmpty ? 'GF-${rawId.substring(rawId.length > 6 ? rawId.length - 6 : 0).toUpperCase()}' : 'GF-INQUIRY');

    final List<InquiryResponse> responseList = [];
    if (json['responses'] != null && json['responses'] is List) {
      for (final r in json['responses']) {
        if (r is Map<String, dynamic>) {
          responseList.add(InquiryResponse.fromJson(r));
        }
      }
    }

    return Inquiry(
      id: rawId,
      inquiryId: inqId,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 'New',
      internalNotes: json['internalNotes'] ?? '',
      emailNotificationSent: emailSent,
      emailNotificationError: emailError,
      emailNotificationProvider: emailProvider,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      responses: responseList,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'message': message,
    'status': status,
    'internalNotes': internalNotes,
    'responses': responses.map((r) => r.toJson()).toList(),
  };
}
