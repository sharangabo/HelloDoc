import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hospital.dart';
import 'hospital_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> categories = [
    'Hospital',
    'Ambulance',
    'Blood Test',
    'Free eye checkup',
    'Dental Clinic',
    'Blood Bank',
    'Eye Specialist',
    'Skin Doctor',
    'Pet Specialist',
    'Lab',
    'Clinics',
    'Medical Records',
  ];
  String selectedCategory = 'Hospital';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Near Me'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Text(
                'Hospital Near Me',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ...categories.map((cat) => ListTile(
                  leading: _categoryIcon(cat),
                  title: Text(cat),
                  selected: selectedCategory == cat,
                  onTap: () {
                    setState(() {
                      selectedCategory = cat;
                    });
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: isDark ? Colors.grey[900] : Colors.grey[200],
              ),
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
            ),
            const SizedBox(height: 12),
            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selectedCategory == cat,
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = cat;
                      });
                    },
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // Hospital list from Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('hospitals').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No hospitals found.'));
                  }
                  final hospitals = snapshot.data!.docs
                      .map((doc) => Hospital.fromMap(doc.data() as Map<String, dynamic>))
                      .where((h) => h.category == selectedCategory &&
                          (searchQuery.isEmpty || h.name.toLowerCase().contains(searchQuery.toLowerCase())))
                      .toList();
                  if (hospitals.isEmpty) {
                    return const Center(child: Text('No hospitals match your search.'));
                  }
                  return ListView.builder(
                    itemCount: hospitals.length,
                    itemBuilder: (context, index) {
                      final hospital = hospitals[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: const Icon(Icons.local_hospital, color: Colors.red),
                          title: Text(hospital.name),
                          subtitle: Text(hospital.address),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 20),
                              Text(hospital.rating.toString()),
                              const SizedBox(width: 8),
                              Icon(Icons.location_on, color: Colors.green, size: 20),
                              Icon(Icons.phone, color: Colors.blue, size: 20),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HospitalDetailsScreen(hospital: hospital),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Icon _categoryIcon(String cat) {
    switch (cat) {
      case 'Hospital':
        return const Icon(Icons.local_hospital);
      case 'Ambulance':
        return const Icon(Icons.local_taxi);
      case 'Blood Test':
        return const Icon(Icons.bloodtype);
      case 'Free eye checkup':
        return const Icon(Icons.remove_red_eye);
      case 'Dental Clinic':
        return const Icon(Icons.medical_services);
      case 'Blood Bank':
        return const Icon(Icons.opacity);
      case 'Eye Specialist':
        return const Icon(Icons.visibility);
      case 'Skin Doctor':
        return const Icon(Icons.healing);
      case 'Pet Specialist':
        return const Icon(Icons.pets);
      case 'Lab':
        return const Icon(Icons.science);
      case 'Clinics':
        return const Icon(Icons.local_hospital_outlined);
      case 'Medical Records':
        return const Icon(Icons.folder);
      default:
        return const Icon(Icons.local_hospital);
    }
  }
}
