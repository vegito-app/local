import 'package:flutter/material.dart';
import 'vegetable_model.dart';
import 'vegetable_service.dart';

class VegetableListProvider with ChangeNotifier {
  final VegetableService service;

  VegetableListProvider({VegetableService? service})
      : service = service ?? VegetableService();

  List<Vegetable> _allVegetables = [];

  List<Vegetable> get vegetables => _allVegetables;

  Future<void> reload() async {
    _allVegetables = await service.listVegetables();
    notifyListeners();
  }

  Future<List<Vegetable>> findByIds(List<String> ids) async {
    final vegetables = await service.listVegetables();
    return vegetables.where((v) => ids.contains(v.id)).toList();
  }

  List<Vegetable> vegetablesByOwner(String uid) =>
      _allVegetables.where((veg) => veg.ownerId == uid).toList();

  void updateVegetableInList(Vegetable updatedVegetable) {
    final index = _allVegetables.indexWhere((v) => v.id == updatedVegetable.id);
    if (index != -1) {
      _allVegetables[index] = updatedVegetable;
      notifyListeners();
    }
  }

  Future<void> deleteVegetable(String id) async {
    await service.deleteVegetable(id);
    _allVegetables.removeWhere((v) => v.id == id);
    notifyListeners();
  }
}
