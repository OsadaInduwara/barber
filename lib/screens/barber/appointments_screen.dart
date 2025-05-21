import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../models/appointment_model.dart';
import '../../utils/theme.dart';
import '../../widgets/appointment_card.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('EEEE, MMM d');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _nextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
  }

  List<AppointmentModel> _getAppointmentsForSelectedDate(List<AppointmentModel> allAppointments) {
    return allAppointments.where((appointment) {
      return appointment.date.year == _selectedDate.year &&
          appointment.date.month == _selectedDate.month &&
          appointment.date.day == _selectedDate.day &&
          appointment.status == 'confirmed';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.currentUser == null) {
      return const Center(child: Text('User not authenticated'));
    }

    return Column(
      children: [
        // Tab bar
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Daily View'),
            Tab(text: 'All Appointments'),
          ],
        ),

        // Tab contents
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Daily view
              Column(
                children: [
                  // Date selector
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _previousDay,
                        ),
                        Text(
                          _dateFormat.format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _nextDay,
                        ),
                      ],
                    ),
                  ),

                  // Appointments list
                  Expanded(
                    child: appointmentProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Builder(
                      builder: (context) {
                        final dayAppointments = _getAppointmentsForSelectedDate(
                          appointmentProvider.appointments,
                        );

                        if (dayAppointments.isEmpty) {
                          return const Center(
                            child: Text('No appointments for this day'),
                          );
                        }

                        // Sort by start time
                        dayAppointments.sort((a, b) => a.startTime.compareTo(b.startTime));

                        return ListView.builder(
                          itemCount: dayAppointments.length,
                          itemBuilder: (context, index) {
                            return AppointmentCard(
                              appointment: dayAppointments[index],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),

              // All appointments
              appointmentProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Builder(
                builder: (context) {
                  final futureAppointments = appointmentProvider.appointments
                      .where((a) => a.date.isAfter(DateTime.now().subtract(const Duration(days: 1))))
                      .where((a) => a.status == 'confirmed')
                      .toList()
                    ..sort((a, b) => a.date.compareTo(b.date));

                  if (futureAppointments.isEmpty) {
                    return const Center(
                      child: Text('No upcoming appointments'),
                    );
                  }

                  // Group appointments by date
                  final Map<String, List<AppointmentModel>> groupedAppointments = {};
                  for (var appointment in futureAppointments) {
                    final dateStr = DateFormat('yyyy-MM-dd').format(appointment.date);
                    groupedAppointments.putIfAbsent(dateStr, () => []).add(appointment);
                  }

                  // Sort each day's appointments by start time
                  groupedAppointments.forEach((_, list) {
                    list.sort((a, b) => a.startTime.compareTo(b.startTime));
                  });

                  // Sort dates
                  final sortedDates = groupedAppointments.keys.toList()..sort();

                  return ListView.builder(
                    itemCount: sortedDates.length,
                    itemBuilder: (context, dateIndex) {
                      final dateStr = sortedDates[dateIndex];
                      final date = DateTime.parse(dateStr);
                      final appointments = groupedAppointments[dateStr]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              _dateFormat.format(date),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...appointments.map((appointment) => AppointmentCard(
                            appointment: appointment,
                            showDate: false,
                          )),
                          const Divider(),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
