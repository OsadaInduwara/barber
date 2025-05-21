import 'package:flutter/material.dart';
import '../models/appointment_request_model.dart';
import '../utils/theme.dart';

class RequestCard extends StatelessWidget {
  final AppointmentRequestModel request;

  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const RequestCard({
    super.key,
    required this.request,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = request.isNewCustomer
        ? AppTheme.newCustomerColor.withOpacity(0.3)
        : AppTheme.regularCustomerColor.withOpacity(0.3);

    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(request.customerName),
        subtitle: Text('${request.preferredDate.toLocal().toString().split(' ')[0]} at ${request.preferredTime}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: onApprove,
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: onReject,
            ),
          ],
        ),
      ),
    );
  }
}
