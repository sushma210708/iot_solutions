class FooterLink {
  final String label;
  final String route;

  FooterLink({required this.label, required this.route});

  factory FooterLink.fromJson(Map<String, dynamic> json) {
    return FooterLink(
      label: json['label'] ?? '',
      route: json['route'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'route': route,
  };
}

class FooterSocialLink {
  final String platform;
  final String url;
  final String label;

  FooterSocialLink({required this.platform, required this.url, required this.label});

  factory FooterSocialLink.fromJson(Map<String, dynamic> json) {
    return FooterSocialLink(
      platform: json['platform'] ?? '',
      url: json['url'] ?? '',
      label: json['label'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'platform': platform,
    'url': url,
    'label': label,
  };
}

class FooterContent {
  final String companyName;
  final String companyDescription;
  final String address;
  final String businessHours;
  final String copyrightText;
  final List<String> phones;
  final List<String> emails;
  final List<FooterSocialLink> socialLinks;
  final List<FooterLink> quickLinks;
  final List<FooterLink> servicesLinks;
  final String aboutTeam;

  // Legacy fields
  final String phone1;
  final String phone2;
  final String phone3;
  final String email;
  final String instagram;

  FooterContent({
    required this.companyName,
    required this.companyDescription,
    required this.address,
    required this.businessHours,
    required this.copyrightText,
    required this.phones,
    required this.emails,
    required this.socialLinks,
    required this.quickLinks,
    required this.servicesLinks,
    required this.aboutTeam,
    this.phone1 = '',
    this.phone2 = '',
    this.phone3 = '',
    this.email = '',
    this.instagram = '',
  });

  factory FooterContent.fromJson(Map<String, dynamic> json) {
    List<String> parsedPhones = [];
    if (json['phones'] != null && json['phones'] is List) {
      parsedPhones = (json['phones'] as List).map((e) => e.toString()).toList();
    } else {
      if (json['phone1'] != null && json['phone1'].toString().isNotEmpty) parsedPhones.add(json['phone1'].toString());
      if (json['phone2'] != null && json['phone2'].toString().isNotEmpty) parsedPhones.add(json['phone2'].toString());
      if (json['phone3'] != null && json['phone3'].toString().isNotEmpty) parsedPhones.add(json['phone3'].toString());
    }

    List<String> parsedEmails = [];
    if (json['emails'] != null && json['emails'] is List) {
      parsedEmails = (json['emails'] as List).map((e) => e.toString()).toList();
    } else if (json['email'] != null && json['email'].toString().isNotEmpty) {
      parsedEmails.add(json['email'].toString());
    }

    List<FooterSocialLink> parsedSocial = [];
    if (json['socialLinks'] != null && json['socialLinks'] is List) {
      parsedSocial = (json['socialLinks'] as List)
          .map((e) => FooterSocialLink.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else if (json['instagram'] != null && json['instagram'].toString().isNotEmpty) {
      parsedSocial.add(FooterSocialLink(
        platform: 'instagram',
        url: 'https://instagram.com/greenfusioniotsolutions',
        label: json['instagram'].toString(),
      ));
    }

    List<FooterLink> parsedQuick = [];
    if (json['quickLinks'] != null && json['quickLinks'] is List) {
      parsedQuick = (json['quickLinks'] as List)
          .map((e) => FooterLink.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    List<FooterLink> parsedServices = [];
    if (json['servicesLinks'] != null && json['servicesLinks'] is List) {
      parsedServices = (json['servicesLinks'] as List)
          .map((e) => FooterLink.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return FooterContent(
      companyName: json['companyName'] ?? 'Green Fusion IoT Solutions',
      companyDescription: json['companyDescription'] ?? 'Revolutionizing energy management through IoT and AI-powered solutions.',
      address: json['address'] ?? 'Plot No. 42, Green Tech Park, Hyderabad, India',
      businessHours: json['businessHours'] ?? 'Mon - Fri: 9:00 AM - 6:00 PM IST',
      copyrightText: json['copyrightText'] ?? '© 2026 GreenFusion IoT Solutions. All rights reserved.',
      phones: parsedPhones.isNotEmpty ? parsedPhones : ['+91 6301644960', '+91 9398633736', '+91 9951012333'],
      emails: parsedEmails.isNotEmpty ? parsedEmails : ['info@gfiotsolutions.com'],
      socialLinks: parsedSocial,
      quickLinks: parsedQuick,
      servicesLinks: parsedServices,
      aboutTeam: json['aboutTeam'] ?? 'Our team of experts combines deep industry knowledge with cutting-edge technology expertise to deliver innovative energy solutions.',
      phone1: parsedPhones.isNotEmpty ? parsedPhones[0] : (json['phone1'] ?? ''),
      phone2: parsedPhones.length > 1 ? parsedPhones[1] : (json['phone2'] ?? ''),
      phone3: parsedPhones.length > 2 ? parsedPhones[2] : (json['phone3'] ?? ''),
      email: parsedEmails.isNotEmpty ? parsedEmails[0] : (json['email'] ?? ''),
      instagram: json['instagram'] ?? '@greenfusioniotsolutions',
    );
  }

  Map<String, dynamic> toJson() => {
    'companyName': companyName,
    'companyDescription': companyDescription,
    'address': address,
    'businessHours': businessHours,
    'copyrightText': copyrightText,
    'phones': phones,
    'emails': emails,
    'socialLinks': socialLinks.map((e) => e.toJson()).toList(),
    'quickLinks': quickLinks.map((e) => e.toJson()).toList(),
    'servicesLinks': servicesLinks.map((e) => e.toJson()).toList(),
    'aboutTeam': aboutTeam,
    'phone1': phones.isNotEmpty ? phones[0] : '',
    'phone2': phones.length > 1 ? phones[1] : '',
    'phone3': phones.length > 2 ? phones[2] : '',
    'email': emails.isNotEmpty ? emails[0] : '',
    'instagram': instagram,
  };
}
