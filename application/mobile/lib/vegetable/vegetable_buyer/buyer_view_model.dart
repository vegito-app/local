import 'package:flutter/foundation.dart';
import '../vegetable_model.dart';
import '../vegetable_service.dart';
import 'buyer_filter.dart';

class BuyerViewModel extends ChangeNotifier {
  final VegetableService vegetableService;
  BuyerFilter _filter;
  List<Vegetable> _vegetables = [];
  bool _isLoading = false;
  String? _error;

  BuyerViewModel({
    required this.vegetableService,
    BuyerFilter? initialFilter,
  }) : _filter = initialFilter ?? BuyerFilter(searchRadiusKm: 10.0) {
    fetchVegetables(_filter);
  }

  List<Vegetable> get vegetables => _vegetables;
  bool get isLoading => _isLoading;
  String? get error => _error;
  BuyerFilter get currentFilter => _filter;

  Future<void> fetchVegetables(BuyerFilter filter) async {
    _filter = filter;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vegetables = await vegetableService.listAvailableVegetables(
        lat: filter.userLat,
        lon: filter.userLon,
        radiusKm: filter.searchRadiusKm,
        keyword: filter.searchText,
      );
    } catch (e) {
      _error = 'Erreur de chargement des légumes : $e';
      _vegetables = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateFilter(BuyerFilter newFilter) {
    fetchVegetables(newFilter);
  }
}
