class VegetableImage {
  final String url;
  final DateTime uploadedAt;
  final String status;

  VegetableImage({
    required this.url,
    required this.uploadedAt,
    required this.status,
  });

  factory VegetableImage.fromJson(Map<String, dynamic> json) {
    return VegetableImage(
      url: json['url'] as String,
      uploadedAt: json['uploadedAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['uploadedAt'] as int)
          : DateTime.parse(json['uploadedAt'] as String),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'uploadedAt': uploadedAt.toIso8601String(),
      'status': status,
    };
  }
}

class Vegetable {
  final String id;
  final String name;
  final String description;
  final String saleType;
  final int weightGrams;
  final int priceCents;
  final List<VegetableImage> images;
  final String ownerId;
  final DateTime createdAt;

  Vegetable({
    required this.id,
    required this.name,
    required this.description,
    required this.saleType,
    required this.weightGrams,
    required this.priceCents,
    required this.images,
    required this.ownerId,
    required this.createdAt,
  });

  factory Vegetable.fromJson(Map<String, dynamic> json) {
    return Vegetable(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      description: json['description'] as String,
      images: (json['images'] as List<dynamic>)
          .map((e) => VegetableImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String,
      ownerId: json['ownerId'] as String,
      priceCents: json['priceCents'] as int,
      saleType: json['saleType'] as String,
      weightGrams: json['weightGrams'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt.toIso8601String(),
      'description': description,
      'images': images.map((e) => e.toJson()).toList(),
      'name': name,
      'ownerId': ownerId,
      'priceCents': priceCents,
      'saleType': saleType,
      'weightGrams': weightGrams,
    };
  }
}
