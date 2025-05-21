import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appointment_provider.dart';
import 'appointments_screen.dart';
import 'requests_screen.dart';
import 'customers_screen.dart';

class BarberDashboard extends StatefulWidget {
  const BarberDashboard({super.key});

  @override
  State<BarberDashboard> createState() => _BarberDashboardState();
}

class _BarberDashboardState extends State<BarberDashboard> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    AppointmentsScreen(),
    RequestsScreen(),
    CustomersScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);

    // Setup listeners once user is available
    if (authProvider.currentUser != null) {
      appointmentProvider.setupAppointmentsListener(authProvider.currentUser!.uid);
      appointmentProvider.setupRequestsListener();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Barber Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.signOut(),
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Appointments'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
        ],
      ),
    );
  }
}
