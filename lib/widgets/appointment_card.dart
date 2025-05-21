import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment_model.dart';
import '../utils/theme.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final bool showDate;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    this.showDate = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = appointment.isNewCustomer
        ? AppTheme.newCustomerColor.withOpacity(0.3)
        : AppTheme.regularCustomerColor.withOpacity(0.3);

    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showDate)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                DateFormat('EEEE, MMM d').format(appointment.date),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ListTile(
            title: Text(appointment.customerName),
            subtitle: Text(
              '${DateFormat('hh:mm a').format(appointment.startTime as DateTime)}'
                  ' – '
                  '${DateFormat('hh:mm a').format(appointment.endTime as DateTime)}',
            ),
            trailing: Text(appointment.status),
          ),
        ],
      ),
    );
  }
}
