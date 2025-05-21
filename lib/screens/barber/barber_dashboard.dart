import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/customer_provider.dart';
import '../../utils/theme.dart';
import 'appointments_screen.dart';
import 'requests_screen.dart';
import 'customers_screen.dart';

class BarberDashboard extends StatefulWidget {
  const BarberDashboard({super.key});

  @override
  State<BarberDashboard> createState() => _BarberDashboardState();
}

class _BarberDashboardState extends State<BarberDashboard> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const AppointmentsScreen(),
    const RequestsScreen(),
    const CustomersScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Set up listeners for appointments and requests
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      appointmentProvider.setupAppointmentsListener(authProvider.currentUser!.uid);
      appointmentProvider.setupRequestsListener();
    }
  }

  void _signOut() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user?.displayName ?? "Barber"}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Customers',
          ),
        ],
        selectedItemColor: AppTheme.primaryColor,
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddAppointmentScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}

class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen({super.key});

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _startTime = '09:00';
  int _duration = 30;
  bool _isNewCustomer = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  // Calculate end time based on start time and duration
  String _calculateEndTime() {
    final parts = _startTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final DateTime startDateTime = DateTime(2022, 1, 1, hour, minute);
    final DateTime endDateTime = startDateTime.add(Duration(minutes: _duration));

    return '${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}';
  }

  void _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      final customerProvider = Provider.of<CustomerProvider>(context, listen: false);

      // Check if customer is new
      bool isNewCustomer = await customerProvider.isNewCustomer(_phoneController.text);

      // Create appointment
      final appointment = AppointmentModel(
        id: '',  // Will be set in createAppointment
        barberId: authProvider.currentUser!.uid,
        customerName: _nameController.text,
        customerPhone: _phoneController.text,
        date: _selectedDate,
        startTime: _startTime,
        endTime: _calculateEndTime(),
        duration: _duration,
        notes: _notesController.text,
        status: 'confirmed',
        orderIndex: appointmentProvider.appointments.length,
        isNewCustomer: isNewCustomer,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final appointmentId = await appointmentProvider.createAppointment(appointment);

      // Update customer record
      await customerProvider.updateCustomerWithAppointment(_phoneController.text, appointmentId);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Appointment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter customer name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Date selection
              ListTile(
                title: const Text('Appointment Date'),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                leading: const Icon(Icons.calendar_today),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _selectDate,
              ),
              const Divider(),
              // Time selection
              ListTile(
                title: const Text('Start Time'),
                subtitle: Text(_startTime, style: const TextStyle(fontSize: 16)),
                leading: const Icon(Icons.access_time),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _selectTime,
              ),
              const Divider(),
              // Duration selection
              ListTile(
                title: const Text('Duration'),
                subtitle: Text('$_duration minutes', style: const TextStyle(fontSize: 16)),
                leading: const Icon(Icons.timelapse),
                trailing: DropdownButton<int>(
                  value: _duration,
                  items: [15, 30, 45, 60, 90, 120].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value min'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _duration = value;
                      });
                    }
                  },
                ),
              ),
              const Divider(),
              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveAppointment,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}