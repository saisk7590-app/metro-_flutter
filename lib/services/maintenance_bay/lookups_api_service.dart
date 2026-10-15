import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../models/maintenance_bay/maintenance_purpose_model.dart';
import '../../models/maintenance_bay/status_model.dart';
import '../../models/maintenance_bay/train_model.dart';
import '../base_api_service.dart';

/// Service handling asset lookups, maintenance statuses, purposes, and trainset lists.
class LookupsApiService extends BaseApiService {
  /// Fetch maintenance bay statuses (lookups)
  Future<List<StatusModel>> getMaintenanceStatus() async {
    final response = await postJson(
      '/assetconfig/get-lookups',
      base: BaseApiService.assetConfigBase,
      body: {
        'Params': [
          {'key': 'name', 'value': 'Maintenance Bay Status'},
          {'key': 'id', 'value': ''},
        ],
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final itemList = decoded is List
          ? decoded
          : (decoded is Map ? [decoded] : []);
      final matches = itemList.whereType<Map<String, dynamic>>().where((entry) {
        final nameValue = entry['lookup_name'] ?? entry['lookupName'] ?? '';
        return nameValue.toString() == 'Maintenance Bay Status';
      });
      final lookupEntry = matches.isNotEmpty
          ? matches.first
          : <String, dynamic>{};
      final values =
          lookupEntry['lookupvalues'] ??
          lookupEntry['lookupValues'] ??
          lookupEntry['values'] ??
          <dynamic>[];
      final listData = values is List ? values : <dynamic>[];

      return listData
          .whereType<Map<String, dynamic>>()
          .map((json) => StatusModel.fromJson(json))
          .toList();
    }

    throw Exception('Failed to load status: ${response.statusCode}');
  }

  /// Fetch maintenance schedule types / purposes
  Future<List<MaintenancePurposeModel>> getMaintenancePurposes() async {
    final response = await postJson(
      '/maintenanceconfig/get-schedule-types',
      base: BaseApiService.maintenanceConfigBase,
      body: {
        'Params': [
          {'key': 'Name', 'value': ''},
          {'key': 'Type', 'value': ''},
        ],
      },
    );

    if (response.statusCode == 200) {
      final data = normalizeListResponse(jsonDecode(response.body));

      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => MaintenancePurposeModel.fromJson(json))
          .toList();
    }

    throw Exception(
      'Failed to load maintenance purposes: ${response.statusCode}',
    );
  }

  /// Fetch list of all trainsets
  Future<List<TrainModel>> getTrainSets({
    String? token,
    String? userSession,
    String? roleId,
  }) async {
    final customHeaders = <String, String>{};
    if (token != null && token.isNotEmpty) {
      customHeaders['Authorization'] = token;
    }
    if (userSession != null && userSession.isNotEmpty) {
      customHeaders['userSession'] = userSession;
    }
    if (roleId != null && roleId.isNotEmpty) {
      customHeaders['Role-Id'] = roleId;
    }

    final response = await postJson(
      '/assetconfig/get-trainset-list',
      base: BaseApiService.assetConfigBase,
      body: {
        'Params': [
          {'key': 'TSNo', 'value': ''},
        ],
      },
      headers: customHeaders.isNotEmpty ? customHeaders : null,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = normalizeListResponse(decoded);
      debugPrint('Trainsets Status: ${response.statusCode} (loaded ${data.length} trainsets)');

      return data
          .whereType<Map>()
          .map((e) => TrainModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    throw Exception('Failed to load train sets: ${response.statusCode}');
  }
}
