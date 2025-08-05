import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../vegetable_model.dart';

class VegetableMap extends StatelessWidget {
  final List<Vegetable> vegetables;

  const VegetableMap({super.key, required this.vegetables});

  @override
  Widget build(BuildContext context) {
    final markers = vegetables
        .map((veg) {
          final position = veg.deliveryLocation;
          if (position == null) return null;

          return Marker(
            markerId: MarkerId(veg.id),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: InfoWindow(
              title: veg.name,
              snippet: '${(veg.priceCents / 100).toStringAsFixed(2)} €',
            ),
          );
        })
        .whereType<Marker>()
        .toSet();

    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(48.8566, 2.3522), // Paris par défaut
        zoom: 12,
      ),
      markers: markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }
}
