import '../models/auth/login_model.dart';
import '../services/api_service.dart';

class LoginRepository {
  final ApiService _apiService;

  LoginRepository({
    ApiService? apiService,
  }) : _apiService = apiService ?? ApiService();

  Future<LoginModel> login({
    required String userName,
    required String password,
    required String timeStamp,
  }) async {
    return await _apiService.login(
      userName: userName,
      password: password,
      timeStamp: timeStamp,
    );
  }
}