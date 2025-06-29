import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:vegito/config.dart';
import 'package:vegito/http/auth_headers.dart';
import 'package:vegito/vegetable/vegetable_model.dart';

class VegetableService {
  final http.Client client;
  final String backendUrl;
  VegetableService({http.Client? client, String? backendUrl})
      : client = client ?? http.Client(),
        backendUrl = backendUrl ?? Config.backendUrl;

  Future<List<Vegetable>> listVegetables() async {
    final response = await client.get(
      Uri.parse('$backendUrl/api/vegetables'),
      headers: await authHeaders(),
    );
    if (response.statusCode == 200) {
      final List<dynamic> decoded = json.decode(response.body) as List<dynamic>;
      final vegetables = decoded
          .map((v) => Vegetable.fromJson(v as Map<String, dynamic>))
          .toList();
      vegetables
          .sort((a, b) => b.active.toString().compareTo(a.active.toString()));
      return vegetables;
    } else {
      throw Exception('Failed to fetch vegetables');
    }
  }

  Future<List<Vegetable>> listAvailableVegetables({
    required LatLng position,
    double? deliveryRadiusKm = 1,
    String? keyword,
  }) async {
    final uri = Uri.parse('$backendUrl/api/vegetables/available').replace(
      queryParameters: {
        'lat': position.latitude.toString(),
        'lon': position.longitude.toString(),
        'deliveryRadiusKm': deliveryRadiusKm.toString(),
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      },
    );

    final response = await client.get(uri, headers: await authHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> decoded = json.decode(response.body) as List<dynamic>;
      return decoded
          .map((v) => Vegetable.fromJson(v as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to fetch available vegetables');
    }
  }

  Future<Vegetable> getVegetable(String id) async {
    final response = await client.get(
      Uri.parse('$backendUrl/api/vegetables/$id'),
      headers: await authHeaders(),
    );
    if (response.statusCode == 200) {
      return Vegetable.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Vegetable not found');
    }
  }

  Future<Vegetable> createVegetable(Vegetable vegetable) async {
    final bodyMap = vegetable.toJson();
    if (vegetable.deliveryLocation != null) {
      bodyMap['deliveryLocation'] = {
        'latitude': vegetable.deliveryLocation!.latitude,
        'longitude': vegetable.deliveryLocation!.longitude,
      };
    } else {
      bodyMap['deliveryLocation'] = null;
    }
    bodyMap['deliveryRadiusKm'] = vegetable.deliveryRadiusKm;

    final response = await client.post(
      Uri.parse('$backendUrl/api/vegetables'),
      headers: await authHeaders(),
      body: json.encode(bodyMap),
    );
    if (response.statusCode == 201) {
      return Vegetable.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create vegetable');
    }
  }

  Future<void> updateVegetable(String id, Vegetable vegetable) async {
    final bodyMap = vegetable.toJson();
    if (vegetable.deliveryLocation != null) {
      bodyMap['deliveryLocation'] = {
        'latitude': vegetable.deliveryLocation!.latitude,
        'longitude': vegetable.deliveryLocation!.longitude,
      };
    } else {
      bodyMap['deliveryLocation'] = null;
    }
    bodyMap['deliveryRadiusKm'] = vegetable.deliveryRadiusKm;

    final response = await client.put(
      Uri.parse('$backendUrl/api/vegetables/$id'),
      headers: await authHeaders(),
      body: json.encode(bodyMap),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update vegetable');
    }
  }

  Future<void> deleteVegetable(String id) async {
    final response = await client.delete(
      Uri.parse('$backendUrl/api/vegetables/$id'),
      headers: await authHeaders(),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete vegetable');
    }
  }

  Future<List<VegetableImage>> uploadImages({
    required String userId,
    required List<XFile> images,
  }) async {
    if (images.isEmpty) {
      throw Exception('Aucune image sélectionnée');
    }

    try {
      final List<VegetableImage> vegetableImages = [];

      for (final imageFile in images) {
        if (imageFile.path.startsWith('http')) {
          continue;
        }
        final dir = await getTemporaryDirectory();
        final targetPath =
            '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}.jpg';

        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          imageFile.path,
          targetPath,
          quality: 85,
          format: CompressFormat.jpeg,
        );

        if (compressedFile == null) {
          throw Exception(
              'Échec de la compression de l\'image : ${imageFile.name}');
        }

        final storageRef = FirebaseStorage.instance.ref().child(
            'vegetables/$userId/${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}');

        try {
          await storageRef.putFile(File(compressedFile.path));

          final downloadUrl = await storageRef.getDownloadURL();
          final uri = Uri.parse(downloadUrl);
          final downloadToken = uri.queryParameters['token'];

          final relativePath = storageRef.fullPath;

          vegetableImages.add(VegetableImage(
            path: relativePath,
            uploadedAt: DateTime.now().toUtc(),
            status: 'pending',
            downloadToken: downloadToken,
          ));
        } catch (e) {
          throw Exception(
              "L'upload a échoué ou le fichier n'est pas disponible : $e");
        }
      }
      return vegetableImages;
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du légume : $e');
    }
  }

  Future<void> updateMainImage(String vegetableId, int mainImageIndex) async {
    final response = await client.put(
      Uri.parse('$backendUrl/api/vegetables/$vegetableId/main-image'),
      headers: await authHeaders(),
      body: json.encode({'mainImageIndex': mainImageIndex}),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to update main image');
    }
  }
}
