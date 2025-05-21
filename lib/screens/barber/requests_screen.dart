import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/request_card.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final requests = appointmentProvider.appointmentRequests;

    return Scaffold(
      appBar: AppBar(title: const Text('Appointment Requests')),
      body: requests.isEmpty
          ? const Center(child: Text('No appointment requests'))
          : ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return RequestCard(request: request);
        },
      ),
    );
  }
}
