import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../vegetable_model.dart';

class BuyerFilter {
  final String? searchText;
  final LatLng userLocation;
  final bool onlyDeliverable;
  final double searchRadiusKm;

  BuyerFilter({
    this.searchText,
    required this.userLocation,
    this.onlyDeliverable = true,
    this.searchRadiusKm = 1.0,
  });

  List<Vegetable> apply(List<Vegetable> allVegetables) {
    return allVegetables.where((veg) {
      // 1. Texte libre
      final matchText = searchText == null ||
          veg.name.toLowerCase().contains(searchText!.toLowerCase()) ||
          veg.description.toLowerCase().contains(searchText!.toLowerCase());
      if (veg.deliveryLocation == null) {
        return false; // Skip vegetables without location
      }
      // 2. Zone de livraison
      final matchDelivery = !onlyDeliverable ||
          (userLocation != null &&
              _isInDeliveryRange(
                  userLocation, veg.deliveryLocation!, veg.deliveryRadiusKm));

      return matchText && matchDelivery;
    }).toList();
  }

  bool _isInDeliveryRange(
      LatLng userLocation, LatLng sellerLocation, double deliveryRadiusKm) {
    final distance = Geolocator.distanceBetween(
          userLocation.latitude,
          userLocation.longitude,
          sellerLocation.latitude,
          sellerLocation.longitude,
        ) /
        1000;
    return distance <= deliveryRadiusKm;
  }
}
