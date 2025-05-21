import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';
import '../models/appointment_request_model.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createAppointment(AppointmentModel appointment) async {
    final docRef = _firestore.collection('appointments').doc();
    final newAppointment = appointment.copyWith(id: docRef.id);
    await docRef.set(newAppointment.toMap());
    return docRef.id;
  }

  Future<AppointmentModel?> getAppointment(String id) async {
    final doc = await _firestore.collection('appointments').doc(id).get();
    if (doc.exists) return AppointmentModel.fromMap(doc.data()!, doc.id);
    return null;
  }

  Stream<List<AppointmentModel>> getBarberAppointments(String barberId) {
    return _firestore
        .collection('appointments')
        .where('barberId', isEqualTo: barberId)
        .orderBy('orderIndex')
        .snapshots()
        .map((snap) => snap.docs.map((d) => AppointmentModel.fromMap(d.data(), d.id)).toList());
  }

  Stream<List<AppointmentModel>> getTodayAppointments(String barberId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _firestore
        .collection('appointments')
        .where('barberId', isEqualTo: barberId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('date')
        .orderBy('startTime')
        .snapshots()
        .map((snap) => snap.docs.map((d) => AppointmentModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> updateAppointment(AppointmentModel appointment) async {
    await _firestore.collection('appointments').doc(appointment.id).update(appointment.toMap());
  }

  Future<void> deleteAppointment(String id) async {
    await _firestore.collection('appointments').doc(id).delete();
  }

  Future<String> createAppointmentRequest(AppointmentRequestModel request) async {
    final docRef = _firestore.collection('appointmentRequests').doc();
    final newRequest = request.copyWith(id: docRef.id);
    await docRef.set(newRequest.toMap());
    return docRef.id;
  }

  Stream<List<AppointmentRequestModel>> getPendingRequests() {
    return _firestore
        .collection('appointmentRequests')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => AppointmentRequestModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> approveRequest(String requestId) async {
    await _firestore.collection('appointmentRequests').doc(requestId).update({'status': 'approved'});
  }

  Future<void> rejectRequest(String requestId) async {
    await _firestore.collection('appointmentRequests').doc(requestId).update({'status': 'rejected'});
  }
}
