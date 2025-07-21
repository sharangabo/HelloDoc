class UserModel {
  final String uid;
  final String email;
  final String name;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.createdAt,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Map (from Firebase)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Create from Firebase Auth User
  factory UserModel.fromFirebaseUser(dynamic user, String name) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: name,
      createdAt: DateTime.now(),
    );
  }
} 