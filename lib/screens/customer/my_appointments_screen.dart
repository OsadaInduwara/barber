import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/appointment_card.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    // You would get the logged-in user's phone number here to fetch their appointments
    // For demo purposes, let's assume phone number stored in AuthProvider or passed here.
    // Replace with actual phone number logic
    const phoneNumber = '1234567890';
    appointmentProvider.setupCustomerAppointmentsListener(phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      body: appointmentProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : appointmentProvider.appointments.isEmpty
          ? const Center(child: Text('No appointments found'))
          : ListView.builder(
        itemCount: appointmentProvider.appointments.length,
        itemBuilder: (context, index) {
          final appt = appointmentProvider.appointments[index];
          return AppointmentCard(appointment: appt);
        },
      ),
    );
  }
}
