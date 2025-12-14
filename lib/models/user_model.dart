class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final int age;
  final String? photoURL;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.age,
    this.photoURL,
    required this.createdAt,
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'age': age,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create UserModel from Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      age: map['age'] ?? 0,
      photoURL: map['photoURL'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  // Create UserModel from Firebase Auth User and additional data
  factory UserModel.fromFirebaseUser({
    required String uid,
    required String email,
    required String fullName,
    required int age,
    String? photoURL,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      fullName: fullName,
      age: age,
      photoURL: photoURL,
      createdAt: DateTime.now(),
    );
  }

  // Copy with method for updates
  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    int? age,
    String? photoURL,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

