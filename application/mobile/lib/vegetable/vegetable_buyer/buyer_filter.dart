import 'package:geolocator/geolocator.dart';

import '../vegetable_model.dart';

class BuyerFilter {
  final String? searchText;
  final double? userLat;
  final double? userLon;
  final bool onlyDeliverable;
  final double? searchRadiusKm;

  BuyerFilter({
    this.searchText,
    this.userLat,
    this.userLon,
    this.onlyDeliverable = true,
    this.searchRadiusKm,
  });

  List<Vegetable> apply(List<Vegetable> allVegetables) {
    return allVegetables.where((veg) {
      // 1. Texte libre
      final matchText = searchText == null ||
          veg.name.toLowerCase().contains(searchText!.toLowerCase()) ||
          veg.description.toLowerCase().contains(searchText!.toLowerCase());

      // 2. Zone de livraison
      final matchDelivery = !onlyDeliverable ||
          (userLat != null &&
              userLon != null &&
              veg.latitude != null &&
              veg.longitude != null &&
              veg.deliveryRadiusKm != null &&
              _isInDeliveryRange(userLat!, userLon!, veg.latitude!,
                  veg.longitude!, veg.deliveryRadiusKm!));

      return matchText && matchDelivery;
    }).toList();
  }

  bool _isInDeliveryRange(double userLat, double userLon, double sellerLat,
      double sellerLon, double maxDistanceKm) {
    final distance = Geolocator.distanceBetween(
          userLat,
          userLon,
          sellerLat,
          sellerLon,
        ) /
        1000;
    return distance <= maxDistanceKm;
  }
}
