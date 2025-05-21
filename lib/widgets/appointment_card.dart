import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../utils/theme.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final Key? key;

  const AppointmentCard({this.key, required this.appointment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = appointment.isNewCustomer
        ? AppTheme.newCustomerColor.withOpacity(0.3)
        : AppTheme.regularCustomerColor.withOpacity(0.3);

    return Card(
      key: key,
      color: cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(appointment.customerName),
        subtitle: Text('${appointment.startTime} - ${appointment.endTime}'),
        trailing: Text(appointment.status),
      ),
    );
  }
}
