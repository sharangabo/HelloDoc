import 'package:flutter/foundation.dart';

class LocationProvider extends ChangeNotifier {
  double? _latitude;
  double? _longitude;
  String? _address;
  bool _isLoading = false;
  String? _error;

  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get address => _address;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getCurrentLocation() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // TODO: Implement actual location services
      // For now, using mock data
      await Future.delayed(const Duration(seconds: 2));
      
      _latitude = -1.9441; // Kigali coordinates
      _longitude = 30.0619;
      _address = 'Kigali, Rwanda';
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateLocation(double lat, double lng) async {
    _latitude = lat;
    _longitude = lng;
    // TODO: Implement reverse geocoding
    _address = 'Location: $lat, $lng';
    notifyListeners();
  }

  void clearLocation() {
    _latitude = null;
    _longitude = null;
    _address = null;
    _error = null;
    notifyListeners();
  }
} 