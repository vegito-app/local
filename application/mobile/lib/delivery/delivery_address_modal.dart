import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';

class DeliveryAddressModal extends StatefulWidget {
  final String? initialAddress;
  final void Function(String address, double lat, double lon) onAddressSelected;

  const DeliveryAddressModal(
      {super.key, this.initialAddress, required this.onAddressSelected});

  @override
  _DeliveryAddressModalState createState() => _DeliveryAddressModalState();
}

class _DeliveryAddressModalState extends State<DeliveryAddressModal> {
  String? _selectedAddress;
  double? _lat;
  double? _lon;

  @override
  void initState() {
    super.initState();
    _selectedAddress = widget.initialAddress;
  }

  Future<void> _handlePressButton() async {
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: 'VOTRE_API_KEY_GOOGLE_PLACES', // à remplacer
      mode: Mode.overlay,
      language: "fr",
      components: [const Component(Component.country, "fr")],
    );
    if (p != null) {
      // Récupérer détails du lieu
      final places = GoogleMapsPlaces(apiKey: 'VOTRE_API_KEY_GOOGLE_PLACES');
      final detail = await places.getDetailsByPlaceId(p.placeId!);
      final lat = detail.result.geometry!.location.lat;
      final lon = detail.result.geometry!.location.lng;
      setState(() {
        _selectedAddress = detail.result.formattedAddress;
        _lat = lat;
        _lon = lon;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Définir l\'adresse de livraison'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text('Rechercher une adresse'),
            onPressed: _handlePressButton,
          ),
          if (_selectedAddress != null) ...[
            const SizedBox(height: 12),
            const Text('Adresse sélectionnée :'),
            Text(
              _selectedAddress!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // annuler
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: (_selectedAddress != null && _lat != null && _lon != null)
              ? () {
                  widget.onAddressSelected(_selectedAddress!, _lat!, _lon!);
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Valider'),
        ),
      ],
    );
  }
}
