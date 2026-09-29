import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final api = ApiService();
  final username = TextEditingController();
  final mobile = TextEditingController();
  final captcha = TextEditingController();
  final otp = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();

  bool userVerified = false;
  bool loading = false;
  String captchaId = '';
  String captchaImage = '';
  int userId = 0;
  String otpReference = '';
  int seconds = 0;
  Timer? timer;
  String? message;

  @override
  void initState() {
    super.initState();
    _loadCaptcha();
  }

  @override
  void dispose() {
    timer?.cancel();
    username.dispose();
    mobile.dispose();
    captcha.dispose();
    otp.dispose();
    newPassword.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _loadCaptcha() async {
    try {
      final result = await api.generateCaptcha();
      if (!mounted) return;
      setState(() {
        captchaId = result['captchaId']?.toString() ?? '';
        captchaImage = result['captchaImage']?.toString() ?? '';
        captcha.clear();
      });
    } catch (_) {
      if (mounted) setState(() => message = 'Unable to load CAPTCHA.');
    }
  }

  void _startTimer() {
    timer?.cancel();
    setState(() => seconds = 120);
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (seconds <= 1) {
        timer.cancel();
        setState(() => seconds = 0);
      } else {
        setState(() => seconds--);
      }
    });
  }

  Future<void> _sendOtp() async {
    if (username.text.trim().isEmpty || mobile.text.trim().length != 10) {
      setState(
        () => message = 'Enter a valid username and 10-digit mobile number.',
      );
      return;
    }
    if (captcha.text.trim().isEmpty) {
      setState(() => message = 'Enter the CAPTCHA.');
      return;
    }
    setState(() {
      loading = true;
      message = null;
    });
    try {
      final validCaptcha = await api.validateCaptcha(
        captchaId: captchaId,
        captchaValue: captcha.text.trim(),
      );
      if (!validCaptcha) {
        setState(() => message = 'Invalid CAPTCHA.');
        await _loadCaptcha();
        return;
      }
      final result = await api.requestPasswordReset(
        username: username.text.trim(),
        mobileNumber: mobile.text.trim(),
      );
      if (!mounted) return;
      if ((result['status'] ?? 0).toString() == '1') {
        userId = int.tryParse(result['userId'].toString()) ?? 0;
        otpReference = result['otpRef']?.toString() ?? '';
        setState(() {
          userVerified = true;
          message = 'OTP sent to your mobile number.';
        });
        _startTimer();
      } else {
        setState(
          () => message =
              result['message']?.toString() ?? 'No matching user was found.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => message = 'Unable to request password reset.');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      loading = true;
      message = null;
    });
    try {
      final result = await api.resendOtp(userId: userId);
      if (!mounted) return;
      otpReference = result['mfaReferenceCode']?.toString() ?? otpReference;
      setState(() => message = 'A new OTP has been sent.');
      _startTimer();
    } catch (_) {
      if (mounted) setState(() => message = 'Unable to resend OTP.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  bool _validPassword(String value) =>
      value.length >= 12 &&
      value.length <= 15 &&
      RegExp(r'[0-9]').hasMatch(value) &&
      RegExp(r'[a-z]').hasMatch(value) &&
      RegExp(r'[A-Z]').hasMatch(value) &&
      RegExp(r'[!@#\$%^&*]').hasMatch(value);

  Future<void> _updatePassword() async {
    if (otp.text.trim().isEmpty ||
        !_validPassword(newPassword.text) ||
        newPassword.text != confirmPassword.text) {
      setState(
        () => message =
            'Enter the OTP and a matching 12–15 character password with uppercase, lowercase, number, and special character.',
      );
      return;
    }
    setState(() {
      loading = true;
      message = null;
    });
    try {
      final result = await api.updateForgottenPassword(
        userId: userId,
        otpReference: otpReference,
        otp: otp.text.trim(),
        newPassword: newPassword.text,
      );
      if (!mounted) return;
      if ((result['status'] ?? 0).toString() == '1') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successfully.')),
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

  Widget _captchaImage() {
    if (captchaImage.isEmpty) return const SizedBox.shrink();
    try {
      final bytes = Uri.parse(
        'data:image/png;base64,$captchaImage',
      ).data!.contentAsBytes();
      return Image.memory(Uint8List.fromList(bytes), height: 70);
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: userVerified ? _resetForm() : _requestForm(),
          ),
        ),
      ),
    );
  }

  Widget _requestForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'Enter your username and mobile number. A 6-digit OTP will be sent to verify your details.',
      ),
      const SizedBox(height: 20),
      TextField(
        controller: username,
        decoration: const InputDecoration(
          labelText: 'User name',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: mobile,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          labelText: 'Mobile number',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      Center(child: _captchaImage()),
      TextField(
        controller: captcha,
        decoration: InputDecoration(
          labelText: 'CAPTCHA',
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            onPressed: loading ? null : _loadCaptcha,
            icon: const Icon(Icons.refresh),
          ),
        ),
      ),
      if (message != null) _message(),
      const SizedBox(height: 20),
      FilledButton(
        onPressed: loading ? null : _sendOtp,
        child: Text(loading ? 'SENDING...' : 'SEND OTP'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('BACK TO LOGIN'),
      ),
    ],
  );

  Widget _resetForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text('Enter the OTP sent to your mobile, then set a new password.'),
      const SizedBox(height: 20),
      TextField(
        controller: otp,
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
            onPressed: loading || seconds > 0 ? null : _resendOtp,
            child: const Text('RESEND'),
          ),
        ],
      ),
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
      if (message != null) _message(),
      const SizedBox(height: 20),
      FilledButton(
        onPressed: loading ? null : _updatePassword,
        child: Text(loading ? 'RESETTING...' : 'RESET PASSWORD'),
      ),
    ],
  );

  Widget _message() => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Text(message!, textAlign: TextAlign.center),
  );
}
