import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';

class VegetableUploadProvider with ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  XFile? _image;
  bool _isLoading = false;

  XFile? get image => _image;
  bool get isLoading => _isLoading;

  Future<void> pickImage() async {
    _image = await _picker.pickImage(source: ImageSource.gallery);
    notifyListeners();
  }

  Future<void> submitVegetable({
    required BuildContext context,
    required String name,
    required String description,
    required int weightGrams,
    required int priceCents,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) {
      throw Exception('Utilisateur non authentifié');
    }

    if (_image == null) {
      throw Exception('Aucune image sélectionnée');
    }

    _isLoading = true;
    notifyListeners();

    try {
      final storageRef = FirebaseStorage.instance.ref().child(
          'vegetables/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = await storageRef.putFile(File(_image!.path));
      final imageUrl = await uploadTask.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('vegetables').add({
        'name': name,
        'description': description,
        'weightGrams': weightGrams,
        'priceCents': priceCents,
        'imageUrl': imageUrl,
        'ownerId': user.uid,
        'createdAt': Timestamp.now(),
      });

      _image = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
