import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hospital.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final Hospital hospital;
  const AppointmentBookingScreen({Key? key, required this.hospital}) : super(key: key);

  @override
  State<AppointmentBookingScreen> createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedDoctor;
  DateTime? _selectedDateTime;
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _doctors = [
    'Dr. Alice Uwimana',
    'Dr. Jean Bosco',
    'Dr. Grace Mukamana',
    'Dr. Eric Niyonzima',
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Book Appointment')),
        body: const Center(child: Text('You must be signed in to book an appointment.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Hospital: ${widget.hospital.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDoctor,
                items: _doctors.map((doctor) => DropdownMenuItem(
                  value: doctor,
                  child: Text(doctor),
                )).toList(),
                onChanged: (val) => setState(() => _selectedDoctor = val),
                decoration: const InputDecoration(
                  labelText: 'Select Doctor',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null ? 'Please select a doctor' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_selectedDateTime == null
                    ? 'Select Date & Time'
                    : '${_selectedDateTime!.toLocal()}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDateTime,
              ),
              if (_selectedDateTime == null)
                const Padding(
                  padding: EdgeInsets.only(left: 12.0, top: 4.0),
                  child: Text('Please select date and time', style: TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for Appointment',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter a reason' : null,
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Book Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedDateTime == null) return;
    setState(() { _isSubmitting = true; });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('appointments').add({
      'userId': user.uid,
      'hospitalId': widget.hospital.id,
      'doctorName': _selectedDoctor!,
      'dateTime': _selectedDateTime!.toIso8601String(),
      'reason': _reasonController.text.trim(),
      'createdAt': DateTime.now().toIso8601String(),
    });
    setState(() { _isSubmitting = false; });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appointment Booked'),
        content: const Text('Your appointment has been booked successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
} 