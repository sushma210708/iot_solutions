class AdminUser {
  final String id;
  final String firebaseUid;
  final String name;
  final String email;
  final String role;
  final List<String> permissions;
  final String status;

  AdminUser({
    required this.id,
    required this.firebaseUid,
    required this.name,
    required this.email,
    required this.role,
    required this.permissions,
    required this.status,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['_id'] ?? '',
      firebaseUid: json['firebaseUid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'viewer',
      permissions: (json['permissions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      status: json['status'] ?? 'active',
    );
  }
}
