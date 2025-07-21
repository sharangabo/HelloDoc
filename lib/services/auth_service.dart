import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user model
      UserModel userModel = UserModel.fromFirebaseUser(userCredential.user!, name);

      // Save user data to Realtime Database
      await _database.child('users').child(userCredential.user!.uid).set(
        userModel.toMap(),
      );

      return userCredential;
    } catch (e) {
      // Error signing up: $e
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // Error signing in: $e
      rethrow;
    }
  }

  // Get user data from database
  Future<UserModel?> getUserData(String uid) async {
    try {
      DatabaseEvent event = await _database.child('users').child(uid).once();
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        return UserModel.fromMap(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      // Error getting user data: $e
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
} 