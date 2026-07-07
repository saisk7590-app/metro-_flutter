import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/status_model.dart';
import '../models/maintenance_purpose_model.dart';
import '../models/train_model.dart';
import '../models/maintenance_bay_model.dart';

class ApiService {
  static const String baseUrl =
      'http://192.168.14.60/services/assetregister/api';

  /// STATUS API
  Future<List<StatusModel>> getMaintenanceStatus() async {
    final response = await http.post(
      Uri.parse('$baseUrl/asset-register/get-maintenance-status'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((json) => StatusModel.fromJson(json)).toList();
    }

    throw Exception('Failed to load status: ${response.statusCode}');
  }

  /// MAINTENANCE PURPOSE API
  Future<List<MaintenancePurposeModel>> getMaintenancePurposes() async {
    final response = await http.post(
      Uri.parse('$baseUrl/asset-register/get-maintenance-purpose'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((json) => MaintenancePurposeModel.fromJson(json))
          .toList();
    }

    throw Exception(
      'Failed to load maintenance purposes: ${response.statusCode}',
    );
  }

  /// TRAIN SET API
  Future<List<TrainModel>> getTrainSets() async {
    final response = await http.post(
      Uri.parse(
        'http://192.168.14.60/services/assetconfig/api/assetconfig/get-trainset-list',
      ),
      headers: {'Content-Type': 'application/json', 'Role-id': '1'},
      body: jsonEncode({
        "Params": [
          {"Key": "TSNo", "Value": ""},
        ],
      }),
    );
    // debugPrint('Train API Status: ${response.statusCode}');
    // debugPrint('Train API Response: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((e) => TrainModel.fromJson(e)).toList();
    }

    throw Exception('Failed to load train sets: ${response.statusCode}');
  }

  Future<List<MaintenanceBayModel>> getMaintenanceBay(int depotId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/asset-register/search-maintenancebay'),
      headers: {'Content-Type': 'application/json', 'Role-id': '1'},
      body: jsonEncode({
        "params": [
          {"key": "MbDepot", "value": depotId.toString()},
        ],
      }),
    );

    debugPrint('Maintenance Bay Status: ${response.statusCode}');

    debugPrint('Maintenance Bay Response: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final List<dynamic> results = json['results'];

      return results.map((e) => MaintenanceBayModel.fromJson(e)).toList();
    }

    throw Exception('Failed to load maintenance bay');
  }

  //SAVE API
  Future<Map<String, dynamic>> saveMaintenanceBay({
    required int mbId,
    required int mbDepot,
    required int mbSlot,
    required int mbTrainSet,
    required int mbStatus,
    required int mbPurpose,
    required String mbInward,
    required String mbOutward,
    required String mbRemark,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/asset-register/save-maintenance-bay'),
      headers: {'Content-Type': 'application/json', 'Role-id': '1'},
      body: jsonEncode({
        "mbId": mbId,
        "mbDepot": mbDepot,
        "mbSlot": mbSlot,
        "mbTrainSet": mbTrainSet,
        "mbStatus": mbStatus,
        "mbPurpose": mbPurpose,
        "mbInward": mbInward,
        "mbOutward": mbOutward,
        "mbRemark": mbRemark,
        "mbIsAllocated": true,
        "createdBy": 1,
        "updatedBy": 1,
        "isOutward": false,
      }),
    );

    debugPrint('Save API Status: ${response.statusCode}');
    debugPrint('Save API Response: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to save maintenance bay');
  }
}
