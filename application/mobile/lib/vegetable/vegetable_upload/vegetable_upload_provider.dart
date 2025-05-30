import 'dart:io';

import 'package:car2go/auth/auth_provider.dart';
import 'package:car2go/vegetable/vegetable_model.dart';
import 'package:car2go/vegetable/vegetable_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class VegetableUploadProvider with ChangeNotifier {
  final List<XFile> _images = [];
  int _mainImageIndex = 0;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  List<XFile> get images => _images;
  int get mainImageIndex => _mainImageIndex;
  XFile? get mainImage => _images.isNotEmpty ? _images[_mainImageIndex] : null;
  bool get isLoading => _isLoading;

  Future<void> pickImage() async {
    // Permet d'ajouter plusieurs images successivement, les images précédentes sont conservées.
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _images.add(image);
      notifyListeners();
    }
  }

  void setMainImage(int index) {
    if (index >= 0 && index < _images.length) {
      _mainImageIndex = index;
      notifyListeners();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < _images.length) {
      _images.removeAt(index);
      if (_mainImageIndex >= _images.length) {
        _mainImageIndex = 0;
      }
      notifyListeners();
    }
  }

  Future<void> submitVegetable({
    required BuildContext context,
    required String name,
    required String description,
    required String saleType,
    required int weightGrams,
    required int priceCents,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) {
      throw Exception('Utilisateur non authentifié');
    }

    if (_images.isEmpty) {
      throw Exception('Aucune image sélectionnée');
    }

    _isLoading = true;
    notifyListeners();

    try {
      final List<VegetableImage> vegetableImages = [];

      for (final imageFile in _images) {
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
            'vegetables/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}');
        final uploadTask = await storageRef.putFile(compressedFile);
        final imageUrl = await uploadTask.ref.getDownloadURL();

        vegetableImages.add(VegetableImage(
          url: imageUrl,
          uploadedAt: DateTime.now().millisecondsSinceEpoch,
          status: 'pending',
        ));
      }

      final vegetableService = VegetableService(
        backendUrl: const String.fromEnvironment('APPLICATION_BACKEND_URL'),
      );
      final vegetable = Vegetable(
        name: name,
        description: description,
        saleType: saleType,
        weightGrams: weightGrams,
        priceCents: priceCents,
        images: vegetableImages,
        ownerId: user.uid,
        createdAt: DateTime.now(),
      );
      await vegetableService.createVegetable(vegetable);

      _images.clear();
      _mainImageIndex = 0;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Erreur lors de l\'envoi du légume : $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
