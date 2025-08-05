import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vegito/vegetable/vegetable_map/vegetable_map_location_picker.dart';
import 'package:vegito/vegetable/vegetable_upload/vegetable_upload_provider.dart';
import 'package:vegito/vegetable/vehetable_map_location_mini_preview.dart';

class VegetableLocationPicker extends StatelessWidget {
  const VegetableLocationPicker({super.key});

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
    final provider = context.watch<VegetableUploadProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Livraison/Emport", style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 12),
        if (provider.deliveryLocation == null)
          GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: provider,
                    child: VegetableMapLocationPicker(
                      deliveryRadiusKm: provider.deliveryRadiusKm,
                      infoMessage:
                          "Sélectionnez un emplacement pour activer les options de livraison.",
                    ),
                  ),
                ),
              );
            },
            child: Container(
              height: 100,
              width: 100,
              color: Colors.blueGrey[100],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, color: Colors.blue),
                    Text("Définir position"),
                  ],
                ),
              ),
            ),
          )
        else
          GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: provider,
                    child: VegetableMapLocationPicker(
                      deliveryRadiusKm: provider.deliveryRadiusKm,
                      infoMessage:
                          "Sélectionnez un emplacement pour activer les options de livraison.",
                    ),
                  ),
                ),
              );
            },
            child: const SizedBox(
              height: 150,
              child: VegetableMapLocationMiniPreview(),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          provider.deliveryRadiusKm == 0.0
              ? "Récupération sur site"
              : "Rayon de livraison",
          style: TextStyle(
            color:
                provider.deliveryRadiusKm == 0.0 ? Colors.grey : Colors.black,
            fontStyle: provider.deliveryRadiusKm == 0.0
                ? FontStyle.italic
                : FontStyle.normal,
          ),
        ),
        DropdownButton<double>(
          value: provider.deliveryRadiusKm,
          onChanged: (value) async {
            if (value != null && value != provider.deliveryRadiusKm) {
              provider.deliveryRadiusKm = value;
            }
            if (provider.deliveryLocation == null) {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider.value(
                    value: provider,
                    child: VegetableMapLocationPicker(
                      deliveryRadiusKm: provider.deliveryRadiusKm,
                      infoMessage:
                          "Sélectionnez un emplacement pour activer les options de livraison.",
                    ),
                  ),
                ),
              );
            }
          },
          items: () {
            final radiusValues = [0.0, 1.0, 2.0, 5.0, 10.0, 20.0];
            final dropdownItems = [...radiusValues];
            if (!radiusValues.contains(provider.deliveryRadiusKm)) {
              dropdownItems.insert(0, provider.deliveryRadiusKm);
            }
            return dropdownItems
                .map((radius) => DropdownMenuItem(
                      value: radius,
                      child: Text(
                        "${radius.toStringAsFixed(1)} km",
                        style: TextStyle(
                          color: radius == 0.0 ? Colors.grey : Colors.black,
                        ),
                      ),
                    ))
                .toList();
          }(),
        ),
      ],
    );
  }
}
