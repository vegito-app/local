import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  bool _hasPermission = false;

  Position? get currentPosition => _currentPosition;
  bool get hasPermission => _hasPermission;

  Future<void> ensurePermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      _hasPermission = false;
      notifyListeners();
      return;
    }

    _hasPermission = true;
    notifyListeners();
  }

  Future<void> fetchCurrentLocation() async {
    if (!_hasPermission) return;

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to get current location: $e");
    }
  }

  void reset() {
    _currentPosition = null;
    _hasPermission = false;
    notifyListeners();
  }
}
