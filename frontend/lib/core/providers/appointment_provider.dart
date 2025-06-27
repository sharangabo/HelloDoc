import 'package:flutter/foundation.dart';

class Appointment {
  final String id;
  final String facilityId;
  final String facilityName;
  final String doctorId;
  final String doctorName;
  final DateTime dateTime;
  final String status;
  final String? notes;

  Appointment({
    required this.id,
    required this.facilityId,
    required this.facilityName,
    required this.doctorId,
    required this.doctorName,
    required this.dateTime,
    required this.status,
    this.notes,
  });
}

class AppointmentProvider extends ChangeNotifier {
  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _error;

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAppointments() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      _appointments = [
        Appointment(
          id: '1',
          facilityId: 'facility_1',
          facilityName: 'Kigali Central Hospital',
          doctorId: 'doctor_1',
          doctorName: 'Dr. Jean Pierre',
          dateTime: DateTime.now().add(const Duration(days: 2)),
          status: 'confirmed',
          notes: 'General checkup',
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

  Future<void> bookAppointment({
    required String facilityId,
    required String facilityName,
    required String doctorId,
    required String doctorName,
    required DateTime dateTime,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      final appointment = Appointment(
        id: 'appointment_${DateTime.now().millisecondsSinceEpoch}',
        facilityId: facilityId,
        facilityName: facilityName,
        doctorId: doctorId,
        doctorName: doctorName,
        dateTime: dateTime,
        status: 'pending',
        notes: notes,
      );
      
      _appointments.add(appointment);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      _appointments.removeWhere((appointment) => appointment.id == appointmentId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
} 