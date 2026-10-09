import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/auth/forgot_password_forms.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: userVerified
                ? ForgotPasswordResetForm(
                    otpController: otp,
                    newPasswordController: newPassword,
                    confirmPasswordController: confirmPassword,
                    seconds: seconds,
                    loading: loading,
                    message: message,
                    onResendOtp: _resendOtp,
                    onResetPassword: _updatePassword,
                  )
                : ForgotPasswordRequestForm(
                    usernameController: username,
                    mobileController: mobile,
                    captchaController: captcha,
                    captchaImage: captchaImage,
                    loading: loading,
                    message: message,
                    onRefreshCaptcha: _loadCaptcha,
                    onSendOtp: _sendOtp,
                    onBackToLogin: () => Navigator.pop(context),
                  ),
          ),
        ),
      ),
    );
  }
}
