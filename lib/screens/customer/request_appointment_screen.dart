import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_request_model.dart';
import '../../providers/appointment_provider.dart';

class RequestAppointmentScreen extends StatefulWidget {
  const RequestAppointmentScreen({super.key});

  @override
  State<RequestAppointmentScreen> createState() => _RequestAppointmentScreenState();
}

class _RequestAppointmentScreenState extends State<RequestAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _notesCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Request Appointment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Your Name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Enter phone number' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(_selectedDate == null
                    ? 'Select Preferred Date'
                    : _selectedDate!.toLocal().toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: now,
                    lastDate: DateTime(now.year + 1),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              ListTile(
                title: Text(_selectedTime == null
                    ? 'Select Preferred Time'
                    : _selectedTime!.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) setState(() => _selectedTime = picked);
                },
              ),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && _selectedDate != null && _selectedTime != null) {
                    final newRequest = AppointmentRequestModel(
                      id: '',
                      customerName: _nameCtrl.text.trim(),
                      customerPhone: _phoneCtrl.text.trim(),
                      preferredDate: DateTime(
                        _selectedDate!.year,
                        _selectedDate!.month,
                        _selectedDate!.day,
                      ),
                      preferredTime: _selectedTime!.format(context),
                      notes: _notesCtrl.text.trim(),
                      status: 'pending',
                      isNewCustomer: true, // You can check actual customer existence here if needed
                      createdAt: DateTime.now(),
                    );

                    await appointmentProvider.createAppointmentRequest(newRequest);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Appointment request sent')),
                      );
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
