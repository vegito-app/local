import 'package:flutter/material.dart';
import 'vegetable_model.dart';
import 'vegetable_service.dart';

class VegetableListProvider with ChangeNotifier {
  List<Vegetable> _allVegetables = [];

  List<Vegetable> get vegetables => _allVegetables;

  Future<void> reload() async {
    _allVegetables = await VegetableService.listVegetables();
    notifyListeners();
  }

  Future<List<Vegetable>> findByIds(List<String> ids) async {
    final vegetables = await VegetableService.listVegetables();
    return vegetables.where((v) => ids.contains(v.id)).toList();
  }

  List<Vegetable> vegetablesByOwner(String uid) =>
      _allVegetables.where((veg) => veg.ownerId == uid).toList();
}
