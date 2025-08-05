import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vegito/vegetable/vegetable_upload/vegetable_upload_provider.dart';

class VegetableMapLocationMiniPreview extends StatefulWidget {
  final VoidCallback? onTap;

  const VegetableMapLocationMiniPreview({super.key, this.onTap});

  @override
  State<VegetableMapLocationMiniPreview> createState() =>
      _VegetableMapLocationMiniPreviewState();
}

class _VegetableMapLocationMiniPreviewState
    extends State<VegetableMapLocationMiniPreview> {
  final Completer<GoogleMapController> _controller = Completer();

  double _computeZoom(double radiusKm) {
    return 14 - math.log(radiusKm > 0 ? radiusKm : 1.0) / math.ln2;
  }

  void _maybeUpdateCamera(VegetableUploadProvider provider) async {
    if (!_controller.isCompleted) return;
    final mapController = await _controller.future;
    final zoom = _computeZoom(provider.deliveryRadiusKm);
    mapController.moveCamera(
        CameraUpdate.newLatLngZoom(provider.deliveryLocation!, zoom));
  }

  @override
  void dispose() {
    // Si tu ajoutes un listener plus tard, tu le nettoieras ici
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VegetableUploadProvider>(
      builder: (context, provider, _) {
        // if (provider.deliveryLocation != _previousDeliveryLocation ||
        //     provider.deliveryRadiusKm != _previousDeliveryRadiusKm) {
        //   _maybeUpdateCamera(provider);
        //   _previousDeliveryLocation = provider.deliveryLocation;
        //   _previousDeliveryRadiusKm = provider.deliveryRadiusKm;
        // }
        return GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque, // capte tout
          child: Opacity(
            opacity: 0.8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: provider.deliveryLocation!,
                      zoom: _computeZoom(provider.deliveryRadiusKm),
                    ),
                    circles: {
                      Circle(
                        circleId: const CircleId('deliveryRadius'),
                        center: provider.deliveryLocation!,
                        radius: provider.deliveryRadiusKm * 1000,
                        fillColor: Colors.green.withOpacity(0.2),
                        strokeColor: Colors.green,
                        strokeWidth: 2,
                      ),
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('deliveryMarker'),
                        position: provider.deliveryLocation!,
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
                    onMapCreated: (controller) {
                      _controller.complete(controller);
                      if (provider.deliveryLocation == null) {
                        debugPrint(
                            'Error: deliveryLocation is null. Using default location.');
                        const fallbackLocation =
                            LatLng(48.8566, 2.3522); // Default to Paris
                        Future.delayed(const Duration(milliseconds: 100),
                            () async {
                          final mapController = await _controller.future;
                          mapController.moveCamera(
                            CameraUpdate.newLatLngZoom(
                              fallbackLocation,
                              _computeZoom(provider.deliveryRadiusKm),
                            ),
                          );
                        });
                        return;
                      }
                      Future.delayed(const Duration(milliseconds: 100),
                          () async {
                        final mapController = await _controller.future;
                        mapController.moveCamera(
                          CameraUpdate.newLatLngZoom(
                            provider.deliveryLocation!,
                            _computeZoom(provider.deliveryRadiusKm),
                          ),
                        );
                      });
                    },
                    gestureRecognizers:
                        <Factory<OneSequenceGestureRecognizer>>{}.toSet(),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Zone de couverture livraison : ${provider.deliveryRadiusKm.toStringAsFixed(2)} km',
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
      },
    );
  }
}
