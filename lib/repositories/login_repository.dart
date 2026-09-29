import '../models/auth/login_model.dart';
import '../services/api_service.dart';

class LoginRepository {
  final ApiService _apiService;

  LoginRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<LoginModel> login({
    required String userName,
    required String password,
    required String timeStamp,
    String captchaId = '',
    String captchaValue = '',
  }) async {
    return await _apiService.login(
      userName: userName,
      password: password,
      timeStamp: timeStamp,
      captchaId: captchaId,
      captchaValue: captchaValue,
    );
  }

  Future<bool> logout({
    String userSession = '',
    String userSessionId = '',
    String remarks = 'User Logout',
  }) async {
    return await _apiService.logout(
      userSession: userSession,
      userSessionId: userSessionId,
      remarks: remarks,
    );
  }
}
