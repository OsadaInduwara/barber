import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';

class CustomerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createUpdateCustomer(CustomerModel customer) async {
    final querySnapshot = await _firestore
        .collection('customers')
        .where('phoneNumber', isEqualTo: customer.phoneNumber)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final id = querySnapshot.docs.first.id;
      await _firestore.collection('customers').doc(id).update(customer.copyWith(id: id).toMap());
      return id;
    } else {
      final docRef = _firestore.collection('customers').doc();
      final newCustomer = customer.copyWith(id: docRef.id);
      await docRef.set(newCustomer.toMap());
      return docRef.id;
    }
  }

  Future<CustomerModel?> getCustomerByPhone(String phoneNumber) async {
    final querySnapshot = await _firestore
        .collection('customers')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      return CustomerModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Stream<List<CustomerModel>> getCustomers() {
    return _firestore
        .collection('customers')
        .orderBy('lastVisit', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => CustomerModel.fromMap(d.data() as Map<String, dynamic>, d.id)).toList());
  }

  Future<void> addAppointmentToHistory(String customerId, String appointmentId) async {
    await _firestore.collection('customers').doc(customerId).update({
      'appointmentHistory': FieldValue.arrayUnion([appointmentId]),
      'lastVisit': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<List<CustomerModel>> searchCustomers(String query) async {
    final nameResults = await _firestore
        .collection('customers')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    final phoneResults = await _firestore
        .collection('customers')
        .where('phoneNumber', isGreaterThanOrEqualTo: query)
        .where('phoneNumber', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    final Set<String> ids = {};
    final List<CustomerModel> results = [];

    for (final doc in nameResults.docs) {
      if (!ids.contains(doc.id)) {
        results.add(CustomerModel.fromMap(doc.data() as Map<String, dynamic>, doc.id));
        ids.add(doc.id);
      }
    }

    for (final doc in phoneResults.docs) {
      if (!ids.contains(doc.id)) {
        results.add(CustomerModel.fromMap(doc.data() as Map<String, dynamic>, doc.id));
        ids.add(doc.id);
      }
    }
    return results;
  }
}
