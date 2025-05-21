import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/customer_card.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: customerProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : customerProvider.customers.isEmpty
          ? const Center(child: Text('No customers found'))
          : ListView.builder(
        itemCount: customerProvider.customers.length,
        itemBuilder: (context, index) {
          final customer = customerProvider.customers[index];
          return CustomerCard(customer: customer);
        },
      ),
    );
  }
}
