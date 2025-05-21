// lib/models/appointment_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String barberId;
  final String customerName;
  final String customerPhone;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int duration; // In minutes
  final String? notes;
  final String status; // 'confirmed', 'completed', 'cancelled'
  final int orderIndex; // For drag-and-drop reordering
  final bool isNewCustomer;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppointmentModel({
    required this.id,
    required this.barberId,
    required this.customerName,
    required this.customerPhone,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.duration,
    this.notes,
    required this.status,
    required this.orderIndex,
    required this.isNewCustomer,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barberId': barberId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'duration': duration,
      'notes': notes,
      'status': status,
      'orderIndex': orderIndex,
      'isNewCustomer': isNewCustomer,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create AppointmentModel from Firestore Map
  factory AppointmentModel.fromMap(Map<String, dynamic> map, String id) {
    return AppointmentModel(
      id: id,
      barberId: map['barberId'] as String,
      customerName: map['customerName'] as String,
      customerPhone: map['customerPhone'] as String,
      date: (map['date'] as Timestamp).toDate(),
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      duration: map['duration'] as int,
      notes: map['notes'] as String?,
      status: map['status'] as String,
      orderIndex: map['orderIndex'] as int,
      isNewCustomer: map['isNewCustomer'] as bool,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Copy with method for updating appointment properties
  AppointmentModel copyWith({
    String? id,
    String? barberId,
    String? customerName,
    String? customerPhone,
    DateTime? date,
    String? startTime,
    String? endTime,
    int? duration,
    String? notes,
    String? status,
    int? orderIndex,
    bool? isNewCustomer,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      barberId: barberId ?? this.barberId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      orderIndex: orderIndex ?? this.orderIndex,
      isNewCustomer: isNewCustomer ?? this.isNewCustomer,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
