import 'package:flutter/material.dart';
import '../../models/auth/login_model.dart';
import '../../services/api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final LoginModel loginData;
  const ResetPasswordScreen({super.key, required this.loginData});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();
  final api = ApiService();
  bool loading = false;
  String? message;

  @override
  void dispose() {
    newPassword.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  bool _valid(String value) =>
      value.length >= 12 &&
      value.length <= 15 &&
      RegExp(r'[0-9]').hasMatch(value) &&
      RegExp(r'[a-z]').hasMatch(value) &&
      RegExp(r'[A-Z]').hasMatch(value) &&
      RegExp(r'[!@#$%^&*]').hasMatch(value);

  Future<void> _save() async {
    if (!_valid(newPassword.text) || newPassword.text != confirmPassword.text) {
      setState(
        () => message =
            'Password must be 12–15 characters with uppercase, lowercase, number, and special character, and both fields must match.',
      );
      return;
    }
    setState(() {
      loading = true;
      message = null;
    });
    try {
      final result = await api.resetPassword(
        userId: widget.loginData.id,
        newPassword: newPassword.text,
        updatedBy: widget.loginData.id,
      );
      if (!mounted) return;
      if ((result['status'] ?? 0) > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Password changed successfully. Please log in again.',
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        setState(
          () => message =
              result['message']?.toString() ?? 'Password reset failed.',
        );
      }
    } catch (_) {
      if (mounted) setState(() => message = 'Password reset failed.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set new password')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: newPassword,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPassword,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm password',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (message != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(message!, textAlign: TextAlign.center),
                  ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: loading ? null : _save,
                  child: Text(loading ? 'SAVING...' : 'CHANGE PASSWORD'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
