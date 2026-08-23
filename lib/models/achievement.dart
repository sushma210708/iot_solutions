class Achievement {
  final String id;
  final String title;
  final String description;
  final int year;
  final String imageUrl;
  final String cloudinaryPublicId;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.year,
    required this.imageUrl,
    required this.cloudinaryPublicId,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      year: json['year'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      cloudinaryPublicId: json['cloudinaryPublicId'] ?? '',
    );
  }
}
