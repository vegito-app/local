import 'package:car2go/vegetable/vegetable_model.dart';
import 'package:car2go/vegetable/vegetable_provider.dart';
import 'package:car2go/vegetable/vegetable_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VegetableUploadProvider with ChangeNotifier {
  Vegetable? initialVegetable;
  final VegetableService _service;
  VegetableUploadProvider({VegetableService? service})
    : _service = service ?? VegetableService();

  final List<XFile> _images = [];
  int _mainImageIndex = 0;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  List<XFile> get images => _images;
  int get mainImageIndex => _mainImageIndex;
  XFile? get mainImage => _images.isNotEmpty ? _images[_mainImageIndex] : null;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

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
    required String userId,
    required VegetableProvider vegetableProvider,
    required String name,
    required String description,
    required int weightGrams,
    required int priceCents,
    required String saleType,
  }) async {
    if (_images.isEmpty) {
      throw Exception('No images selected');
    }
    final vegetableImages = await _service.uploadImages(
      userId: userId,
      images: _images,
    );

    final vegetable = Vegetable(
      id: '',
      name: name,
      description: description,
      saleType: saleType,
      weightGrams: weightGrams,
      priceCents: priceCents,
      images: vegetableImages,
      ownerId: userId,
      createdAt: DateTime.now().toUtc(),
    );
    await _service.createVegetable(vegetable);
  }

  factory VegetableUploadProvider.fromVegetable(
    Vegetable vegetable, {
    VegetableService? service,
  }) {
    final provider = VegetableUploadProvider(service: service);
    provider.initialVegetable = vegetable;
    provider._images.clear();
    provider._images.addAll(vegetable.images.map((img) => XFile(img.url)));
    provider._mainImageIndex = 0;
    return provider;
  }
}
