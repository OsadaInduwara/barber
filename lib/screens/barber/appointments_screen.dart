import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/appointment_card.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final appointments = appointmentProvider.appointments;

    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      body: appointments.isEmpty
          ? const Center(child: Text('No appointments'))
          : ReorderableListView.builder(
        itemCount: appointments.length,
        onReorder: (oldIndex, newIndex) async {
          await appointmentProvider.reorderAppointments(oldIndex, newIndex);
        },
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return AppointmentCard(
            key: ValueKey(appointment.id),
            appointment: appointment,
          );
        },
      ),
    );
  }
}
