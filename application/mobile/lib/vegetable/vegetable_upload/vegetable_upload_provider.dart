import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vegito/vegetable/vegetable_list_provider.dart';
import 'package:vegito/vegetable/vegetable_model.dart';
import 'package:vegito/vegetable/vegetable_service.dart';
import 'package:vegito/vegetable/vegetable_upload/vegetable_sale_details_section.dart';

class VegetableUploadProvider with ChangeNotifier {
  String _saleType = 'weight';

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
  int _quantity = 0;
  int _priceCents = 0;

  LatLng? _deliveryLocation;
  LatLng? get deliveryLocation => _deliveryLocation;
  set deliveryLocation(LatLng? location) {
    _deliveryLocation = location;
    notifyListeners();
  }

  double _deliveryRadiusKm = 5.0; // Valeur par défaut 5 km

  double get deliveryRadiusKm => _deliveryRadiusKm;
  set deliveryRadiusKm(double value) {
    if (_deliveryRadiusKm != value) {
      _deliveryRadiusKm = value;
      notifyListeners();
    }
  }

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

  int get quantityAvailable => _quantity;
  set quantityAvailableGrams(int grams) {
    if (_quantity != grams) {
      _quantity = grams;
      notifyListeners();
    }
  }

  set quantityAvailableUnits(int units) {
    if (_quantity != units) {
      _quantity = units;
      notifyListeners();
    }
  }

  double get priceEuros => _priceCents / 100.0;
  set priceEuros(double value) {
    _priceCents = (value * 100).round();
    notifyListeners();
  }

  String get saleType => _saleType;
  set saleType(String value) {
    if (_saleType != value) {
      _saleType = value;
      notifyListeners();
    }
  }

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set isActive(bool value) {
    _isActive = value;
    notifyListeners();
  }

  // Limite à 3 images max
  Future<void> pickImage() async {
    if (_images.length >= 3) return;
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _images.add(image);
      notifyListeners();
    }
  }

  bool get hasChanges {
    if (initialVegetable == null) return true;

    return _quantity != initialVegetable!.quantityAvailable ||
        _priceCents != initialVegetable!.priceCents ||
        _availabilityType.name != initialVegetable!.availabilityType ||
        _availabilityDate != initialVegetable!.availabilityDate ||
        _isActive != initialVegetable!.active ||
        _saleType != initialVegetable!.saleType ||
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
    final hasValidQuantity = _quantity > 0;
    final hasValidPrice = _priceCents > 0;
    final hasImage = _images.isNotEmpty;
    return hasValidQuantity && hasValidPrice && hasImage;
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
      saleType: _saleType,
      priceCents: _priceCents,
      images: vegetableImages,
      ownerId: userId,
      createdAt: DateTime.now().toUtc(),
      active: _isActive,
      availabilityType: _availabilityType.name,
      availabilityDate: _availabilityDate,
      quantityAvailable: _quantity,
      latitude: _deliveryLocation?.latitude,
      longitude: _deliveryLocation?.longitude,
      deliveryRadiusKm: _deliveryRadiusKm,
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
    provider._quantity = vegetable.quantityAvailable;
    provider._availabilityDate = vegetable.availabilityDate;
    provider._saleType = vegetable.saleType;

    // Ajout des champs
    provider._deliveryLocation = vegetable.deliveryLocation;
    provider._deliveryRadiusKm = vegetable.deliveryRadiusKm ?? 5.0;

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
      saleType: _saleType,
      priceCents: _priceCents,
      images: initialVegetable!.images,
      ownerId: initialVegetable!.ownerId,
      createdAt: initialVegetable!.createdAt,
      active: _isActive,
      availabilityType: _availabilityType.name,
      availabilityDate: _availabilityDate,
      quantityAvailable: _quantity,
      latitude: _deliveryLocation?.latitude,
      longitude: _deliveryLocation?.longitude,
      deliveryRadiusKm: _deliveryRadiusKm,
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
      saleType: _saleType,
      priceCents: _priceCents,
      images: initialVegetable!.images,
      ownerId: initialVegetable!.ownerId,
      createdAt: initialVegetable!.createdAt,
      active: _isActive,
      availabilityType: _availabilityType.name,
      availabilityDate: _availabilityDate,
      quantityAvailable: _quantity,
      latitude: _deliveryLocation?.latitude,
      longitude: _deliveryLocation?.longitude,
      deliveryRadiusKm: _deliveryRadiusKm,
    );
  }

  void markChanged() {
    notifyListeners();
  }

  void setQuantityFromKgString(String raw) {
    final cleaned = raw.trim().replaceAll(',', '.');
    final parsed = double.tryParse(cleaned);
    if (parsed == null) return;
    const maxKg = 1000000.0;
    final clamped = parsed.clamp(0, maxKg);
    _quantity = (clamped * 1000).round();
    notifyListeners();
  }

  void setQuantityFromGramsString(String raw) {
    final parsed = int.tryParse(raw.trim()) ?? 0;
    _quantity = parsed;
    notifyListeners();
  }

  void setQuantityFromUnitsString(String raw) {
    final parsed = int.tryParse(raw.trim()) ?? 0;
    _quantity = parsed;
    notifyListeners();
  }
}
