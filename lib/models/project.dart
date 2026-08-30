class Project {
  final String id;
  final String title;
  final String category;
  final String shortDescription;
  final String problem;
  final String whyItMatters;
  final String solution;
  final List<Map<String, String>> workflowSteps;
  final List<String> keyCapabilities;
  final String impact;
  final List<Map<String, String>> impactMetrics;
  final List<String> technologies;
  final String imageUrl;
  final String cloudinaryPublicId;
  final List<Map<String, String>> gallery;
  final bool isFeatured;
  final String status;

  Project({
    required this.id,
    required this.title,
    this.category = 'Engineering Solution',
    required this.shortDescription,
    this.problem = '',
    this.whyItMatters = '',
    this.solution = '',
    this.workflowSteps = const [],
    this.keyCapabilities = const [],
    this.impact = '',
    this.impactMetrics = const [],
    this.technologies = const [],
    this.imageUrl = '',
    this.cloudinaryPublicId = '',
    this.gallery = const [],
    this.isFeatured = false,
    this.status = 'Active',
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'Engineering Solution',
      shortDescription: json['shortDescription'] ?? '',
      problem: json['problem'] ?? '',
      whyItMatters: json['whyItMatters'] ?? '',
      solution: json['solution'] ?? '',
      workflowSteps: json['workflowSteps'] != null
          ? List<Map<String, String>>.from((json['workflowSteps'] as List).map((x) => {
              'title': x['title']?.toString() ?? '',
              'description': x['description']?.toString() ?? '',
            }))
          : [],
      keyCapabilities: json['keyCapabilities'] != null
          ? List<String>.from(json['keyCapabilities'])
          : [],
      impact: json['impact'] ?? '',
      impactMetrics: json['impactMetrics'] != null
          ? List<Map<String, String>>.from((json['impactMetrics'] as List).map((x) => {
              'metric': x['metric']?.toString() ?? '',
              'value': x['value']?.toString() ?? '',
              'description': x['description']?.toString() ?? '',
            }))
          : [],
      technologies: json['technologies'] != null
          ? List<String>.from(json['technologies'])
          : [],
      imageUrl: json['imageUrl'] ?? '',
      cloudinaryPublicId: json['cloudinaryPublicId'] ?? '',
      gallery: json['gallery'] != null
          ? List<Map<String, String>>.from((json['gallery'] as List).map((x) => {
              'url': x['url']?.toString() ?? '',
              'cloudinaryPublicId': x['cloudinaryPublicId']?.toString() ?? '',
            }))
          : [],
      isFeatured: json['isFeatured'] ?? false,
      status: json['status'] ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'shortDescription': shortDescription,
      'problem': problem,
      'whyItMatters': whyItMatters,
      'solution': solution,
      'workflowSteps': workflowSteps,
      'keyCapabilities': keyCapabilities,
      'impact': impact,
      'impactMetrics': impactMetrics,
      'technologies': technologies,
      'imageUrl': imageUrl,
      'cloudinaryPublicId': cloudinaryPublicId,
      'gallery': gallery,
      'isFeatured': isFeatured,
      'status': status,
    };
  }
}
