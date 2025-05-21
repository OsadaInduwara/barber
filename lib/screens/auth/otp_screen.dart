import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  const OTPScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Enter the OTP sent to ${widget.phoneNumber}'),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'OTP'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool success = await authProvider.verifyOTP(_otpController.text.trim());
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid OTP')));
                }
              },
              child: const Text('Verify'),
            ),
            if (authProvider.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(authProvider.error!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
