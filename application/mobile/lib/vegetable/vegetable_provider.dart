import 'package:flutter/material.dart';
import 'vegetable_model.dart';
import 'vegetable_service.dart';

class VegetableProvider with ChangeNotifier {
  final VegetableService _service;

  VegetableProvider({VegetableService? service})
      : _service = service ?? VegetableService();

  Future<Vegetable> createVegetable(Vegetable vegetable) async {
    final created = await _service.createVegetable(vegetable);
    notifyListeners();
    return created;
  }

  // Tu peux ajouter d'autres méthodes si besoin (update, delete, list, ...)
}
