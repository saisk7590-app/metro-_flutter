import 'package:flutter/foundation.dart';

import '../models/auth/login_model.dart';
import '../repositories/login_repository.dart';
import '../services/api_service.dart';
import '../utils/password_encryption.dart';
import '../utils/token_diagnostics.dart';

class LoginProvider extends ChangeNotifier {
  final LoginRepository _repository;

  LoginProvider({LoginRepository? repository})
    : _repository = repository ?? LoginRepository();

  bool _isLoading = false;
  String? _errorMessage;
  LoginModel? _loginData;
  String? _selectedRoleId;
  String? _selectedRoleName;
  String? _selectedUnitAccessScope;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LoginModel? get loginData => _loginData;

  bool get isLoggedIn => _loginData != null;
  String? get selectedRoleId => _selectedRoleId;
  String? get selectedRoleName => _selectedRoleName;
  String? get selectedUnitAccessScope => _selectedUnitAccessScope;

  void selectRole({
    required String roleId,
    required String roleName,
    required String unitAccessScope,
  }) {
    _selectedRoleId = roleId;
    _selectedRoleName = roleName;
    _selectedUnitAccessScope = unitAccessScope;
    ApiService.currentRoleId = roleId;
    notifyListeners();
  }

  Future<bool> login({
    required String userName,
    required String password,
    required String timeStamp,
    String captchaId = '',
    String captchaValue = '',
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      // Encrypt password exactly like the existing AMS application
      final encryptedPassword = PasswordEncryption.encryptPassword(password);

      final result = await _repository.login(
        userName: userName,
        password: encryptedPassword,
        timeStamp: timeStamp,
        captchaId: captchaId,
        captchaValue: captchaValue,
      );

      logTokenDiagnostics('before LoginProvider storage', result.token);
      _loginData = result;
      ApiService.currentToken = result.token;
      ApiService.currentUserSession = result.encodedUserSession;
      ApiService.currentRoleId = _selectedRoleId ?? result.roleIds.split(',').first.trim();

      _isLoading = false;

      if (result.loginResult != 1) {
        _errorMessage = result.loginMessage.isNotEmpty
            ? result.loginMessage
            : 'The server rejected the login credentials.';
      }

      notifyListeners();

      return result.loginResult == 1;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> logout() async {
    final session = _loginData?.userSession ?? '';
    final sessionId = _loginData?.userSessionId.toString() ?? '';
    try {
      await _repository.logout(
        userSession: session,
        userSessionId: sessionId,
      );
    } catch (e) {
      debugPrint('Logout provider error: $e');
    } finally {
      _loginData = null;
      _errorMessage = null;
      _selectedRoleId = null;
      notifyListeners();
    }
  }
}
