import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/hospital.dart';

class AddReviewScreen extends StatefulWidget {
  final String hospitalId;
  const AddReviewScreen({Key? key, required this.hospitalId}) : super(key: key);

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  double _rating = 3.0;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Review')),
        body: const Center(child: Text('You must be signed in to add a review.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Add Review')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your Review', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _commentController,
                decoration: const InputDecoration(hintText: 'Write your review...'),
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Please enter a comment' : null,
              ),
              const SizedBox(height: 16),
              const Text('Your Rating', style: TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: _rating,
                min: 1,
                max: 5,
                divisions: 4,
                label: _rating.toString(),
                onChanged: (val) {
                  setState(() {
                    _rating = val;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isSubmitting = true; });
    final review = Review(user: user.email ?? 'Anonymous', comment: _commentController.text.trim(), rating: _rating);
    final doc = FirebaseFirestore.instance.collection('hospitals').doc(widget.hospitalId);
    await doc.update({
      'reviews': FieldValue.arrayUnion([review.toMap()]),
    });
    setState(() { _isSubmitting = false; });
    if (mounted) {
      Navigator.pop(context);
    }
  }
} 