import 'package:flutter/material.dart';
import '../../models/auth/login_model.dart';
import '../../services/api_service.dart';
import 'security_verification_screen.dart';
import 'role_selection_screen.dart';

class MfaVerificationScreen extends StatefulWidget {
  final LoginModel loginData;
  const MfaVerificationScreen({super.key, required this.loginData});

  @override
  State<MfaVerificationScreen> createState() => _MfaVerificationScreenState();
}

class _MfaVerificationScreenState extends State<MfaVerificationScreen> {
  final otpController = TextEditingController();
  final api = ApiService();
  bool loading = false;
  String? message;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (otpController.text.trim().isEmpty) {
      setState(() => message = 'Enter the OTP sent to your mobile number.');
      return;
    }
    setState(() {
      loading = true;
      message = null;
    });
    try {
      final result = await api.validateOtp(
        userId: widget.loginData.id,
        mfaReference: widget.loginData.mfaReferenceCode ?? '',
        otp: otpController.text.trim(),
      );
      if (!mounted) return;
      if (result['Status'] == 1 || result['status'] == 1) {
        _continueToApp();
      } else {
        setState(() => message = 'Please enter a valid OTP.');
      }
    } catch (_) {
      if (mounted) setState(() => message = 'OTP validation failed.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _resend() async {
    try {
      final result = await api.resendOtp(userId: widget.loginData.id);
      if (!mounted) return;
      final reference = result['mfaReferenceCode']?.toString();
      if (reference != null && reference.isNotEmpty) {
        widget.loginData.mfaReferenceCode = reference;
      }
      setState(() => message = 'A new OTP has been sent.');
    } catch (_) {
      if (mounted) setState(() => message = 'Unable to resend OTP.');
    }
  }

  void _continueToApp() {
    final roles = widget.loginData.roleNames
        .split(',')
        .map((role) => role.trim())
        .where((role) => role.isNotEmpty)
        .toList();
    final next = roles.length > 1
        ? RoleSelectionScreen(loginData: widget.loginData)
        : const SecurityVerificationScreen();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => next));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security verification')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sms_outlined, size: 56),
                const SizedBox(height: 16),
                const Text(
                  'Enter the 6-digit OTP sent to your mobile number',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'OTP',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (message != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(message!),
                  ),
                FilledButton(
                  onPressed: loading ? null : _verify,
                  child: Text(loading ? 'VALIDATING...' : 'VALIDATE OTP'),
                ),
                TextButton(
                  onPressed: loading ? null : _resend,
                  child: const Text('RESEND OTP'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
