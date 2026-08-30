class Testimonial {
  final String id;
  final String quote;
  final String organization;
  final String personName;
  final String designation;
  final String status;

  Testimonial({
    required this.id,
    required this.quote,
    required this.organization,
    required this.personName,
    required this.designation,
    required this.status,
  });

  factory Testimonial.fromJson(Map<String, dynamic> json) {
    return Testimonial(
      id: json['_id'] ?? '',
      quote: json['quote'] ?? '',
      organization: json['organization'] ?? '',
      personName: json['personName'] ?? '',
      designation: json['designation'] ?? '',
      status: json['status'] ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quote': quote,
      'organization': organization,
      'personName': personName,
      'designation': designation,
      'status': status,
    };
  }
}
