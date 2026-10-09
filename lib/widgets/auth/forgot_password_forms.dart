import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Request step form: username, mobile, and captcha input
class ForgotPasswordRequestForm extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController mobileController;
  final TextEditingController captchaController;
  final String captchaImage;
  final bool loading;
  final String? message;
  final VoidCallback onRefreshCaptcha;
  final VoidCallback onSendOtp;
  final VoidCallback onBackToLogin;

  const ForgotPasswordRequestForm({
    super.key,
    required this.usernameController,
    required this.mobileController,
    required this.captchaController,
    required this.captchaImage,
    required this.loading,
    required this.message,
    required this.onRefreshCaptcha,
    required this.onSendOtp,
    required this.onBackToLogin,
  });

  Widget _buildCaptcha() {
    if (captchaImage.isEmpty) return const SizedBox.shrink();
    try {
      final bytes = Uri.parse('data:image/png;base64,$captchaImage').data!.contentAsBytes();
      return Image.memory(Uint8List.fromList(bytes), height: 70);
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Enter your username and mobile number. A 6-digit OTP will be sent to verify your details.',
        ),
        const SizedBox(height: 20),
        TextField(
          controller: usernameController,
          decoration: const InputDecoration(
            labelText: 'User name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: mobileController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Mobile number',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Center(child: _buildCaptcha()),
        TextField(
          controller: captchaController,
          decoration: InputDecoration(
            labelText: 'CAPTCHA',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              onPressed: loading ? null : onRefreshCaptcha,
              icon: const Icon(Icons.refresh),
            ),
          ),
        ),
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(message!, textAlign: TextAlign.center),
          ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: loading ? null : onSendOtp,
          child: Text(loading ? 'SENDING...' : 'SEND OTP'),
        ),
        TextButton(
          onPressed: onBackToLogin,
          child: const Text('BACK TO LOGIN'),
        ),
      ],
    );
  }
}

/// Reset password form: OTP and new password fields
class ForgotPasswordResetForm extends StatelessWidget {
  final TextEditingController otpController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final int seconds;
  final bool loading;
  final String? message;
  final VoidCallback onResendOtp;
  final VoidCallback onResetPassword;

  const ForgotPasswordResetForm({
    super.key,
    required this.otpController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.seconds,
    required this.loading,
    required this.message,
    required this.onResendOtp,
    required this.onResetPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Enter the OTP sent to your mobile, then set a new password.'),
        const SizedBox(height: 20),
        TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'OTP',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(seconds > 0 ? 'OTP expires in $seconds seconds' : 'OTP expired'),
            TextButton(
              onPressed: loading || seconds > 0 ? null : onResendOtp,
              child: const Text('RESEND'),
            ),
          ],
        ),
        TextField(
          controller: newPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'New password',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: confirmPasswordController,
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
          onPressed: loading ? null : onResetPassword,
          child: Text(loading ? 'RESETTING...' : 'RESET PASSWORD'),
        ),
      ],
    );
  }
}
