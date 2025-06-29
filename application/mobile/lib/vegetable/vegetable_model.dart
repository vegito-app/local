import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vegito/config.dart';
import 'package:vegito/vegetable/vegetable_upload/vegetable_sale_details_section.dart';

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
      servedByCdn: json['servedByCdn'] as bool?,
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
  final SaleType saleType;
  final int priceCents;
  final List<VegetableImage> images;
  final String ownerId;
  final DateTime createdAt;
  final bool active;
  final AvailabilityType availabilityType;
  final DateTime? availabilityDate;
  final int quantityAvailable;
  final LatLng? deliveryLocation;
  final double deliveryRadiusKm;

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
    this.deliveryLocation,
    this.deliveryRadiusKm = 0.0,
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
      saleType: json['saleType'] == 'weight' ? SaleType.weight : SaleType.unit,
      active: json['active'] as bool? ?? true,
      availabilityType: json['availabilityType'] == 'futureDate'
          ? AvailabilityType.futureDate
          : json['availabilityType'] == 'alreadyHarvested'
              ? AvailabilityType.alreadyHarvested
              : AvailabilityType.sameDay,
      availabilityDate: json['availabilityDate'] != null
          ? DateTime.parse(json['availabilityDate'] as String)
          : null,
      quantityAvailable: json['quantityAvailable'] as int,
      deliveryLocation: json['latitude'] != null && json['longitude'] != null
          ? LatLng(
              (json['latitude'] as num).toDouble(),
              (json['longitude'] as num).toDouble(),
            )
          : null,
      deliveryRadiusKm: (json['deliveryRadiusKm'] as num?)!.toDouble(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'images': images.map((e) => e.toJson()).toList(),
      'name': name,
      'ownerId': ownerId,
      'priceCents': priceCents,
      'saleType': saleType.name,
      'active': active,
      'availabilityType': availabilityType.name,
      'availabilityDate': availabilityDate?.toUtc().toIso8601String(),
      'quantityAvailable': quantityAvailable,
      'latitude': deliveryLocation?.latitude,
      'longitude': deliveryLocation?.longitude,
      'deliveryRadiusKm': deliveryRadiusKm,
    };
  }

  bool get isAvailableNow {
    if (availabilityType == AvailabilityType.sameDay) return true;
    if (availabilityType == AvailabilityType.futureDate &&
        availabilityDate != null) {
      return DateTime.now().isAfter(availabilityDate!);
    }
    return false;
  }

  bool get isAvailableForDelivery {
    return deliveryLocation != null && deliveryRadiusKm != null;
  }

  String get formattedPrice {
    final price = priceCents / 100;
    return '${price.toStringAsFixed(2)} €';
  }

  String get formattedAvailability {
    if (availabilityType == AvailabilityType.sameDay) {
      return 'Disponible aujourd’hui';
    } else if (availabilityType == AvailabilityType.futureDate &&
        availabilityDate != null) {
      return 'Disponible le ${availabilityDate!.toLocal().toIso8601String().split('T')[0]}';
    } else {
      return 'Disponible en stock';
    }
  }
}
