import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../client/client_location_model.dart';
import '../client/client_detail_screen.dart';

class DeliveryMapScreen extends StatefulWidget {
  final List<ClientLocation> clients;

  const DeliveryMapScreen({super.key, required this.clients});

  @override
  State<DeliveryMapScreen> createState() => _DeliveryMapScreenState();
}

class _DeliveryMapScreenState extends State<DeliveryMapScreen> {
  ClientLocation? _selectedClient;

  @override
  Widget build(BuildContext context) {
    if (widget.clients.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Aucun client localisé')),
      );
    }

    final bounds = _calculateBounds(widget.clients);
    final initialCameraPosition = CameraPosition(
      target: LatLng(widget.clients[0].lat, widget.clients[0].lng),
      zoom: 12,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Carte des livraisons')),
      body: GoogleMap(
        initialCameraPosition: initialCameraPosition,
        markers: widget.clients
            .map((c) => Marker(
                  markerId: MarkerId(c.id),
                  position: LatLng(c.lat, c.lng),
                  infoWindow: InfoWindow(
                    title: c.displayName,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(c.displayName),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('📍 Latitude : ${c.lat.toStringAsFixed(5)}'),
                              Text(
                                  '📍 Longitude : ${c.lng.toStringAsFixed(5)}'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Fermer'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // fermer le dialog
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ClientDetailScreen(client: c),
                                  ),
                                );
                              },
                              child: const Text('Voir détails'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ))
            .toSet(),
        onMapCreated: (controller) {
          controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
        },
        onTap: (_) => setState(() => _selectedClient = null),
      ),
    );
  }

  LatLngBounds _calculateBounds(List<ClientLocation> clients) {
    final lats = clients.map((c) => c.lat);
    final lngs = clients.map((c) => c.lng);
    return LatLngBounds(
      southwest: LatLng(lats.reduce((a, b) => a < b ? a : b),
          lngs.reduce((a, b) => a < b ? a : b)),
      northeast: LatLng(lats.reduce((a, b) => a > b ? a : b),
          lngs.reduce((a, b) => a > b ? a : b)),
    );
  }
}
