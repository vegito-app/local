import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:vegito/info_snackbar.dart';
import 'package:vegito/vegetable/vegetable_upload/vegetable_upload_provider.dart';

class VegetableMapLocationPicker extends StatefulWidget {
  final LatLng? initialLocation;
  final String? infoMessage;
  final double deliveryRadiusKm;

  const VegetableMapLocationPicker({
    super.key,
    this.initialLocation,
    this.infoMessage,
    required this.deliveryRadiusKm,
  });

  @override
  State<VegetableMapLocationPicker> createState() =>
      _VegetableMapLocationPickerState();
}

class _VegetableMapLocationPickerState
    extends State<VegetableMapLocationPicker> {
  LatLng? _selectedPosition;
  double _localRadiusKm = 0;

  GoogleMapController? _mapController;
  LocationData? _currentLocation;
  bool _userInteracted = false;
  bool _initialZoomSet = false;

  @override

  /// Initializes the state of the map location picker.
  ///
  /// If an initial location is provided through the widget's constructor,
  /// it sets `_selectedPosition` to that location. Otherwise, it calls
  /// `_initLocation` to determine the current location.
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.infoMessage != null) {
        InfoSnackBar.show(context, widget.infoMessage!);
      }
    });
    if (widget.initialLocation != null) {
      _selectedPosition = widget.initialLocation;
      _localRadiusKm = widget.deliveryRadiusKm;
    } else {
      _initLocation();
      _localRadiusKm = widget.deliveryRadiusKm;
    }
  }

  Future<void> _initLocation() async {
    final location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final loc = await location.getLocation();
    setState(() {
      _currentLocation = loc;
      _selectedPosition = LatLng(loc.latitude ?? 0, loc.longitude ?? 0);
    });
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _userInteracted = true;
    });
    _mapController?.animateCamera(CameraUpdate.newLatLng(position));
  }

  void _updateRadiusFromZoom() async {
    if (!_initialZoomSet) {
      return;
    }
    if (_mapController == null) return;
    final bounds = await _mapController!.getVisibleRegion();
    final sw = bounds.southwest;
    final ne = bounds.northeast;

    final distanceLng = (ne.longitude - sw.longitude).abs();
    // Ajustement selon la latitude moyenne
    final midLat = (ne.latitude + sw.latitude) / 2;
    final kmPerDegreeLng = 111.320 * math.cos(midLat * math.pi / 180);

    final widthKm = distanceLng * kmPerDegreeLng;
    final radiusKm =
        widthKm * 0.5 * 0.8; // 0.8 reste visible pour ajustement plus tard

    setState(() {
      _localRadiusKm = radiusKm;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VegetableUploadProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Choisir une position')),
      body: (_currentLocation == null && widget.initialLocation == null)
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Stack(children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _selectedPosition!,
                        zoom: 14,
                      ),
                      onMapCreated: (controller) {
                        final provider =
                            context.read<VegetableUploadProvider>();
                        _selectedPosition =
                            provider.deliveryLocation ?? _selectedPosition!;
                        double radiusKm = provider.deliveryRadiusKm > 0
                            ? provider.deliveryRadiusKm
                            : 1.0;
                        final zoom = 14 - math.log(radiusKm) / math.ln2;
                        _mapController = controller;
                        _mapController!.moveCamera(
                          CameraUpdate.newLatLngZoom(
                              provider.deliveryLocation ?? _selectedPosition!,
                              zoom),
                        );
                        _initialZoomSet = true;
                      },
                      markers: {},
                      circles: _selectedPosition != null
                          ? {
                              Circle(
                                circleId: const CircleId('delivery_area'),
                                center: _selectedPosition!,
                                radius: _localRadiusKm * 1000, // km to meters
                                fillColor: const Color(0x2200C853),
                                strokeColor: const Color(0xFF00C853),
                                strokeWidth: 2,
                              )
                            }
                          : {},
                      onTap: _onMapTap,
                      onCameraIdle: _updateRadiusFromZoom,
                    ),
                    const Positioned.fill(
                      child: IgnorePointer(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Text(
                              //   '🫛',
                              //   // '🫛𐫰👨‍🌾',
                              //   style: TextStyle(fontSize: 40),
                              // ),
                              Icon(
                                Icons.eco,
                                size: 40,
                                color: Color(0xFF00C853),
                              ),
                              // Icon(Icons.filter_vintage_outlined,
                              // size: 40,
                              // color: Color(0xFF00C853)),
                              // Icon(Icons.filter_vintage,
                              // Icon(Icons.nature_rounded,
                              // Icon(Icons.agriculture,
                              // Icon(Icons.local_florist,
                              Text(
                                'Définir la position d\'origine',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF00C853),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 60,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.agriculture, color: Color(0xFF00C853)),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Position de récolte du légume : origine du légume pour le consommateur et point de départ pour le calcul de votre tournée en cas de livraison.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        color: Colors.black.withOpacity(0.5),
                        child: Stack(
                          children: [
                            Text(
                              'Zone de couverture livraison',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 4
                                  ..color = Colors.black,
                              ),
                            ),
                            const Text(
                              'Zone de couverture livraison',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00C853),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: _FlashingRadiusMessage(
                        radiusInKm: _localRadiusKm,
                      ),
                    ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: _selectedPosition != null
                        ? () {
                            final provider =
                                context.read<VegetableUploadProvider>();
                            provider.setDeliveryLocationAndRadius(
                              _selectedPosition!,
                              _localRadiusKm,
                            );
                            Navigator.of(context).pop();
                          }
                        : null,
                    icon: const Icon(Icons.check),
                    label: const Text('Valider la position'),
                  ),
                )
              ],
            ),
    );
  }
}

class _FlashingRadiusMessage extends StatefulWidget {
  final double? radiusInKm;
  const _FlashingRadiusMessage({Key? key, this.radiusInKm}) : super(key: key);

  @override
  State<_FlashingRadiusMessage> createState() => _FlashingRadiusMessageState();
}

class _FlashingRadiusMessageState extends State<_FlashingRadiusMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: child,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 48),
        padding: const EdgeInsets.all(8),
        color: Colors.black.withOpacity(0.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Vous couvrez une zone de livraison de :',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF00C853),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              '${widget.radiusInKm?.toStringAsFixed(2) ?? '0.00'} km',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00C853),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
