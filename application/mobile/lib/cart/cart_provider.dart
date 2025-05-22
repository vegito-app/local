import 'package:flutter/material.dart';
import '../vegetable_upload/vegetable_model.dart';

class CartProvider with ChangeNotifier {
  final Map<Vegetable, int> _items = {};

  Map<Vegetable, int> get items => _items;

  void add(Vegetable vegetable, {int quantity = 1}) {
    if (_items.containsKey(vegetable)) {
      _items[vegetable] = _items[vegetable]! + quantity;
    } else {
      _items[vegetable] = quantity;
    }
    notifyListeners();
  }

  void remove(Vegetable vegetable) {
    _items.remove(vegetable);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
