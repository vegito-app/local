import 'package:cloud_firestore/cloud_firestore.dart';

class VegetableImage {
  final String url;
  final int uploadedAt;
  final String status;

  VegetableImage({
    required this.url,
    required this.uploadedAt,
    required this.status,
  });

  factory VegetableImage.fromJson(Map<String, dynamic> json) {
    return VegetableImage(
      url: json['url'] as String,
      uploadedAt: json['uploadedAt'] as int,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'uploadedAt': uploadedAt,
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
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : (json['createdAt'] as DateTime),
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
      'createdAt':
          createdAt is DateTime ? Timestamp.fromDate(createdAt) : createdAt,
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
