import 'package:flutter/material.dart';
import 'vegetable_model.dart';

class VegetableListProvider with ChangeNotifier {
  final List<Vegetable> _allVegetables;
  final String filteredImagePrefix;

  VegetableListProvider({
    required List<Vegetable> vegetables,
    required this.filteredImagePrefix,
  }) : _allVegetables = vegetables;

  List<Vegetable> get vegetables => _allVegetables.map((veg) {
        if (_isAllowedImageUrl(veg.imageUrl)) {
          return veg;
        } else {
          return Vegetable(
            ownerId: veg.ownerId,
            createdAt: veg.createdAt,
            // If the image URL is not allowed, return a Vegetable with an empty imageUrl
            // but keep other properties intact.
            id: veg.id,
            name: veg.name,
            description: veg.description,
            saleType: veg.saleType,
            weightGrams: veg.weightGrams,
            priceCents: veg.priceCents,
            imageUrl: '',
          );
        }
      }).toList();

  bool _isAllowedImageUrl(String url) {
    return filteredImagePrefix == '*' || url.startsWith(filteredImagePrefix);
  }

  void updateVegetables(List<Vegetable> updatedVegetables) {
    _allVegetables.clear();
    _allVegetables.addAll(updatedVegetables);
    notifyListeners();
  }
}
