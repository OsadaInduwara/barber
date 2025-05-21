// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/barber/barber_dashboard.dart';
import 'screens/customer/customer_dashboard.dart';
import 'utils/theme.dart';

class SaloonApp extends StatelessWidget {
  const SaloonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saloon Appointment Manager',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Show loading spinner while checking authentication
          if (authProvider.status == AuthStatus.authenticating) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Determine which screen to show based on authentication state
          if (authProvider.isAuthenticated) {
            if (authProvider.currentUser?.role == 'barber') {
              return const BarberDashboard();
            } else {
              return const CustomerDashboard();
            }
          } else {
            return const LoginScreen();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}