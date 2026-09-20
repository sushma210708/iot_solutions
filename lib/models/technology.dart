class TechnologyDomain {
  final String title;
  final String description;
  final List<String> bullets;
  final String imageUrl;

  TechnologyDomain({
    required this.title,
    required this.description,
    required this.bullets,
    required this.imageUrl,
  });

  factory TechnologyDomain.fromJson(Map<String, dynamic> json) {
    return TechnologyDomain(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      bullets: List<String>.from(json['bullets'] ?? []),
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'bullets': bullets,
      'imageUrl': imageUrl,
    };
  }
}

class Technology {
  final String headerTitle;
  final String mainTitle;
  final String mainSubtitle;
  final String coreDomainsHeader;
  final String coreDomainsTitle;
  final List<TechnologyDomain> domains;

  Technology({
    required this.headerTitle,
    required this.mainTitle,
    required this.mainSubtitle,
    required this.coreDomainsHeader,
    required this.coreDomainsTitle,
    required this.domains,
  });

  factory Technology.fromJson(Map<String, dynamic> json) {
    var list = json['domains'] as List? ?? [];
    List<TechnologyDomain> domainsList = list.map((i) => TechnologyDomain.fromJson(i)).toList();

    return Technology(
      headerTitle: json['headerTitle'] ?? '',
      mainTitle: json['mainTitle'] ?? '',
      mainSubtitle: json['mainSubtitle'] ?? '',
      coreDomainsHeader: json['coreDomainsHeader'] ?? '',
      coreDomainsTitle: json['coreDomainsTitle'] ?? '',
      domains: domainsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'headerTitle': headerTitle,
      'mainTitle': mainTitle,
      'mainSubtitle': mainSubtitle,
      'coreDomainsHeader': coreDomainsHeader,
      'coreDomainsTitle': coreDomainsTitle,
      'domains': domains.map((e) => e.toJson()).toList(),
    };
  }
}

