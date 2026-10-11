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
  });

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
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'message': message,
    'status': status,
    'internalNotes': internalNotes,
  };
}
