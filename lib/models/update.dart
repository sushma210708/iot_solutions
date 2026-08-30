class AppUpdate {
  final String id;
  final String title;
  final String shortDescription;
  final String fullContent;
  final String imageUrl;
  final String cloudinaryPublicId;
  final String category;
  final String status;
  final bool notifySubscribers;
  final bool notificationSent;
  final DateTime? createdAt;

  AppUpdate({
    required this.id,
    required this.title,
    required this.shortDescription,
    this.fullContent = '',
    this.imageUrl = '',
    this.cloudinaryPublicId = '',
    this.category = 'General',
    this.status = 'Draft',
    this.notifySubscribers = false,
    this.notificationSent = false,
    this.createdAt,
  });

  factory AppUpdate.fromJson(Map<String, dynamic> json) {
    return AppUpdate(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      shortDescription: json['shortDescription'] ?? '',
      fullContent: json['fullContent'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      cloudinaryPublicId: json['cloudinaryPublicId'] ?? '',
      category: json['category'] ?? 'General',
      status: json['status'] ?? 'Draft',
      notifySubscribers: json['notifySubscribers'] ?? false,
      notificationSent: json['notificationSent'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'shortDescription': shortDescription,
      'fullContent': fullContent,
      'imageUrl': imageUrl,
      'cloudinaryPublicId': cloudinaryPublicId,
      'category': category,
      'status': status,
      'notifySubscribers': notifySubscribers,
    };
  }
}
