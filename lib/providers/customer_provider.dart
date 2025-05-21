// lib/providers/customer_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';

class CustomerProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<CustomerModel> _customers = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CustomerModel> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all customers
  Future<void> fetchCustomers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('customers')
          .orderBy('lastVisit', descending: true)
          .get();

      _customers = snapshot.docs
          .map((doc) => CustomerModel.fromMap(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch customer by phone number
  Future<CustomerModel?> fetchCustomerByPhone(String phoneNumber) async {
    try {
      final snapshot = await _firestore
          .collection('customers')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return CustomerModel.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
      }

      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Check if customer is new (doesn't exist in database)
  Future<bool> isNewCustomer(String phoneNumber) async {
    try {
      final customer = await fetchCustomerByPhone(phoneNumber);
      return customer == null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return true; // Assume new customer if there's an error
    }
  }

  // Add a new customer
  Future<String> addCustomer(CustomerModel customer) async {
    try {
      // Check if customer already exists
      final existingCustomer = await fetchCustomerByPhone(customer.phoneNumber);
      if (existingCustomer != null) {
        return existingCustomer.id;
      }

      // Create new customer
      final docRef = _firestore.collection('customers').doc();
      final newCustomer = customer.copyWith(id: docRef.id);

      await docRef.set(newCustomer.toMap());
      return docRef.id;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // Update customer with new appointment
  Future<void> updateCustomerWithAppointment(String phoneNumber, String appointmentId) async {
    try {
      // Try to find existing customer
      final customer = await fetchCustomerByPhone(phoneNumber);

      if (customer != null) {
        // Update existing customer
        final updatedAppointmentHistory = List<String>.from(customer.appointmentHistory)
          ..add(appointmentId);

        await _firestore.collection('customers').doc(customer.id).update({
          'appointmentHistory': updatedAppointmentHistory,
          'lastVisit': Timestamp.fromDate(DateTime.now()),
        });
      } else {
        // Create a new customer
        final newCustomer = CustomerModel(
          id: '',  // Will be set in addCustomer
          name: '',  // Will be set by appointment data
          phoneNumber: phoneNumber,
          appointmentHistory: [appointmentId],
          createdAt: DateTime.now(),
          lastVisit: DateTime.now(),
        );

        await addCustomer(newCustomer);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // Update customer details
  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      await _firestore
          .collection('customers')
          .doc(customer.id)
          .update(customer.toMap());
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // Search customers by name or phone
  Future<List<CustomerModel>> searchCustomers(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      // First try to match by phone number
      final phoneResults = await _firestore
          .collection('customers')
          .where('phoneNumber', isGreaterThanOrEqualTo: query)
          .where('phoneNumber', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      // Then try to match by name
      final nameResults = await _firestore
          .collection('customers')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      // Combine results
      final Set<String> uniqueIds = {};
      final List<CustomerModel> results = [];

      for (final doc in phoneResults.docs) {
        if (!uniqueIds.contains(doc.id)) {
          results.add(CustomerModel.fromMap(doc.data(), doc.id));
          uniqueIds.add(doc.id);
        }
      }

      for (final doc in nameResults.docs) {
        if (!uniqueIds.contains(doc.id)) {
          results.add(CustomerModel.fromMap(doc.data(), doc.id));
          uniqueIds.add(doc.id);
        }
      }

      return results;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }
}