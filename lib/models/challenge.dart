class Challenge {
  final String id;
  final String title;
  final String description;
  final String domain;
  final String technology;
  final String outcome;
  final String imageUrl;
  final String status;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.domain,
    required this.technology,
    required this.outcome,
    required this.imageUrl,
    required this.status,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      domain: json['domain'] ?? '',
      technology: json['technology'] ?? '',
      outcome: json['outcome'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      status: json['status'] ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'domain': domain,
      'technology': technology,
      'outcome': outcome,
      'imageUrl': imageUrl,
      'status': status,
    };
  }
}
