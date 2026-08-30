class HeroContent {
  final String id;
  final String badge;
  final String titleLine1;
  final String titleLine2;
  final String description;
  final String imageUrl;
  final String cloudinaryPublicId;
  final String impactBackgroundUrl;
  final String impactBackgroundPublicId;

  HeroContent({
    required this.id,
    required this.badge,
    required this.titleLine1,
    required this.titleLine2,
    required this.description,
    required this.imageUrl,
    required this.cloudinaryPublicId,
    required this.impactBackgroundUrl,
    required this.impactBackgroundPublicId,
  });

  factory HeroContent.fromJson(Map<String, dynamic> json) {
    return HeroContent(
      id: json['_id'] ?? '',
      badge: json['badge'] ?? '',
      titleLine1: json['titleLine1'] ?? '',
      titleLine2: json['titleLine2'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      cloudinaryPublicId: json['cloudinaryPublicId'] ?? '',
      impactBackgroundUrl: json['impactBackgroundUrl'] ?? '',
      impactBackgroundPublicId: json['impactBackgroundPublicId'] ?? '',
    );
  }
}
