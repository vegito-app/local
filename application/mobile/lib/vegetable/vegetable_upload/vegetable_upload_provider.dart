import 'package:car2go/vegetable/vegetable_list_provider.dart';
import 'package:car2go/vegetable/vegetable_model.dart';
import 'package:car2go/vegetable/vegetable_service.dart';
import 'package:car2go/vegetable/vegetable_upload/vegetable_sale_details_section.dart';
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
  bool _isActive = true;
  final ImagePicker _picker = ImagePicker();

  AvailabilityType _availabilityType = AvailabilityType.sameDay;
  DateTime? _availabilityDate;
  int _quantityGrams = 0;
  int _priceCents = 0;

  List<XFile> get images => _images;
  int get mainImageIndex => _mainImageIndex;
  XFile? get mainImage => _images.isNotEmpty ? _images[_mainImageIndex] : null;
  bool get isLoading => _isLoading;
  bool get isActive => _isActive;

  AvailabilityType get availabilityType => _availabilityType;
  set availabilityType(AvailabilityType value) {
    _availabilityType = value;
    notifyListeners();
  }

  DateTime? get availabilityDate => _availabilityDate;
  set availabilityDate(DateTime? value) {
    _availabilityDate = value;
    notifyListeners();
  }

  double get quantityAvailableKg => _quantityGrams / 1000.0;
  set quantityAvailableKg(double value) {
    _quantityGrams = (value * 1000).round();
    notifyListeners();
  }

  double get priceEuros => _priceCents / 100.0;
  set priceEuros(double value) {
    _priceCents = (value * 100).round();
    notifyListeners();
  }

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set isActive(bool value) {
    _isActive = value;
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

  bool get hasChanges {
    if (initialVegetable == null) return true;

    return _quantityGrams != initialVegetable!.quantityAvailable ||
        _priceCents != initialVegetable!.priceCents ||
        _availabilityType.name != initialVegetable!.availabilityType ||
        _availabilityDate != initialVegetable!.availabilityDate ||
        _isActive != initialVegetable!.active ||
        !_sameImages(initialVegetable!.images, _images);
  }

  bool _sameImages(List<VegetableImage> a, List<XFile> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!b[i].path.contains(a[i].publicUrl.split('/').last)) return false;
    }
    return true;
  }

  Future<void> setMainImage(
    int index,
    String userId,
    VegetableListProvider vegetableListProvider,
  ) async {
    if (index >= 0 && index < _images.length) {
      final selectedImage = _images.removeAt(index);
      _images.insert(0, selectedImage);
      _mainImageIndex = 0;

      notifyListeners();

      final initialImageList = initialVegetable?.images;

      if (initialVegetable != null &&
          initialImageList != null &&
          index < initialImageList.length) {
        final selected = initialImageList.removeAt(index);
        initialImageList.insert(0, selected);

        try {
          await _service.updateMainImage(initialVegetable!.id, index);
          await vegetableListProvider.reload();
        } catch (e) {
          debugPrint(
              'Erreur lors de la mise à jour de l\'image principale : $e');
        }
      }
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

  bool get isReadyToSubmit {
    return _quantityGrams > 0 && _priceCents > 0 && _images.isNotEmpty;
  }

  Future<void> submitVegetable({
    required String userId,
    required VegetableListProvider vegetableListProvider,
    required String name,
    required String description,
    required int quantityAvailable,
    required AvailabilityType availabilityType,
    DateTime? availabilityDate,
    required int priceCents,
    required String saleType,
  }) async {
    if (initialVegetable == null && _images.isEmpty) {
      throw Exception('No images selected');
    }

    List<VegetableImage> vegetableImages = [];

    if (initialVegetable != null) {
      vegetableImages.addAll(initialVegetable!.images);
    }

    if (_images.isNotEmpty) {
      final newUploadedImages = await _service.uploadImages(
        userId: userId,
        images: _images,
      );
      vegetableImages.addAll(newUploadedImages);
    }

    if (vegetableImages.isEmpty) {
      throw Exception('No images selected after filtering.');
    } else {
      final VegetableImage mainImage = vegetableImages[_mainImageIndex];
      vegetableImages.removeAt(_mainImageIndex);
      vegetableImages.insert(0, mainImage);
    }
    final vegetable = Vegetable(
      id: initialVegetable?.id ?? '', // conserve l'id existant
      name: name,
      description: description,
      saleType: saleType,
      priceCents: _priceCents,
      images: vegetableImages,
      ownerId: userId,
      createdAt: DateTime.now().toUtc(),
      active: _isActive,
      availabilityType: _availabilityType.name,
      availabilityDate: _availabilityDate,
      quantityAvailable: _quantityGrams,
    );

    if (initialVegetable == null) {
      await _service.createVegetable(vegetable);
    } else {
      await _service.updateVegetable(initialVegetable!.id, vegetable);
    }
    await vegetableListProvider.reload();
  }

  factory VegetableUploadProvider.fromVegetable(
    Vegetable vegetable, {
    VegetableService? service,
  }) {
    final provider = VegetableUploadProvider(service: service);
    provider.initialVegetable = vegetable;
    provider._images
        .addAll(vegetable.images.map((img) => XFile(img.publicUrl)));

    // Lors du chargement, par convention on positionne la 1ère image comme principale
    provider._mainImageIndex = 0;
    provider._isActive = vegetable.active;
    provider._availabilityType = AvailabilityType.values.firstWhere(
      (e) => e.name == vegetable.availabilityType,
      orElse: () => AvailabilityType.sameDay,
    );
    provider._priceCents = vegetable.priceCents;
    provider._quantityGrams = vegetable.quantityAvailable;
    provider._availabilityDate = vegetable.availabilityDate;
    return provider;
  }

  Future<void> setVegetableActive(bool isActive, String userId,
      VegetableListProvider vegetableListProvider) async {
    if (initialVegetable == null) {
      throw Exception(
          'Impossible de modifier le statut d\'une annonce qui n\'existe pas encore.');
    }

    _isActive = isActive;

    final updatedVegetable = Vegetable(
      id: initialVegetable!.id,
      name: initialVegetable!.name,
      description: initialVegetable!.description,
      saleType: initialVegetable!.saleType,
      priceCents: _priceCents,
      images: initialVegetable!.images,
      ownerId: initialVegetable!.ownerId,
      createdAt: initialVegetable!.createdAt,
      active: _isActive,
      availabilityType: _availabilityType.name,
      availabilityDate: _availabilityDate,
      quantityAvailable: _quantityGrams,
    );

    await _service.updateVegetable(initialVegetable!.id, updatedVegetable);
    await vegetableListProvider.reload();
    notifyListeners();
  }

  Vegetable? get currentVegetable {
    if (initialVegetable == null) return null;
    return Vegetable(
      id: initialVegetable!.id,
      name: initialVegetable!.name,
      description: initialVegetable!.description,
      saleType: initialVegetable!.saleType,
      priceCents: _priceCents,
      images: initialVegetable!.images,
      ownerId: initialVegetable!.ownerId,
      createdAt: initialVegetable!.createdAt,
      active: _isActive,
      availabilityType: _availabilityType.name,
      availabilityDate: _availabilityDate,
      quantityAvailable: _quantityGrams,
    );
  }

  void markChanged() {
    notifyListeners();
  }
}
