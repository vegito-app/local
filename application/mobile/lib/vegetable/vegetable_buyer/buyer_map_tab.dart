import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../vegetable_model.dart';

class BuyerMapTab extends StatefulWidget {
  final List<Vegetable> vegetables;

  const BuyerMapTab({super.key, required this.vegetables});

  @override
  State<BuyerMapTab> createState() => _BuyerMapTabState();
}

class _BuyerMapTabState extends State<BuyerMapTab> {
  late GoogleMapController _controller;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  void _loadMarkers() {
    final markers =
        widget.vegetables.where((v) => v.deliveryLocation != null).map((veg) {
      return Marker(
        markerId: MarkerId(veg.id),
        position: LatLng(
            veg.deliveryLocation!.latitude, veg.deliveryLocation!.longitude),
        infoWindow: InfoWindow(
          title: veg.name,
          snippet: '${veg.priceCents / 100.0} € / kg',
        ),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (_) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(veg.name,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('${veg.priceCents / 100.0} € / kg'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: navigate to vegetable details or initiate purchase
                    },
                    child: const Text('Acheter'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }).toSet();

    setState(() {
      _markers.addAll(markers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(48.8566, 2.3522), // Paris par défaut
        zoom: 12,
      ),
      markers: _markers,
      onMapCreated: (controller) => _controller = controller,
    );
  }
}
