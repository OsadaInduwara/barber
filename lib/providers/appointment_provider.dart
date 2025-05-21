// lib/providers/appointment_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';
import '../models/appointment_request_model.dart';

class AppointmentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<AppointmentModel> _appointments = [];
  List<AppointmentRequestModel> _appointmentRequests = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<AppointmentModel> get appointments => _appointments;
  List<AppointmentRequestModel> get appointmentRequests => _appointmentRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered appointments for today
  List<AppointmentModel> get todayAppointments {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return _appointments
        .where((appointment) =>
    appointment.date.isAfter(startOfDay) &&
        appointment.date.isBefore(endOfDay) &&
        appointment.status == 'confirmed')
        .toList();
  }

  // Fetch appointments for a barber
  Future<void> fetchBarberAppointments(String barberId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where('barberId', isEqualTo: barberId)
          .orderBy('orderIndex')
          .get();

      _appointments = snapshot.docs
          .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set up real-time listener for barber's appointments
  void setupAppointmentsListener(String barberId) {
    _firestore
        .collection('appointments')
        .where('barberId', isEqualTo: barberId)
        .orderBy('orderIndex')
        .snapshots()
        .listen((snapshot) {
      _appointments = snapshot.docs
          .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      notifyListeners();
    });
  }

  // Fetch appointment requests
  Future<void> fetchAppointmentRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('appointmentRequests')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      _appointmentRequests = snapshot.docs
          .map((doc) => AppointmentRequestModel.fromMap(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set up real-time listener for appointment requests
  void setupRequestsListener() {
    _firestore
        .collection('appointmentRequests')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _appointmentRequests = snapshot.docs
          .map((doc) => AppointmentRequestModel.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      notifyListeners();
    });
  }

  // Create a new appointment
  Future<String> createAppointment(AppointmentModel appointment) async {
    try {
      final docRef = _firestore.collection('appointments').doc();
      final newAppointment = appointment.copyWith(id: docRef.id);

      await docRef.set(newAppointment.toMap());
      return docRef.id;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // Update an appointment
  Future<void> updateAppointment(AppointmentModel appointment) async {
    try {
      await _firestore
          .collection('appointments')
          .doc(appointment.id)
          .update(appointment.toMap());
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // Delete an appointment
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).delete();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // Create appointment request
  Future<String> createAppointmentRequest(AppointmentRequestModel request) async {
    try {
      final docRef = _firestore.collection('appointmentRequests').doc();
      final newRequest = request.copyWith(id: docRef.id);

      await docRef.set(newRequest.toMap());
      return docRef.id;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // Approve appointment request
  Future<void> approveRequest(AppointmentRequestModel request, String barberId) async {
    try {
      // Update request status
      await _firestore
          .collection('appointmentRequests')
          .doc(request.id)
          .update({'status': 'approved'});

      // Get the highest order index
      int orderIndex = 0;
      final snapshot = await _firestore
          .collection('appointments')
          .where('barberId', isEqualTo: barberId)
          .orderBy('orderIndex', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        orderIndex = (snapshot.docs.first.data()['orderIndex'] as int) + 1;
      }

      // Create a new appointment from this request
      final appointment = AppointmentModel(
        id: '', // Will be set in createAppointment
        barberId: barberId,
        customerName: request.customerName,
        customerPhone: request.customerPhone,
        date: request.preferredDate,
        startTime: request.preferredTime,
        endTime: '', // To be set by barber
        duration: 30, // Default duration
        notes: request.notes,
        status: 'confirmed',
        orderIndex: orderIndex,
        isNewCustomer: request.isNewCustomer,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await createAppointment(appointment);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // Reject appointment request
  Future<void> rejectRequest(String requestId) async {
    try {
      await _firestore
          .collection('appointmentRequests')
          .doc(requestId)
          .update({'status': 'rejected'});
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // Reorder appointments
  Future<void> reorderAppointments(int oldIndex, int newIndex) async {
    try {
      // Make a copy of the list to modify
      final List<AppointmentModel> updatedAppointments = List.from(_appointments);

      // Handle the case where you might be moving down the list
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      // Get the item we're moving
      final AppointmentModel item = updatedAppointments.removeAt(oldIndex);
      // Insert it at the new position
      updatedAppointments.insert(newIndex, item);

      // Update order indexes
      final batch = _firestore.batch();

      for (int i = 0; i < updatedAppointments.length; i++) {
        final appointment = updatedAppointments[i];
        if (appointment.orderIndex != i) {
          final updatedAppointment = appointment.copyWith(orderIndex: i);
          batch.update(
              _firestore.collection('appointments').doc(appointment.id),
              {'orderIndex': i}
          );
        }
      }

      await batch.commit();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // Fetch customer appointments
  Future<void> fetchCustomerAppointments(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where('customerPhone', isEqualTo: phoneNumber)
          .orderBy('date', descending: true)
          .get();

      _appointments = snapshot.docs
          .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set up real-time listener for customer appointments
  void setupCustomerAppointmentsListener(String phoneNumber) {
    _firestore
        .collection('appointments')
        .where('customerPhone', isEqualTo: phoneNumber)
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      _appointments = snapshot.docs
          .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      notifyListeners();
    });
  }
}
