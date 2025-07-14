class Appointment {
  final String id;
  final String userId;
  final String doctorName;
  final DateTime dateTime;
  final String reason;
  final String status;

  Appointment({
    required this.id,
    required this.userId,
    required this.doctorName,
    required this.dateTime,
    required this.reason,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'doctorName': doctorName,
      'dateTime': dateTime.toIso8601String(),
      'reason': reason,
      'status': status,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      dateTime: DateTime.parse(map['dateTime'] ?? DateTime.now().toIso8601String()),
      reason: map['reason'] ?? '',
      status: map['status'] ?? 'pending',
    );
  }
} 