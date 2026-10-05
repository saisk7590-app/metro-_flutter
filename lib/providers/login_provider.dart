import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth/login_model.dart';
import '../repositories/login_repository.dart';
import '../services/api_service.dart';
import '../utils/password_encryption.dart';
import '../utils/token_diagnostics.dart';

class LoginProvider extends ChangeNotifier {
  static const _kBiometricEnabled = 'ams_biometric_enabled';
  static const _kSavedLoginJson = 'ams_saved_login_json';
  static const _kSavedRawBody = 'ams_saved_raw_body';
  static const _kSavedRoleId = 'ams_saved_role_id';
  static const _kSavedRoleName = 'ams_saved_role_name';
  static const _kSavedUnitScope = 'ams_saved_unit_scope';
  static const _kSavedDisplayName = 'ams_saved_display_name';
  static const _kSavedUserName = 'ams_saved_user_name';

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

  Future<void> saveSessionForBiometrics({
    String? roleId,
    String? roleName,
    String? unitAccessScope,
  }) async {
    if (_loginData == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kBiometricEnabled, true);
      await prefs.setString(_kSavedLoginJson, jsonEncode(_loginData!.toJson()));
      if (_loginData!.rawBody != null) {
        await prefs.setString(_kSavedRawBody, _loginData!.rawBody!);
      }
      final rId = roleId ?? _selectedRoleId ?? _loginData!.roleIds.split(',').first.trim();
      final rName = roleName ?? _selectedRoleName ?? _loginData!.roleNames.split(',').first.trim();
      final uScope = unitAccessScope ?? _selectedUnitAccessScope ?? _loginData!.unitAccessScopes.split(',').first.trim();
      await prefs.setString(_kSavedRoleId, rId);
      await prefs.setString(_kSavedRoleName, rName);
      await prefs.setString(_kSavedUnitScope, uScope);
      final displayName = _loginData!.staffName.isNotEmpty ? _loginData!.staffName : _loginData!.userName;
      await prefs.setString(_kSavedDisplayName, displayName);
      await prefs.setString(_kSavedUserName, _loginData!.userName);
    } catch (e) {
      debugPrint('Error saving session for biometrics: $e');
    }
  }

  static Future<bool> hasSavedBiometricSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(_kBiometricEnabled) ?? false;
      final savedJson = prefs.getString(_kSavedLoginJson);
      return enabled && savedJson != null && savedJson.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static Future<String> getSavedUserDisplayName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kSavedDisplayName) ?? prefs.getString(_kSavedUserName) ?? 'User';
    } catch (e) {
      return 'User';
    }
  }

  Future<bool> restoreSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(_kSavedLoginJson);
      if (savedJson == null || savedJson.isEmpty) return false;

      final rawBody = prefs.getString(_kSavedRawBody);
      final jsonMap = jsonDecode(savedJson) as Map<String, dynamic>;
      final model = LoginModel.fromJson(jsonMap, rawBody: rawBody);

      _loginData = model;
      _selectedRoleId = prefs.getString(_kSavedRoleId) ?? model.roleIds.split(',').first.trim();
      _selectedRoleName = prefs.getString(_kSavedRoleName) ?? model.roleNames.split(',').first.trim();
      _selectedUnitAccessScope = prefs.getString(_kSavedUnitScope) ?? model.unitAccessScopes.split(',').first.trim();

      ApiService.currentToken = model.token;
      ApiService.currentUserSession = model.encodedUserSession;
      ApiService.currentRoleId = _selectedRoleId;

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error restoring saved session: $e');
      return false;
    }
  }

  static Future<void> clearSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kBiometricEnabled);
      await prefs.remove(_kSavedLoginJson);
      await prefs.remove(_kSavedRawBody);
      await prefs.remove(_kSavedRoleId);
      await prefs.remove(_kSavedRoleName);
      await prefs.remove(_kSavedUnitScope);
      await prefs.remove(_kSavedDisplayName);
      await prefs.remove(_kSavedUserName);
    } catch (e) {
      debugPrint('Error clearing saved session: $e');
    }
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
      await clearSavedSession();
      _loginData = null;
      _errorMessage = null;
      _selectedRoleId = null;
      _selectedRoleName = null;
      _selectedUnitAccessScope = null;
      notifyListeners();
    }
  }
}

