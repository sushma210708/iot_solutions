class AboutUs {
  final String heroTitle;
  final String heroSubtitle;
  final String storyTitle;
  final String storyDescription;
  final String storyImageUrl;
  final String visionTitle;
  final String visionDescription;
  final String missionTitle;
  final String missionDescription;
  final String capabilitiesTitle;
  final String capabilitiesSubtitle;
  final List<AboutCapability> capabilities;

  AboutUs({
    required this.heroTitle,
    required this.heroSubtitle,
    required this.storyTitle,
    required this.storyDescription,
    required this.storyImageUrl,
    required this.visionTitle,
    required this.visionDescription,
    required this.missionTitle,
    required this.missionDescription,
    required this.capabilitiesTitle,
    required this.capabilitiesSubtitle,
    required this.capabilities,
  });

  factory AboutUs.fromJson(Map<String, dynamic> json) {
    return AboutUs(
      heroTitle: json['heroTitle'] ?? '',
      heroSubtitle: json['heroSubtitle'] ?? '',
      storyTitle: json['storyTitle'] ?? '',
      storyDescription: json['storyDescription'] ?? '',
      storyImageUrl: json['storyImageUrl'] ?? '',
      visionTitle: json['visionTitle'] ?? '',
      visionDescription: json['visionDescription'] ?? '',
      missionTitle: json['missionTitle'] ?? '',
      missionDescription: json['missionDescription'] ?? '',
      capabilitiesTitle: json['capabilitiesTitle'] ?? '',
      capabilitiesSubtitle: json['capabilitiesSubtitle'] ?? '',
      capabilities: (json['capabilities'] as List<dynamic>?)
              ?.map((e) => AboutCapability.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heroTitle': heroTitle,
      'heroSubtitle': heroSubtitle,
      'storyTitle': storyTitle,
      'storyDescription': storyDescription,
      'storyImageUrl': storyImageUrl,
      'visionTitle': visionTitle,
      'visionDescription': visionDescription,
      'missionTitle': missionTitle,
      'missionDescription': missionDescription,
      'capabilitiesTitle': capabilitiesTitle,
      'capabilitiesSubtitle': capabilitiesSubtitle,
      'capabilities': capabilities.map((e) => e.toJson()).toList(),
    };
  }
}

class AboutCapability {
  final String title;
  final String description;

  AboutCapability({
    required this.title,
    required this.description,
  });

  factory AboutCapability.fromJson(Map<String, dynamic> json) {
    return AboutCapability(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }
}
