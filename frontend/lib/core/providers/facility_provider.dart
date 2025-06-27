import 'package:flutter/foundation.dart';

class Facility {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String email;
  final List<String> services;
  final double rating;
  final int reviewCount;
  final bool isOpen;

  Facility({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.email,
    required this.services,
    required this.rating,
    required this.reviewCount,
    required this.isOpen,
  });
}

class FacilityProvider extends ChangeNotifier {
  List<Facility> _facilities = [];
  bool _isLoading = false;
  String? _error;

  List<Facility> get facilities => _facilities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFacilities() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      _facilities = [
        Facility(
          id: 'facility_1',
          name: 'Kigali Central Hospital',
          address: 'Kigali, Rwanda',
          latitude: -1.9441,
          longitude: 30.0619,
          phone: '+250 788 123 456',
          email: 'info@kch.rw',
          services: ['General Medicine', 'Surgery', 'Emergency Care'],
          rating: 4.5,
          reviewCount: 120,
          isOpen: true,
        ),
        Facility(
          id: 'facility_2',
          name: 'King Faisal Hospital',
          address: 'Kigali, Rwanda',
          latitude: -1.9500,
          longitude: 30.0700,
          phone: '+250 788 654 321',
          email: 'info@kfh.rw',
          services: ['Cardiology', 'Oncology', 'Pediatrics'],
          rating: 4.8,
          reviewCount: 89,
          isOpen: true,
        ),
      ];
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> searchFacilities(String query) async {
    try {
      _isLoading = true;
      notifyListeners();

      // TODO: Implement actual search API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Filter facilities based on query
      final filtered = _facilities.where((facility) =>
        facility.name.toLowerCase().contains(query.toLowerCase()) ||
        facility.address.toLowerCase().contains(query.toLowerCase())
      ).toList();
      
      _facilities = filtered;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> getNearbyFacilities(double lat, double lng, double radius) async {
    try {
      _isLoading = true;
      notifyListeners();

      // TODO: Implement actual location-based search
      await Future.delayed(const Duration(seconds: 1));
      
      // For now, return all facilities
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
} 