import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    try {
      // returns verificationId
      String vId = await authProv.signInWithPhone(_phoneController.text.trim());
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            verificationId: vId,
            phoneNumber: _phoneController.text.trim(),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+1234567890',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter phone number';
                  // basic format check
                  if (!RegExp(r'^\+[0-9]{7,15}\$').hasMatch(val.trim())) {
                    return 'Include country code, e.g. +1';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sendOTP,
                  child: const Text('Send OTP'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
