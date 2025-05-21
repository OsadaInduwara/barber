
// lib/models/customer_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String id;
  final String name;
  final String phoneNumber;
  final List<String> appointmentHistory; // List of appointment IDs
  final DateTime createdAt;
  final DateTime lastVisit;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.appointmentHistory,
    required this.createdAt,
    required this.lastVisit,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'appointmentHistory': appointmentHistory,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastVisit': Timestamp.fromDate(lastVisit),
    };
  }

  // Create CustomerModel from Firestore Map
  factory CustomerModel.fromMap(Map<String, dynamic> map, String id) {
    return CustomerModel(
      id: id,
      name: map['name'] as String,
      phoneNumber: map['phoneNumber'] as String,
      appointmentHistory: List<String>.from(map['appointmentHistory']),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastVisit: (map['lastVisit'] as Timestamp).toDate(),
    );
  }

  // Copy with method for updating customer properties
  CustomerModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    List<String>? appointmentHistory,
    DateTime? createdAt,
    DateTime? lastVisit,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      appointmentHistory: appointmentHistory ?? this.appointmentHistory,
      createdAt: createdAt ?? this.createdAt,
      lastVisit: lastVisit ?? this.lastVisit,
    );
  }
}