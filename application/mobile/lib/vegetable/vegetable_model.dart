import 'package:car2go/config.dart';

class VegetableImage {
  final DateTime uploadedAt;
  final String status;
  final String path;
  final bool? servedByCdn;
  final String? downloadToken;
  VegetableImage({
    required this.path,
    required this.uploadedAt,
    required this.status,
    this.servedByCdn,
    this.downloadToken,
  });

  factory VegetableImage.fromJson(Map<String, dynamic> json) {
    return VegetableImage(
      path: json['path'] as String,
      uploadedAt: json['uploadedAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['uploadedAt'] as int)
          : DateTime.parse(json['uploadedAt'] as String),
      status: json['status'] as String,
      servedByCdn: json['servedByCdn'] as bool,
      downloadToken: json['downloadToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'uploadedAt': uploadedAt.toIso8601String(),
      'status': status,
      'servedByCdn': servedByCdn,
      'downloadToken': downloadToken,
    };
  }

  String get publicUrl {
    if (path.isEmpty) return '';
    if (servedByCdn == true) {
      return '${Config.cdnPublicPrefix}/$path';
    } else {
      final encodedPath =
          Uri.encodeComponent(path); // ← c'est ici qu'il fallait corriger
      final tokenPart = downloadToken != null ? '&token=$downloadToken' : '';
      return '${Config.firebaseStoragePublicPrefix}/$encodedPath?alt=media$tokenPart';
    }
  }
}

class Vegetable {
  final String id;
  final String name;
  final String description;
  final String saleType;
  final int priceCents;
  final List<VegetableImage> images;
  final String ownerId;
  final DateTime createdAt;
  final bool active;
  final String availabilityType;
  final DateTime? availabilityDate;
  final int quantityAvailable;

  Vegetable({
    required this.id,
    required this.name,
    required this.description,
    required this.saleType,
    required this.priceCents,
    required this.images,
    required this.ownerId,
    required this.createdAt,
    required this.active,
    required this.availabilityType,
    required this.availabilityDate,
    required this.quantityAvailable,
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
      // weightGrams: json['weightGrams'] as int,
      active: json['active'] as bool? ?? true,
      availabilityType: json['availabilityType'] as String,
      availabilityDate: json['availabilityDate'] != null
          ? DateTime.parse(json['availabilityDate'] as String)
          : null,
      quantityAvailable: json['quantityAvailable'] as int,
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
      'active': active,
      'availabilityType': availabilityType,
      'availabilityDate': availabilityDate?.toIso8601String(),
      'quantityAvailable': quantityAvailable,
    };
  }
}
