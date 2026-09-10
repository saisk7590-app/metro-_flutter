import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
//import 'package:crypto/crypto.dart';

import '../models/auth/login_model.dart';
import '../models/trainset_meter_reading_model.dart';

import '../models/status_model.dart';
import '../models/maintenance_purpose_model.dart';
import '../models/train_model.dart';
import '../models/maintenance_bay_model.dart';
import '../utils/token_diagnostics.dart';

class ApiService {
  static const String baseUrl =
      'http://192.168.14.60/services/assetregister/api';

  String _fingerprint(String value) {
    return crypto.sha256
        .convert(utf8.encode(value))
        .toString()
        .substring(0, 12);
  }

  // ============================================================
  // LOGIN API
  // ============================================================

  Future<LoginModel> login({
    required String userName,
    required String password,
    required String timeStamp,
  }) async {
    final response = await http.post(
      Uri.parse(
        'https://nxamsdev.winfocus.co.in/NxAmsDevServices/adminService/api/Admin/login',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'UserName': userName,
        'Password': password,
        'TimeStamp': timeStamp,
        'BrowserInfo': '',
        'CaptchaId': '',
        'CaptchaValue': '',
        'IpAddress': '',
        'IspAddress': '',
      }),
    );

    debugPrint('Login API Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final loginToken = data['token'] as String? ?? '';

      logTokenDiagnostics('login response token', loginToken);

      return LoginModel.fromJson(data);
    }

    throw Exception('Login failed: ${response.statusCode} ${response.body}');
  }
  // ============================================================
  // TRAINSET METER LIST API
  // ============================================================

  // ============================================================
  // TRAINSET METER READING API
  // ============================================================

  Future<List<TrainsetMeterReadingModel>> getTrainsetMeterReadings({
    required String date,
    required int pageNo,
    required int pageSize,
    required int pagination,
    required String token,
    required String userSession,
    required String roleId,
  }) async {
    // ------------------------------------------------------------
    // REQUEST BODY
    // ------------------------------------------------------------

    final requestBody = {
      'Params': [
        {'key': 'Date', 'value': date},
        {'key': 'PageNo', 'value': pageNo.toString()},
        {'key': 'PageSize', 'value': pageSize.toString()},
        {'key': 'Pagenation', 'value': pagination.toString()},
      ],
    };

    final body = jsonEncode(requestBody);
    final hashCheck = crypto.Hmac(
      crypto.sha256,
      utf8.encode('UW1nF0cu5S'),
    ).convert(utf8.encode(body)).toString();

    // ------------------------------------------------------------
    // DEBUG
    // ------------------------------------------------------------

    debugPrint('================ TRAINSET API DEBUG ================');

    debugPrint('Authorization token received: ${token.isNotEmpty}');
    debugPrint('UserSession received: ${userSession.isNotEmpty}');
    debugPrint('Role-Id: $roleId');

    debugPrint('Request Body:');
    debugPrint(body);

    // ------------------------------------------------------------
    // API REQUEST
    // ------------------------------------------------------------

    final uri = Uri.parse(
      'https://nxamsdev.winfocus.co.in/NxAmsDevServices/assetregister/api/asset-register/get-trainsets-meterreading',
    );
    final fullToken = token.replaceFirst(
      RegExp(r'^Bearer\s+', caseSensitive: false),
      '',
    );
    logTokenDiagnostics('after removing Bearer', fullToken);
    final jwtToken = fullToken.split('&gF=').first;
    logTokenDiagnostics('after removing &gF=', jwtToken);
    debugPrint('Meter session fingerprint: ${_fingerprint(userSession)}');

    Map<String, String> headersFor(String value) => {
      'Accept': 'application/json, text/plain, */*',
      'Content-Type': 'application/json',
      'Hash-Check': hashCheck,
      'Authorization': 'Bearer $value',
      'Role-Id': roleId,
      'userSession': userSession,
      'Origin': 'https://nxamsdev.winfocus.co.in',
      'Referer': 'https://nxamsdev.winfocus.co.in/',
    };

    logTokenDiagnostics('immediately before Authorization header', jwtToken);

    final response = await http.post(
      uri,
      headers: headersFor(jwtToken),
      body: body,
    );

    // ------------------------------------------------------------
    // RESPONSE
    // ------------------------------------------------------------

    debugPrint('Trainset Meter Reading Status: ${response.statusCode}');
    debugPrint('Trainset Meter Reading Response: ${response.body}');

    debugPrint('====================================================');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final rawResults = decoded is Map<String, dynamic>
          ? decoded['results']
          : decoded;
      final List<dynamic> results = rawResults is String
          ? jsonDecode(rawResults) as List<dynamic>
          : rawResults as List<dynamic>? ?? <dynamic>[];

      return results.map((e) => TrainsetMeterReadingModel.fromJson(e)).toList();
    }

    throw Exception(
      'Failed to load trainset meter readings: ${response.statusCode} ${response.body}',
    );
  }
  // ============================================================
  // STATUS API
  // ============================================================

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

  // ============================================================
  // MAINTENANCE PURPOSE API
  // ============================================================

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

  // ============================================================
  // TRAIN SET API
  // ============================================================

  Future<List<TrainModel>> getTrainSets() async {
    final response = await http.post(
      Uri.parse(
        'http://192.168.14.60/services/assetconfig/api/assetconfig/get-trainset-list',
      ),
      headers: {'Content-Type': 'application/json', 'Role-id': '1'},
      body: jsonEncode({
        'Params': [
          {'Key': 'TSNo', 'Value': ''},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((e) => TrainModel.fromJson(e)).toList();
    }

    throw Exception('Failed to load train sets: ${response.statusCode}');
  }

  // ============================================================
  // MAINTENANCE BAY API
  // ============================================================

  Future<List<MaintenanceBayModel>> getMaintenanceBay(int depotId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/asset-register/search-maintenancebay'),
      headers: {'Content-Type': 'application/json', 'Role-id': '1'},
      body: jsonEncode({
        'params': [
          {'key': 'MbDepot', 'value': depotId.toString()},
        ],
      }),
    );

    debugPrint('Maintenance Bay Status: ${response.statusCode}');

    debugPrint('Maintenance Bay Response: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);

      final List<dynamic> results = json['results'];

      return results.map((e) => MaintenanceBayModel.fromJson(e)).toList();
    }

    throw Exception('Failed to load maintenance bay');
  }

  // ============================================================
  // SAVE MAINTENANCE BAY API
  // ============================================================

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
        'mbId': mbId,
        'mbDepot': mbDepot,
        'mbSlot': mbSlot,
        'mbTrainSet': mbTrainSet,
        'mbStatus': mbStatus,
        'mbPurpose': mbPurpose,
        'mbInward': mbInward,
        'mbOutward': mbOutward,
        'mbRemark': mbRemark,
        'mbIsAllocated': true,
        'createdBy': 1,
        'updatedBy': 1,
        'isOutward': false,
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
