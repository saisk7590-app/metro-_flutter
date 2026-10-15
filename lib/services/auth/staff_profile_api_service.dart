import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../models/auth/profile_model.dart';
import '../base_api_service.dart';

/// Service handling user profiles and staff details.
class StaffProfileApiService extends BaseApiService {
  /// Fetch staff details for user profile
  Future<StaffProfileModel?> getStaffDetails({required String staffId}) async {
    try {
      final response = await postJson(
        '/Admin/get-staff-details',
        base: BaseApiService.adminBase,
        body: {
          'SearchByName': '',
          'SearchByValue': staffId.trim(),
        },
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return StaffProfileModel.fromJson(decoded);
        }
      }
    } catch (e) {
      debugPrint('getStaffDetails API error: $e');
    }
    return null;
  }

  /// Update staff profile (adminService/api/Admin/update-profile)
  Future<bool> updateStaffProfile({required Map<String, dynamic> staff}) async {
    try {
      final response = await postJson(
        '/Admin/update-profile',
        base: BaseApiService.adminBase,
        body: staff,
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final status = decoded['status'] ?? decoded['Status'];
          return status != null && (int.tryParse(status.toString()) ?? 0) > 0;
        }
        return true;
      }
    } catch (e) {
      debugPrint('updateStaffProfile API error: $e');
    }
    return false;
  }
}
