
// lib/models/appointment_request_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentRequestModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final DateTime preferredDate;
  final String preferredTime;
  final String? notes;
  final String status; // 'pending', 'approved', 'rejected'
  final bool isNewCustomer;
  final DateTime createdAt;

  AppointmentRequestModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.preferredDate,
    required this.preferredTime,
    this.notes,
    required this.status,
    required this.isNewCustomer,
    required this.createdAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'preferredDate': Timestamp.fromDate(preferredDate),
      'preferredTime': preferredTime,
      'notes': notes,
      'status': status,
      'isNewCustomer': isNewCustomer,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create AppointmentRequestModel from Firestore Map
  factory AppointmentRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return AppointmentRequestModel(
      id: id,
      customerName: map['customerName'] as String,
      customerPhone: map['customerPhone'] as String,
      preferredDate: (map['preferredDate'] as Timestamp).toDate(),
      preferredTime: map['preferredTime'] as String,
      notes: map['notes'] as String?,
      status: map['status'] as String,
      isNewCustomer: map['isNewCustomer'] as bool,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Copy with method for updating request properties
  AppointmentRequestModel copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    DateTime? preferredDate,
    String? preferredTime,
    String? notes,
    String? status,
    bool? isNewCustomer,
    DateTime? createdAt,
  }) {
    return AppointmentRequestModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      preferredDate: preferredDate ?? this.preferredDate,
      preferredTime: preferredTime ?? this.preferredTime,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      isNewCustomer: isNewCustomer ?? this.isNewCustomer,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
