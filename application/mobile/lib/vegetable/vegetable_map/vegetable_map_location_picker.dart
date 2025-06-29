import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class VegetableMapLocationPicker extends StatefulWidget {
  final void Function(LatLng) onLocationSelected;
  final LatLng? initialLocation;
  final LatLng? center;
  final double? radiusInKm;

  const VegetableMapLocationPicker({
    super.key,
    required this.onLocationSelected,
    this.initialLocation,
    this.center,
    this.radiusInKm,
  });

  @override
  State<VegetableMapLocationPicker> createState() =>
      _VegetableMapLocationPickerState();
}

class _VegetableMapLocationPickerState
    extends State<VegetableMapLocationPicker> {
  LatLng? _selectedPosition;
  GoogleMapController? _mapController;
  LocationData? _currentLocation;

  @override

  /// Initializes the state of the map location picker.
  ///
  /// If an initial location is provided through the widget's constructor,
  /// it sets `_selectedPosition` to that location. Otherwise, it calls
  /// `_initLocation` to determine the current location.
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedPosition = widget.initialLocation;
    } else {
      _initLocation();
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choisir une position')),
      body: (_currentLocation == null && widget.initialLocation == null)
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _selectedPosition!,
                      zoom: 14,
                    ),
                    onMapCreated: (controller) => _mapController = controller,
                    markers: _selectedPosition != null
                        ? {
                            Marker(
                              markerId: const MarkerId('selected'),
                              position: _selectedPosition!,
                              draggable: true,
                              onDragEnd: _onMapTap,
                            )
                          }
                        : {},
                    onTap: _onMapTap,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: _selectedPosition != null
                        ? () {
                            widget.onLocationSelected(_selectedPosition!);
                            Navigator.pop(context);
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
