import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VegetableMapLocationMiniPreview extends StatelessWidget {
  final LatLng center;
  final double radiusInKm;
  final double zoom;
  final VoidCallback? onTap;

  const VegetableMapLocationMiniPreview({
    super.key,
    required this.center,
    required this.radiusInKm,
    required this.zoom,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: 0.8,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: center,
                  zoom: zoom,
                ),
                circles: {
                  Circle(
                    circleId: const CircleId('deliveryRadius'),
                    center: center,
                    radius: radiusInKm * 1000,
                    fillColor: Colors.green.withOpacity(0.2),
                    strokeColor: Colors.green,
                    strokeWidth: 2,
                  ),
                },
                markers: {
                  Marker(
                    markerId: const MarkerId('deliveryMarker'),
                    position: center,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen),
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                scrollGesturesEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
                zoomGesturesEnabled: false,
                mapToolbarEnabled: false,
                liteModeEnabled: true,
                gestureRecognizers:
                    <Factory<OneSequenceGestureRecognizer>>{}.toSet(),
              ),
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Zone de couverture livraison : ${radiusInKm.toStringAsFixed(2)} km',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
