import 'package:flutter/foundation.dart';
import '../models/profile_model.dart';
import '../services/api_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ApiService _apiService;

  ProfileProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  StaffProfileModel? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  StaffProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProfile(String staffId) async {
    if (staffId.isEmpty || staffId == '0') return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.getStaffDetails(staffId: staffId);
      _profile = res;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('ProfileProvider fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String mobile,
    required String email,
  }) async {
    if (_profile == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedJson = _profile!.toJson();
      updatedJson['mobile'] = mobile.trim();
      updatedJson['eMail'] = email.trim();
      final success = await _apiService.updateStaffProfile(
        staff: updatedJson,
      );
      if (success) {
        _profile = StaffProfileModel.fromJson(updatedJson);
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error updating profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  void clearProfile() {
    _profile = null;
    _errorMessage = null;
    notifyListeners();
  }
}
