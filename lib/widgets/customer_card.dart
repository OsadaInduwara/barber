import 'package:flutter/material.dart';
import '../models/customer_model.dart';

class CustomerCard extends StatelessWidget {
  final CustomerModel customer;

  const CustomerCard({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(customer.name),
        subtitle: Text('Phone: ${customer.phoneNumber}\nLast Visit: ${customer.lastVisit.toLocal().toString().split(' ')[0]}'),
      ),
    );
  }
}
