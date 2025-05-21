import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/appointment_card.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final appointments = appointmentProvider.appointments;

    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      body: appointments.isEmpty
          ? const Center(child: Text('No appointments'))
          : ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return AppointmentCard(appointment: appointment);
        },
      ),
    );
  }
}
