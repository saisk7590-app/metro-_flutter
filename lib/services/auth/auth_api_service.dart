import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../models/auth/login_model.dart';
import '../../utils/password_encryption.dart';
import '../../utils/token_diagnostics.dart';
import '../base_api_service.dart';

/// Service handling authentication, sessions, CAPTCHA, and password recovery.
class AuthApiService extends BaseApiService {
  /// Authenticate user credentials and retrieve JWT token & session
  Future<LoginModel> login({
    required String userName,
    required String password,
    required String timeStamp,
    String captchaId = '',
    String captchaValue = '',
  }) async {
    final response = await BaseApiService.client.post(
      Uri.parse(
        'https://nxamsdev.winfocus.co.in/NxAmsDevServices/adminService/api/Admin/login',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'UserName': userName,
        'Password': password,
        'TimeStamp': timeStamp,
        'BrowserInfo': '',
        'CaptchaId': captchaId,
        'CaptchaValue': captchaValue,
        'IpAddress': '',
        'IspAddress': '',
      }),
    );

    debugPrint('Login API Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      logTokenDiagnostics(
        'login response token',
        data['token']?.toString() ?? '',
      );
      BaseApiService.currentToken = BaseApiService.sanitizeToken(data['token']?.toString() ?? '');
      BaseApiService.currentUserSession = base64Encode(utf8.encode(response.body));
      BaseApiService.currentRoleId = data['roleIds']?.toString().split(',').first.trim() ?? '1';
      return LoginModel.fromJson(data, rawBody: response.body);
    }
    throw Exception('Login failed: ${response.statusCode} ${response.body}');
  }

  /// Invalidate user session and clear local auth tokens
  Future<bool> logout({
    String userSession = '',
    String userSessionId = '',
    String remarks = 'User Logout',
  }) async {
    try {
      final response = await postJson(
        '/adminService/api/Admin/logout',
        base: 'https://nxamsdev.winfocus.co.in/NxAmsDevServices',
        body: {
          'Params': [
            {'key': 'UserSession', 'value': userSession},
            {'key': 'UserSessionId', 'value': userSessionId},
            {'key': 'Remarks', 'value': remarks},
          ],
        },
      );
      debugPrint('Logout API Status: ${response.statusCode}');
      debugPrint('Logout API Response: ${response.body}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['status'] == 1 || decoded['statusCode'] == 200;
      }
    } catch (e) {
      debugPrint('Logout API error: $e');
    } finally {
      BaseApiService.currentToken = null;
      BaseApiService.currentUserSession = null;
      BaseApiService.currentRoleId = null;
    }
    return false;
  }

  /// Generate a new CAPTCHA image and ID for authentication
  Future<Map<String, dynamic>> generateCaptcha() async {
    final response = await BaseApiService.client.post(
      Uri.parse(
        'https://nxamsdev.winfocus.co.in/NxAmsDevServices/adminService/api/Admin/GenerateCaptcha',
      ),
    );
    if (response.statusCode != 200) {
      throw Exception('Unable to load CAPTCHA: ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Validate user entered CAPTCHA value against captchaId
  Future<bool> validateCaptcha({
    required String captchaId,
    required String captchaValue,
  }) async {
    final response = await BaseApiService.client.post(
      Uri.parse(
        'https://nxamsdev.winfocus.co.in/NxAmsDevServices/adminService/api/Admin/ValidateCaptcha',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'captchaId': captchaId, 'captchaValue': captchaValue}),
    );
    if (response.statusCode != 200) return false;
    final result = jsonDecode(response.body);
    return result is Map<String, dynamic> && result['isValid'] == true;
  }

  /// Request password reset via username and registered mobile number
  Future<Map<String, dynamic>> requestPasswordReset({
    required String username,
    required String mobileNumber,
  }) async {
    final response = await BaseApiService.client.post(
      Uri.parse(
        'https://nxamsdev.winfocus.co.in/NxAmsDevServices/adminService/api/Admin/request-reset-pwd',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Params': [
          {'key': 'username', 'value': username},
          {'key': 'mobileno', 'value': mobileNumber},
        ],
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Password reset request failed');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Validate OTP entered during MFA or password reset
  Future<Map<String, dynamic>> validateOtp({
    required int userId,
    required String mfaReference,
    required String otp,
  }) async {
    final response = await BaseApiService.client.post(
      Uri.parse(
        'https://nxamsdev.winfocus.co.in/NxAmsDevServices/adminService/api/Admin/validate-OTP',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Params': [
          {'key': 'UserId', 'value': userId.toString()},
          {'key': 'MFAReference', 'value': mfaReference},
          {'key': 'otp', 'value': otp},
        ],
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('OTP validation failed');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Resend OTP to user's registered contact
  Future<Map<String, dynamic>> resendOtp({required int userId}) async {
    final response = await BaseApiService.client.post(
      Uri.parse(
        'https://nxamsdev.winfocus.co.in/NxAmsDevServices/adminService/api/Admin/resend-OTP',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Params': [
          {'key': 'UserId', 'value': userId.toString()},
        ],
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Unable to resend OTP');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Update password following OTP verification in forgot password workflow
  Future<Map<String, dynamic>> updateForgottenPassword({
    required int userId,
    required String otpReference,
    required String otp,
    required String newPassword,
  }) async {
    final response = await BaseApiService.client.post(
      Uri.parse(
        'https://nxamsdev.winfocus.co.in/NxAmsDevServices/adminService/api/Admin/request-update-pwd',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Params': [
          {'key': 'userid', 'value': userId.toString()},
          {'key': 'otpref', 'value': otpReference},
          {
            'key': 'password',
            'value': PasswordEncryption.encryptPassword(newPassword),
          },
          {'key': 'otp', 'value': otp},
          {
            'key': 'timestamp',
            'value': DateTime.now().toUtc().toIso8601String(),
          },
        ],
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Password update failed');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Reset password directly for an authenticated or admin user
  Future<Map<String, dynamic>> resetPassword({
    required int userId,
    required String newPassword,
    required int updatedBy,
  }) async {
    final response = await BaseApiService.client.post(
      Uri.parse(
        'https://nxamsdev.winfocus.co.in/NxAmsDevServices/adminService/api/Admin/reset-password',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'UserId': userId,
        'NewPassword': PasswordEncryption.encryptPassword(newPassword),
        'UpdatedBy': updatedBy,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Password reset failed');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
