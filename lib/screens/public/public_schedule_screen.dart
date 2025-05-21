import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/appointment_model.dart';

class PublicScheduleScreen extends StatelessWidget {
  const PublicScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return Scaffold(
      appBar: AppBar(title: const Text("Today's Appointments")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
            .where('status', isEqualTo: 'confirmed')
            .orderBy('date')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final appointments = snapshot.data!.docs
              .map((doc) => AppointmentModel.fromMap(doc.data()! as Map<String, dynamic>, doc.id))
              .toList();

          if (appointments.isEmpty) {
            return const Center(child: Text('No appointments today'));
          }

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appt = appointments[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(appt.customerName),
                  subtitle: Text('${appt.startTime} - ${appt.endTime}'),
                  // No phone number or sensitive info
                ),
              );
            },
          );
        },
      ),
    );
  }
}
