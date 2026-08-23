class ProductImage {
  final String url;
  final String publicId;

  ProductImage({required this.url, required this.publicId});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      url: json['url'] ?? '',
      publicId: json['cloudinaryPublicId'] ?? json['publicId'] ?? '',
    );
  }
}

class ProductSpec {
  final String parameter;
  final String value;

  ProductSpec({required this.parameter, required this.value});

  factory ProductSpec.fromJson(Map<String, dynamic> json) {
    return ProductSpec(
      parameter: json['parameter'] ?? '',
      value: json['value'] ?? '',
    );
  }
}

class Product {
  final String id;
  final String title;
  final String shortTitle;
  final String category;
  final String shortDescription;
  final String detailedDescription;
  final List<String> benefits;
  final List<ProductSpec> specifications;
  final List<String> parameters;
  final List<String> technologies;
  final String year;
  final String status;
  final List<ProductImage> images;

  Product({
    required this.id,
    required this.title,
    required this.shortTitle,
    required this.category,
    required this.shortDescription,
    required this.detailedDescription,
    required this.benefits,
    required this.specifications,
    required this.parameters,
    required this.technologies,
    required this.year,
    required this.status,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Backwards compatibility for images
    List<ProductImage> parsedImages = [];
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      parsedImages = (json['images'] as List<dynamic>).map((e) => ProductImage.fromJson(e)).toList();
    } else if (json['imageUrl'] != null && json['imageUrl'].toString().isNotEmpty) {
      parsedImages = [ProductImage(url: json['imageUrl'], publicId: json['cloudinaryPublicId'] ?? '')];
    }

    // Backwards compatibility for arrays (Mongoose might return [] instead of null)
    List<dynamic> rawBenefits = (json['benefits'] as List<dynamic>?) ?? [];
    if (rawBenefits.isEmpty && json['keyBenefits'] != null) {
      rawBenefits = json['keyBenefits'] as List<dynamic>;
    }

    List<dynamic> rawSpecs = (json['specifications'] as List<dynamic>?) ?? [];
    if (rawSpecs.isEmpty && json['technicalSpecifications'] != null) {
      rawSpecs = json['technicalSpecifications'] as List<dynamic>;
    }

    return Product(
      id: json['_id'] ?? '',
      title: json['title'] ?? json['name'] ?? 'Unknown',
      shortTitle: json['shortTitle'] ?? '',
      category: json['category'] ?? 'Uncategorized',
      shortDescription: json['shortDescription'] ?? json['description'] ?? '',
      detailedDescription: json['detailedDescription'] ?? json['description'] ?? '',
      benefits: rawBenefits.map((e) => e.toString()).toList(),
      specifications: rawSpecs.map((e) => ProductSpec.fromJson(e)).toList(),
      parameters: (json['parameters'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      technologies: (json['technologies'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      year: json['year']?.toString() ?? '',
      status: json['status'] ?? 'Active',
      images: parsedImages,
    );
  }
}
