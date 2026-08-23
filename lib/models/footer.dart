class FooterContent {
  final String companyDescription;
  final String email;
  final String phone1;
  final String phone2;
  final String phone3;
  final String instagram;
  final String aboutTeam;

  FooterContent({
    required this.companyDescription,
    required this.email,
    required this.phone1,
    required this.phone2,
    required this.phone3,
    required this.instagram,
    required this.aboutTeam,
  });

  factory FooterContent.fromJson(Map<String, dynamic> json) {
    return FooterContent(
      companyDescription: json['companyDescription'] ?? '',
      email: json['email'] ?? '',
      phone1: json['phone1'] ?? '',
      phone2: json['phone2'] ?? '',
      phone3: json['phone3'] ?? '',
      instagram: json['instagram'] ?? '',
      aboutTeam: json['aboutTeam'] ?? '',
    );
  }
}
