class Inquiry {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String message;
  final String status;
  final DateTime createdAt;

  Inquiry({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) {
    return Inquiry(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 'New',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
