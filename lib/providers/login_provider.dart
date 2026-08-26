import 'package:flutter/foundation.dart';

import '../models/auth/login_model.dart';
import '../repositories/login_repository.dart';
import '../utils/password_encryption.dart';

class LoginProvider extends ChangeNotifier {
  final LoginRepository _repository;

  LoginProvider({
    LoginRepository? repository,
  }) : _repository = repository ?? LoginRepository();

  bool _isLoading = false;
  String? _errorMessage;
  LoginModel? _loginData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LoginModel? get loginData => _loginData;

  bool get isLoggedIn => _loginData != null;

  Future<bool> login({
    required String userName,
    required String password,
    required String timeStamp,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      // Encrypt password exactly like the existing AMS application
      final encryptedPassword =
          PasswordEncryption.encryptPassword(password);

      final result = await _repository.login(
        userName: userName,
        password: encryptedPassword,
        timeStamp: timeStamp,
      );

      _loginData = result;

      _isLoading = false;

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

  void logout() {
    _loginData = null;
    _errorMessage = null;
    notifyListeners();
  }
}