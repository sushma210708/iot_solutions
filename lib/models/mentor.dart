class Mentor {
  final String id;
  final String name;
  final String role;
  final String imageUrl;
  final String cloudinaryPublicId;
  final String bio;
  final List<String> contributions;

  Mentor({
    required this.id,
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.cloudinaryPublicId,
    required this.bio,
    required this.contributions,
  });

  factory Mentor.fromJson(Map<String, dynamic> json) {
    return Mentor(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      cloudinaryPublicId: json['cloudinaryPublicId'] ?? '',
      bio: json['bio'] ?? '',
      contributions: List<String>.from(json['contributions'] ?? []),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'imageUrl': imageUrl,
      'cloudinaryPublicId': cloudinaryPublicId,
      'bio': bio,
      'contributions': contributions,
    };
  }
}
