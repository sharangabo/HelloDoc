import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/hospital.dart';
import 'add_review_screen.dart';
import 'appointment_booking_screen.dart';

class HospitalDetailsScreen extends StatefulWidget {
  final Hospital hospital;
  const HospitalDetailsScreen({Key? key, required this.hospital}) : super(key: key);

  @override
  State<HospitalDetailsScreen> createState() => _HospitalDetailsScreenState();
}

class _HospitalDetailsScreenState extends State<HospitalDetailsScreen> {
  late Hospital hospital;

  @override
  void initState() {
    super.initState();
    hospital = widget.hospital;
    _fetchHospital();
  }

  Future<void> _fetchHospital() async {
    final doc = await FirebaseFirestore.instance.collection('hospitals').doc(hospital.id).get();
    if (doc.exists) {
      setState(() {
        hospital = Hospital.fromMap(doc.data()!);
      });
    }
  }

  Future<void> _launchMaps() async {
    final query = Uri.encodeComponent(hospital.address);
    final url = 'https://www.google.com/maps/search/?api=1&query=$query';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(hospital.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text(hospital.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            Text('Address: ${hospital.address}'),
            Text('Phone: ${hospital.phone}'),
            Text('Website: ${hospital.website}'),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                Text(hospital.rating.toString()),
              ],
            ),
            Text('Estimated Distance: ${hospital.distance.toStringAsFixed(2)} km'),
            Text('Estimated Travel Time: ${hospital.travelTime.toStringAsFixed(2)} minutes'),
            Text('Opening Hours: ${hospital.openingHours}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _launchMaps,
              child: const Text('Get Directions'),
            ),
            const SizedBox(height: 16),
            if (user != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppointmentBookingScreen(hospital: hospital),
                      ),
                    );
                  },
                  child: const Text('Book Appointment'),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Reviews:', style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddReviewScreen(hospitalId: hospital.id),
                      ),
                    );
                    _fetchHospital();
                  },
                  child: const Text('Add Review'),
                ),
              ],
            ),
            ...hospital.reviews.map((review) => Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(review.user),
                subtitle: Text(review.comment),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    Text(review.rating.toString()),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
} 