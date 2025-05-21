// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String phoneNumber;
  final String? email;
  final String role; // 'barber' or 'customer'
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.phoneNumber,
    this.email,
    required this.role,
    required this.createdAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'email': email,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create UserModel from Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      displayName: map['displayName'] as String,
      phoneNumber: map['phoneNumber'] as String,
      email: map['email'] as String?,
      role: map['role'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}

