import 'package:vegito/vegetable/vegetable_map/vegetable_map_location_picker.dart';
import 'package:vegito/vegetable/vegetable_upload/vegetable_upload_provider.dart';
import 'package:flutter/material.dart';

class VegetableLocationPicker extends StatelessWidget {
  final VegetableUploadProvider provider;

  const VegetableLocationPicker({super.key, required this.provider});

  @override

  /// Builds a widget that allows the user to set the delivery location and radius.
  ///
  /// The widget consists of a map that shows the current delivery location and
  /// radius, and a dropdown menu that allows the user to select a different
  /// delivery radius. When the user selects a new delivery location or radius,
  /// the [VegetableUploadProvider] is updated accordingly.
  ///
  /// The widget is designed to be used in a [Column], and takes up a fixed height
  /// of 250 pixels.
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Livraison", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text("Définir la livraison")),
                  body: Column(
                    children: [
                      Expanded(
                        child: VegetableMapLocationPicker(
                          center: provider.deliveryLocation,
                          radiusInKm: provider.deliveryRadiusKm,
                          onLocationSelected: (position) {
                            provider.deliveryLocation = position;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Rayon de livraison : ${provider.deliveryRadiusKm.toStringAsFixed(1)} km"),
                            Slider(
                              value: provider.deliveryRadiusKm,
                              min: 1.0,
                              max: 20.0,
                              label:
                                  "${provider.deliveryRadiusKm.toStringAsFixed(1)} km",
                              onChanged: (value) {
                                provider.deliveryRadiusKm = value;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          child: SizedBox(
            height: 150,
            child: VegetableMapLocationPicker(
              center: provider.deliveryLocation,
              radiusInKm: provider.deliveryRadiusKm,
              onLocationSelected: (pos) {
                provider.deliveryLocation = pos;
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text("Rayon de livraison"),
        DropdownButton<double>(
          value: provider.deliveryRadiusKm,
          onChanged: (value) {
            if (value != null) {
              provider.deliveryRadiusKm = value;
            }
          },
          items: [1.0, 2.0, 5.0, 10.0, 20.0]
              .map((radius) => DropdownMenuItem(
                    value: radius,
                    child: Text("${radius.toStringAsFixed(1)} km"),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
