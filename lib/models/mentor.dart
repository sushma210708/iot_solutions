class Mentor {
  final String id;
  final String name;
  final String role;
  final String imageUrl;
  final String cloudinaryPublicId;

  Mentor({
    required this.id,
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.cloudinaryPublicId,
  });

  factory Mentor.fromJson(Map<String, dynamic> json) {
    return Mentor(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      cloudinaryPublicId: json['cloudinaryPublicId'] ?? '',
    );
  }
}
