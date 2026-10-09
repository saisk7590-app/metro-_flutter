import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../http_client_runner.dart';

import '../models/auth/login_model.dart';
import '../models/trainset_meter_reading_model.dart';

import '../models/status_model.dart';
import '../models/maintenance_purpose_model.dart';
import '../models/train_model.dart';
import '../models/maintenance_bay_model.dart';
import '../models/wheel_measurement_model.dart';
import '../models/checklist_model.dart';
import '../models/notification_model.dart';
import '../models/profile_model.dart';
import '../utils/token_diagnostics.dart';
import '../utils/password_encryption.dart';

class ApiService {
  static const String baseUrl =
      'https://nxamsdev.winfocus.co.in/NxAmsDevServices/assetregister/api';
  static const String assetConfigBase =
      'https://nxamsdev.winfocus.co.in/NxAmsDevServices/assetconfig/api';
  static const String maintenanceConfigBase =
      'https://nxamsdev.winfocus.co.in/NxAmsDevServices/maintenanceconfig/api';
  static const String workOrderBase =
      'https://nxamsdev.winfocus.co.in/NxAmsDevServices/workorderservice/api';
  static const String messagingBase =
      'https://nxamsdev.winfocus.co.in/NxAmsDevServices/messaging/api';
  static const String adminBase =
      'https://nxamsdev.winfocus.co.in/NxAmsDevServices/adminService/api';

  static String? currentToken;
  static String? currentUserSession;
  static String? currentRoleId;
  static http.Client get _client => getAppHttpClient();

  static String sanitizeToken(String raw) {
    var clean = raw.replaceFirst(RegExp(r'^Bearer\s+', caseSensitive: false), '').trim();
    if (clean.contains('k&gF=')) {
      clean = clean.replaceFirst(RegExp(r'k&gF=(?=.{8}$)'), '');
    }
    if (clean.contains('&gF=')) {
      clean = clean.split('&gF=').first;
    }
    return clean;
  }

  /// Checks if a JWT token has expired by inspecting the 'exp' claim.
  static bool isTokenExpired(String? token) {
    if (token == null || token.trim().isEmpty) return true;
    try {
      final clean = sanitizeToken(token);
      final parts = clean.split('.');
      if (parts.length < 2) return true;
      var payload = parts[1];
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      final decodedJson = utf8.decode(base64.decode(payload));
      final map = jsonDecode(decodedJson);
      if (map is Map<String, dynamic> && map['exp'] != null) {
        final expSeconds = map['exp'] as int;
        final expiryTime = DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000);
        return DateTime.now().isAfter(expiryTime);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<http.Response> _postJson(
    String endpoint, {
    String base = '',
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final targetBase = base.isNotEmpty ? base : baseUrl;
    final uri = Uri.parse('$targetBase$endpoint');

    final jsonBody = body == null ? '' : jsonEncode(body);
    final hashCheck = crypto.Hmac(
      crypto.sha256,
      utf8.encode('UW1nF0cu5S'),
    ).convert(utf8.encode(jsonBody)).toString();

    final effectiveHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json, text/plain, */*',
      'Hash-Check': hashCheck,
    };

    final rawToken = headers?['Authorization'] ?? currentToken;
    if (rawToken != null && rawToken.isNotEmpty) {
      final jwtToken = sanitizeToken(rawToken);
      effectiveHeaders['Authorization'] = 'Bearer $jwtToken';
    }

    final roleId = headers?['Role-Id'] ?? headers?['Role-id'] ?? currentRoleId ?? '1';
    effectiveHeaders['Role-Id'] = roleId;

    final session = headers?['userSession'] ?? currentUserSession;
    if (session != null && session.isNotEmpty) {
      effectiveHeaders['userSession'] = session;
    }

    if (headers != null) {
      headers.forEach((key, value) {
        final lower = key.toLowerCase();
        if (lower != 'authorization' &&
            lower != 'origin' &&
            lower != 'referer' &&
            lower != 'hash-check' &&
            lower != 'role-id' &&
            lower != 'usersession') {
          effectiveHeaders[key] = value;
        }
      });
    }

    return await _client.post(
      uri,
      headers: effectiveHeaders,
      body: body == null ? null : jsonBody,
    );
  }

  Future<http.Response> _getJson(
    String endpoint, {
    String base = '',
    Map<String, String>? headers,
  }) async {
    final targetBase = base.isNotEmpty ? base : baseUrl;
    final uri = Uri.parse('$targetBase$endpoint');

    final hashCheck = crypto.Hmac(
      crypto.sha256,
      utf8.encode('UW1nF0cu5S'),
    ).convert(utf8.encode('null')).toString();

    final effectiveHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json, text/plain, */*',
      'Hash-Check': hashCheck,
    };

    final rawToken = headers?['Authorization'] ?? currentToken;
    if (rawToken != null && rawToken.isNotEmpty) {
      final jwtToken = sanitizeToken(rawToken);
      effectiveHeaders['Authorization'] = 'Bearer $jwtToken';
    }

    final roleId = headers?['Role-Id'] ?? headers?['Role-id'] ?? currentRoleId ?? '1';
    effectiveHeaders['Role-Id'] = roleId;

    final session = headers?['userSession'] ?? currentUserSession;
    if (session != null && session.isNotEmpty) {
      effectiveHeaders['userSession'] = session;
    }

    if (headers != null) {
      headers.forEach((key, value) {
        final lower = key.toLowerCase();
        if (lower != 'authorization' &&
            lower != 'origin' &&
            lower != 'referer' &&
            lower != 'hash-check' &&
            lower != 'role-id' &&
            lower != 'usersession') {
          effectiveHeaders[key] = value;
        }
      });
    }

    return await _client.get(
      uri,
      headers: effectiveHeaders,
    );
  }

  // ============================================================
  // LOGIN API
  // ============================================================

  Future<LoginModel> login({
    required String userName,
    required String password,
    required String timeStamp,
    String captchaId = '',
    String captchaValue = '',
  }) async {
    final response = await _client.post(
      Uri.parse(
        'https://nxamsdev.winfocus.co.in/NxAmsDevServices/adminService/api/Admin/login',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'UserName': userName,
        'Password': password,
        'TimeStamp': timeStamp,
        'BrowserInfo': '',
        'CaptchaId': captchaId,
        'CaptchaValue': captchaValue,
        'IpAddress': '',
        'IspAddress': '',
      }),
    );
    debugPrint('Login API Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      logTokenDiagnostics(
        'login response token',
        data['token']?.toString() ?? '',
      );
      currentToken = sanitizeToken(data['token']?.toString() ?? '');
      currentUserSession = base64Encode(utf8.encode(response.body));
      currentRoleId = data['roleIds']?.toString().split(',').first.trim() ?? '1';
      return LoginModel.fromJson(data, rawBody: response.body);
    }
    throw Exception('Login failed: ${response.statusCode} ${response.body}');
  }

  Future<Map<String, dynamic>> generateCaptcha() async {
    final response = await _client.post(
      Uri.parse(
        'https://nxamsdev.winfocus.co.in/NxAmsDevServices/adminService/api/Admin/GenerateCaptcha',
      ),
    );
    if (response.statusCode != 200) {
      throw Exception('Unable to load CAPTCHA: ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<TrainsetMeterReadingPage> getTrainsetMeterReadings({
    required String date,
    required int pageNo,
    required int pageSize,
    required int pagination,
    required String token,
    required String userSession,
    required String roleId,
  }) async {
    final customHeaders = <String, String>{};
    if (token.isNotEmpty) {
      customHeaders['Authorization'] = token;
    }
    if (userSession.isNotEmpty) {
      customHeaders['userSession'] = userSession;
    }
    if (roleId.isNotEmpty) {
      customHeaders['Role-Id'] = roleId;
    }

    final response = await _postJson(
      '/asset-register/get-trainsets-meterreading',
      base: baseUrl,
      body: {
        'Params': [
          {'key': 'Date', 'value': date},
          {'key': 'PageNo', 'value': pageNo.toString()},
          {'key': 'PageSize', 'value': pageSize.toString()},
          {'key': 'Pagenation', 'value': pagination.toString()},
        ],
      },
      headers: customHeaders.isNotEmpty ? customHeaders : null,
    );
    debugPrint('Trainset Meter Reading Status: ${response.statusCode}');
    debugPrint('Trainset Meter Reading Response: ${response.body}');
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load trainset meter readings: ${response.statusCode} ${response.body}',
      );
    }

    var decoded = jsonDecode(response.body);
    if (decoded is String) {
      try {
        decoded = jsonDecode(decoded);
      } catch (_) {}
    }

    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    if (map['Status'] == 0 || map['status'] == 0) {
      final msg = map['Message'] ?? map['message'] ?? 'Failed to load trainset meter readings';
      throw Exception(msg.toString());
    }

    final rawResults =
        map['results'] ?? map['Results'] ?? map['data'] ?? map['Data'];

    List<dynamic> results = [];
    if (rawResults is String) {
      try {
        final parsed = jsonDecode(rawResults);
        if (parsed is List) {
          results = parsed;
        } else if (parsed is Map) {
          results = [parsed];
        }
      } catch (e) {
        debugPrint('Failed to decode rawResults JSON string: $e');
      }
    } else if (rawResults is List) {
      results = rawResults;
    } else if (decoded is List) {
      results = decoded;
    }

    int toInt(dynamic value) => value is num
        ? value.toInt()
        : int.tryParse(value?.toString() ?? '') ?? 0;

    final parsedItems = results
        .whereType<Map<String, dynamic>>()
        .map((e) => TrainsetMeterReadingModel.fromJson(e))
        .toList();

    final totalRows = toInt(
      map['totalRows'] ??
          map['TotalRows'] ??
          map['total'] ??
          map['count'] ??
          (parsedItems.isNotEmpty ? parsedItems.length : 0),
    );

    final resolvedPageNo = toInt(map['pageNo'] ?? map['PageNo'] ?? pageNo) > 0
        ? toInt(map['pageNo'] ?? map['PageNo'] ?? pageNo)
        : pageNo;

    return TrainsetMeterReadingPage(
      items: parsedItems,
      totalRows: totalRows,
      pageNo: resolvedPageNo,
    );
  }

  // ============================================================
  Future<List<Map<String, dynamic>>> getTrainsetMeterDetails({
    required int trainsetId,
    required String location,
    required String date,
    required String token,
    required String userSession,
    required String roleId,
  }) async {
    final customHeaders = <String, String>{};
    if (token.isNotEmpty) {
      customHeaders['Authorization'] = token;
    }
    if (userSession.isNotEmpty) {
      customHeaders['userSession'] = userSession;
    }
    if (roleId.isNotEmpty) {
      customHeaders['Role-Id'] = roleId;
    }

    final response = await _postJson(
      '/asset-register/get-trainset-meterlist',
      base: baseUrl,
      body: {
        'Params': [
          {'key': 'Trainset', 'value': trainsetId.toString()},
          {'key': 'location', 'value': location},
          {'key': 'Date', 'value': date},
        ],
      },
      headers: customHeaders.isNotEmpty ? customHeaders : null,
    );
    debugPrint('Trainset Meter Details Status: ${response.statusCode}');
    debugPrint('Trainset Meter Details Response: ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to load meter details: ${response.statusCode}');
    }

    var decoded = jsonDecode(response.body);
    if (decoded is String) {
      try {
        decoded = jsonDecode(decoded);
      } catch (_) {}
    }

    final raw = decoded is Map<String, dynamic>
        ? (decoded['results'] ??
            decoded['Results'] ??
            decoded['data'] ??
            decoded['Data'])
        : decoded;

    dynamic list = raw;
    if (raw is String) {
      try {
        list = jsonDecode(raw);
      } catch (_) {}
    }

    return (list as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  // ============================================================
  // SAVE TRAINSET METER READINGS API
  // ============================================================
  Future<Map<String, dynamic>> addTrainsetMeterReadings({
    required List<Map<String, dynamic>> readings,
    required String token,
    required String userSession,
    required String roleId,
  }) async {
    final customHeaders = <String, String>{};
    if (token.isNotEmpty) {
      customHeaders['Authorization'] = token;
    }
    if (userSession.isNotEmpty) {
      customHeaders['userSession'] = userSession;
    }
    if (roleId.isNotEmpty) {
      customHeaders['Role-Id'] = roleId;
    }

    final response = await _postJson(
      '/asset-register/add-trainset-meterreadings',
      base: baseUrl,
      body: readings,
      headers: customHeaders.isNotEmpty ? customHeaders : null,
    );
    debugPrint('AddTrainsetMeterReadings Status: ${response.statusCode}');
    debugPrint('AddTrainsetMeterReadings Response: ${response.body}');
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to save meter readings: ${response.statusCode} ${response.body}',
      );
    }
    var decoded = jsonDecode(response.body);
    if (decoded is String) {
      try {
        decoded = jsonDecode(decoded);
      } catch (_) {}
    }
    return decoded is Map<String, dynamic>
        ? decoded
        : {'status': 1, 'data': decoded};
  }


  Future<Map<String, dynamic>> validateOtp({
    required int userId,
    required String mfaReference,
    required String otp,
  }) async {
    final response = await _client.post(
      Uri.parse(
        'https://nxamsdev.winfocus.co.in/NxAmsDevServices/adminService/api/Admin/validate-OTP',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Params': [
          {'key': 'UserId', 'value': userId.toString()},
          {'key': 'MFAReference', 'value': mfaReference},
          {'key': 'otp', 'value': otp},
        ],
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('OTP validation failed');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> resendOtp({required int userId}) async {
    final response = await _client.post(
      Uri.parse(
        'https://nxamsdev.winfocus.co.in/NxAmsDevServices/adminService/api/Admin/resend-OTP',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Params': [
          {'key': 'UserId', 'value': userId.toString()},
        ],
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Unable to resend OTP');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> resetPassword({
    required int userId,
    required String newPassword,
    required int updatedBy,
  }) async {
    final response = await _client.post(
      Uri.parse(
        'https://nxamsdev.winfocus.co.in/NxAmsDevServices/adminService/api/Admin/reset-password',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'UserId': userId,
        'NewPassword': PasswordEncryption.encryptPassword(newPassword),
        'UpdatedBy': updatedBy,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Password reset failed');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<bool> validateCaptcha({
    required String captchaId,
    required String captchaValue,
  }) async {
    final response = await _client.post(
      Uri.parse(
        'https://nxamsdev.winfocus.co.in/NxAmsDevServices/adminService/api/Admin/ValidateCaptcha',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'captchaId': captchaId, 'captchaValue': captchaValue}),
    );
    if (response.statusCode != 200) return false;
    final result = jsonDecode(response.body);
    return result is Map<String, dynamic> && result['isValid'] == true;
  }

  Future<Map<String, dynamic>> requestPasswordReset({
    required String username,
    required String mobileNumber,
  }) async {
    final response = await _client.post(
      Uri.parse(
        'https://nxamsdev.winfocus.co.in/NxAmsDevServices/adminService/api/Admin/request-reset-pwd',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Params': [
          {'key': 'username', 'value': username},
          {'key': 'mobileno', 'value': mobileNumber},
        ],
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Password reset request failed');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateForgottenPassword({
    required int userId,
    required String otpReference,
    required String otp,
    required String newPassword,
  }) async {
    final response = await _client.post(
      Uri.parse(
        'https://nxamsdev.winfocus.co.in/NxAmsDevServices/adminService/api/Admin/request-update-pwd',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Params': [
          {'key': 'userid', 'value': userId.toString()},
          {'key': 'otpref', 'value': otpReference},
          {
            'key': 'password',
            'value': PasswordEncryption.encryptPassword(newPassword),
          },
          {'key': 'otp', 'value': otp},
          {
            'key': 'timestamp',
            'value': DateTime.now().toUtc().toIso8601String(),
          },
        ],
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Password update failed');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getMaintenanceBayHistory({
    required String depot,
    String slot = '',
    String trainSet = '',
    String dateFrom = '',
    String dateTo = '',
  }) async {
    final params = <Map<String, String>>[
      if (depot.isNotEmpty) {'Key': 'Depot', 'Value': depot},
      if (slot.isNotEmpty) {'Key': 'Slot', 'Value': slot},
      if (trainSet.isNotEmpty) {'Key': 'TrainSet', 'Value': trainSet},
      if (dateFrom.isNotEmpty) {'Key': 'DateFrom', 'Value': dateFrom},
      if (dateTo.isNotEmpty) {'Key': 'DateTo', 'Value': dateTo},
    ];

    final response = await _postJson(
      '/asset-register/search-maintenance-history',
      base: baseUrl,
      body: {'Params': params},
      headers: {'Role-id': currentRoleId ?? '1'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load maintenance history: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);
    final raw = decoded is Map<String, dynamic>
        ? (decoded['results'] ??
              decoded['allocations'] ??
              decoded['bays'] ??
              decoded['list'] ??
              <dynamic>[])
        : decoded;
    final list = raw is String ? jsonDecode(raw) : raw;

    return (list is List ? list : <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  List<dynamic> _normalizeListResponse(dynamic responseBody) {
    if (responseBody is List) return responseBody;

    if (responseBody is String) {
      try {
        return _normalizeListResponse(jsonDecode(responseBody));
      } catch (_) {
        return <dynamic>[];
      }
    }

    if (responseBody is Map<String, dynamic>) {
      for (final key in [
        'results',
        'result',
        'data',
        'items',
        'list',
        'values',
      ]) {
        final value = responseBody[key];
        if (value is List) return value;
        if (value is Map<String, dynamic>) {
          final nested = _normalizeListResponse(value);
          if (nested.isNotEmpty) return nested;
        }
      }
    }

    return <dynamic>[];
  }

  // STATUS API
  // ============================================================

  Future<List<StatusModel>> getMaintenanceStatus() async {
    final response = await _postJson(
      '/assetconfig/get-lookups',
      base: assetConfigBase,
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

  // ============================================================
  // MAINTENANCE PURPOSE API
  // ============================================================

  Future<List<MaintenancePurposeModel>> getMaintenancePurposes() async {
    final response = await _postJson(
      '/maintenanceconfig/get-schedule-types',
      base: maintenanceConfigBase,
      body: {
        'Params': [
          {'key': 'Name', 'value': ''},
          {'key': 'Type', 'value': ''},
        ],
      },
    );

    if (response.statusCode == 200) {
      final data = _normalizeListResponse(jsonDecode(response.body));

      return data
          .whereType<Map<String, dynamic>>()
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

    final response = await _postJson(
      '/assetconfig/get-trainset-list',
      base: assetConfigBase,
      body: {
        'Params': [
          {'key': 'TSNo', 'value': ''},
        ],
      },
      headers: customHeaders.isNotEmpty ? customHeaders : null,
    );

    debugPrint('Trainsets Status: ${response.statusCode}');
    debugPrint('Trainsets Response: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = _normalizeListResponse(decoded);

      return data
          .whereType<Map>()
          .map((e) => TrainModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    throw Exception('Failed to load train sets: ${response.statusCode}');
  }

  // ============================================================
  // MAINTENANCE BAY API
  // ============================================================

  Future<List<MaintenanceBayModel>> getMaintenanceBay(int depotId) async {
    final response = await _postJson(
      '/asset-register/search-maintenancebay',
      base: baseUrl,
      body: {
        'Params': [
          {'key': 'MbDepot', 'value': depotId.toString()},
        ],
      },
      headers: {'Role-id': '1'},
    );

    debugPrint('Maintenance Bay Status: ${response.statusCode}');
    debugPrint('Maintenance Bay Response: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      dynamic raw = decoded;
      if (decoded is Map<String, dynamic>) {
        final inner = decoded['response'] ?? decoded['data'];
        if (inner is List) {
          raw = inner;
        } else if (inner is Map<String, dynamic>) {
          raw = inner['results'] ?? inner['allocations'] ?? inner['bays'] ?? inner['list'] ?? inner;
        } else {
          raw = decoded['results'] ??
              decoded['allocations'] ??
              decoded['bays'] ??
              decoded['data'] ??
              decoded['list'] ??
              decoded['items'] ??
              <dynamic>[];
        }
      }
      final list = raw is String ? jsonDecode(raw) : raw;

      return (list is List ? list : <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((e) => MaintenanceBayModel.fromJson(e))
          .toList();
    }

    throw Exception('Failed to load maintenance bay: ${response.statusCode}');
  }

  // ============================================================
  // GET MAINTENANCE BAY BY ID API
  // ============================================================

  Future<Map<String, dynamic>> getMaintenanceBayById(int mbId) async {
    final response = await _postJson(
      '/asset-register/get-maintenance-by-id',
      base: baseUrl,
      body: {
        'Params': [
          {'key': 'mb_id', 'value': mbId.toString(), 'Key': 'mb_id', 'Value': mbId.toString()},
        ],
      },
      headers: {'Role-Id': currentRoleId ?? '1'},
    );

    debugPrint('GetMaintenanceBayById Status: ${response.statusCode}');
    debugPrint('GetMaintenanceBayById Response: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('response') && decoded['response'] is Map<String, dynamic>) {
          return decoded['response'] as Map<String, dynamic>;
        }
        return decoded;
      } else if (decoded is List && decoded.isNotEmpty && decoded.first is Map<String, dynamic>) {
        return decoded.first as Map<String, dynamic>;
      }
      return {'data': decoded};
    }

    throw Exception('Failed to load maintenance bay details: ${response.statusCode}');
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
    bool isOutward = false,
    int? userId,
  }) async {
    final effectiveUserId = userId ?? 1;
    final payload = {
      'MbId': mbId,
      'MbDepot': mbDepot,
      'MbSlot': mbSlot,
      'MbTrainSet': mbTrainSet,
      'MbStatus': mbStatus,
      'MbPurpose': mbPurpose,
      'MbInward': mbInward,
      'MbOutward': mbOutward.isNotEmpty ? mbOutward : null,
      'MbRemark': mbRemark,
      'MbIsAllocated': true,
      'CreatedBy': effectiveUserId,
      'UpdatedBy': effectiveUserId,
      'isOutward': isOutward,
    };

    debugPrint('SaveMaintenanceBay Payload: ${jsonEncode(payload)}');

    final response = await _postJson(
      '/asset-register/save-maintenance-bay',
      base: baseUrl,
      body: payload,
      headers: {'Role-Id': currentRoleId ?? '1'},
    );

    debugPrint('Save API Status: ${response.statusCode}');
    debugPrint('Save API Response: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'status': decoded};
    }

    throw Exception('Failed to save maintenance bay: ${response.statusCode} - ${response.body}');
  }

  // ============================================================
  // SAVE MAINTENANCE ALLOCATION API
  // ============================================================

  Future<Map<String, dynamic>> saveMaintenanceBayAllocation({
    required int mbaMbId,
    required int mbaDepot,
    required int mbaSlot,
    required int mbaTrainSet,
    required int mbaPurpose,
    required int mbaStatus,
    required String mbaAllocatedOn,
    required String mbaAllocatedBy,
    required String mbaRemarks,
    int? userId,
  }) async {
    final effectiveUserId = userId ?? 1;
    final payload = {
      'MbaMbId': mbaMbId,
      'MbaDepot': mbaDepot,
      'MbaSlot': mbaSlot,
      'MbaTrainSet': mbaTrainSet,
      'MbaPurpose': mbaPurpose,
      'MbaStatus': mbaStatus,
      'MbaAllocatedOn': mbaAllocatedOn,
      'MbaAllocatedBy': mbaAllocatedBy,
      'MbaRemarks': mbaRemarks,
      'CreatedBy': effectiveUserId,
    };

    debugPrint('SaveMaintenanceAllocation Payload: ${jsonEncode(payload)}');

    final response = await _postJson(
      '/asset-register/save-maintenance-allocation',
      base: baseUrl,
      body: payload,
      headers: {'Role-Id': currentRoleId ?? '1'},
    );

    debugPrint('Save Allocation API Status: ${response.statusCode}');
    debugPrint('Save Allocation API Response: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'status': decoded};
    }

    throw Exception('Failed to save maintenance allocation: ${response.statusCode} - ${response.body}');
  }

  // ============================================================
  // LOGOUT API
  // ============================================================

  Future<bool> logout({
    String userSession = '',
    String userSessionId = '',
    String remarks = 'User Logout',
  }) async {
    try {
      final response = await _postJson(
        '/adminService/api/Admin/logout',
        base: 'https://nxamsdev.winfocus.co.in/NxAmsDevServices',
        body: {
          'Params': [
            {'key': 'UserSession', 'value': userSession},
            {'key': 'UserSessionId', 'value': userSessionId},
            {'key': 'Remarks', 'value': remarks},
          ],
        },
      );
      debugPrint('Logout API Status: ${response.statusCode}');
      debugPrint('Logout API Response: ${response.body}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['status'] == 1 || decoded['statusCode'] == 200;
      }
    } catch (e) {
      debugPrint('Logout API error: $e');
    } finally {
      currentToken = null;
      currentUserSession = null;
      currentRoleId = null;
    }
    return false;
  }

  // ============================================================
  // WHEEL MEASUREMENTS APIS
  // ============================================================

  /// Fetch wheel measurements history list (search-ts-wm)
  Future<List<WheelMeasurementListItem>> getWheelMeasurementsList({
    String trainSet = '0',
    String schedule = '0',
    String from = '',
    String to = '',
    int pageNo = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _postJson(
        '/workorder/search-ts-wm',
        base: workOrderBase,
        body: {
          'Params': [
            {'key': 'TrainSet', 'value': trainSet},
            {'key': 'Schedule', 'value': schedule},
            {'key': 'From', 'value': from},
            {'key': 'To', 'value': to},
            {'key': 'PageNo', 'value': pageNo.toString()},
            {'key': 'PageSize', 'value': pageSize.toString()},
            {'key': 'Pagenation', 'value': '1'},
          ],
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> items = [];
        if (decoded is Map<String, dynamic> && decoded.containsKey('results')) {
          final resultsRaw = decoded['results'];
          if (resultsRaw is String && resultsRaw.isNotEmpty) {
            items = jsonDecode(resultsRaw) as List<dynamic>;
          } else if (resultsRaw is List) {
            items = resultsRaw;
          }
        } else if (decoded is List) {
          items = decoded;
        }

        return items
            .map((item) =>
                WheelMeasurementListItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('getWheelMeasurementsList API error: $e');
    }
    return [];
  }

  /// Get measurement entry template/details for a Work Order & Trainset (get-wo-wm)
  Future<WheelMeasurementData?> getWheelMeasurementDetails({
    required int woId,
    required int tsId,
  }) async {
    try {
      final response = await _postJson(
        '/workorder/get-wo-wm',
        base: workOrderBase,
        body: {
          'Params': [
            {'key': 'WOId', 'value': woId > 0 ? woId.toString() : ''},
            {'key': 'TSId', 'value': tsId > 0 ? tsId.toString() : ''},
          ],
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return WheelMeasurementData.fromJson(decoded);
        }
      }
    } catch (e) {
      debugPrint('getWheelMeasurementDetails API error: $e');
    }
    return null;
  }

  /// Save wheel measurements to database (save-wo-wm)
  Future<bool> saveWheelMeasurementDetails(WheelMeasurementData data) async {
    try {
      final response = await _postJson(
        '/workorder/save-wo-wm',
        base: workOrderBase,
        body: data.toJson(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded['status'] == 1 || decoded['statusCode'] == 200;
        }
        return true;
      }
    } catch (e) {
      debugPrint('saveWheelMeasurementDetails API error: $e');
    }
    return false;
  }

  // ============================================================
  // WORK ORDER CHECKLIST APIs (NxAMS Direct Mobile Sync)
  // ============================================================

  /// Fetch Work Orders for technicians to inspect
  Future<List<ChecklistWorkOrder>> getWorkOrdersForChecklist({
    String woNo = '',
    String unit = '0',
    String status = '0',
  }) async {
    try {
      final response = await _postJson(
        '/workorder/get-workorder-list',
        base: workOrderBase,
        body: {
          'Params': [
            {'key': 'WONo', 'value': woNo},
            {'key': 'Unit', 'value': unit},
            {'key': 'From', 'value': '1900-01-01'},
            {'key': 'To', 'value': '2900-01-01'},
            {'key': 'Status', 'value': status},
            {'key': 'WorkType', 'value': '0'},
            {'key': 'TargetDeferred', 'value': '0'},
          ],
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic> && decoded['results'] != null) {
          final resRaw = decoded['results'];
          if (resRaw is String && resRaw.isNotEmpty) {
            list = jsonDecode(resRaw) as List<dynamic>;
          } else if (resRaw is List) {
            list = resRaw;
          }
        }
        return list
            .map((item) =>
                ChecklistWorkOrder.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('getWorkOrdersForChecklist API error: $e');
    }
    return [];
  }

  /// Load checklist groups and inspection items for a Work Order
  Future<List<CheckGroupModel>> getWorkOrderChecklistDetails(int workOrderId) async {
    try {
      final response = await _postJson(
        '/workorder/get-workorder-checklist-details',
        base: workOrderBase,
        body: {
          'Params': [
            {'key': 'WOId', 'value': workOrderId > 0 ? workOrderId.toString() : ''},
          ],
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> rawGroups = [];
        if (decoded is List) {
          rawGroups = decoded;
        } else if (decoded is String && decoded.isNotEmpty) {
          rawGroups = jsonDecode(decoded) as List<dynamic>;
        }

        return rawGroups
            .map((g) => CheckGroupModel.fromJson(g as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('getWorkOrderChecklistDetails API error: $e');
    }
    return [];
  }

  /// Instant real-time sync of an individual check item (update-wo-checksheet-comment)
  /// Replaces technician paper notebook with instant database persistence
  Future<bool> updateWorkOrderChecksheetItem({
    required int id,
    required int compliance,
    required String remarks,
  }) async {
    try {
      final response = await _postJson(
        '/workorder/update-wo-checksheet-comment',
        base: workOrderBase,
        body: {
          'Id': id,
          'Compliance': compliance,
          'Remarks': remarks.trim(),
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded['status'] == 1 ||
              decoded['Status'] == 1 ||
              decoded['statusCode'] == 200;
        }
        return true;
      }
    } catch (e) {
      debugPrint('updateWorkOrderChecksheetItem API error: $e');
    }
    return false;
  }

  /// Batch save the entire workorder checksheet (save-workorder-checksheet)
  Future<bool> saveWorkOrderChecksheet({
    required List<CheckGroupModel> groups,
  }) async {
    try {
      final payload = groups
          .map((g) => {
                'Checks': g.checks.map((c) => c.toCommentJson()).toList(),
              })
          .toList();

      final response = await _postJson(
        '/workorder/save-workorder-checksheet',
        base: workOrderBase,
        body: payload,
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded['status'] == 1 ||
              decoded['Status'] == 1 ||
              decoded['statusCode'] == 200;
        }
        return true;
      }
    } catch (e) {
      debugPrint('saveWorkOrderChecksheet API error: $e');
    }
    return false;
  }

  // ============================================================
  // CONFIG MAINTENANCE CHECKLIST APIs (Website Match)
  // ============================================================

  /// Fetch Asset Categories for Filter dropdown (`assetconfig/api/assetconfig/get-asset-categories`)
  Future<List<ChecklistCategoryItem>> getAssetCategories() async {
    try {
      final response = await _postJson(
        '/assetconfig/get-asset-categories',
        base: assetConfigBase,
        body: {
          'Params': [
            {'key': 'name', 'value': ''},
            {'key': 'id', 'value': ''},
          ],
        },
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic> && decoded['response'] != null) {
          list = decoded['response'] is List ? decoded['response'] : [];
        } else if (decoded is Map<String, dynamic> && decoded['results'] != null) {
          final resRaw = decoded['results'];
          if (resRaw is String && resRaw.isNotEmpty) {
            list = jsonDecode(resRaw) as List<dynamic>;
          } else if (resRaw is List) {
            list = resRaw;
          }
        }
        return list
            .map((item) => ChecklistCategoryItem.fromJson(item as Map<String, dynamic>))
            .where((item) => item.value.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('getAssetCategories API error: $e');
    }
    return [];
  }

  /// Fetch Job Plans for Filter dropdown (`maintenanceconfig/api/maintenanceconfig/get-job-plans`)
  Future<List<ChecklistJobPlanItem>> getJobPlans() async {
    try {
      final response = await _postJson(
        '/maintenanceconfig/get-job-plans',
        base: maintenanceConfigBase,
        body: {
          'Params': [
            {'key': 'name', 'value': ''},
          ],
        },
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic> && decoded['response'] != null) {
          list = decoded['response'] is List ? decoded['response'] : [];
        } else if (decoded is Map<String, dynamic> && decoded['results'] != null) {
          final resRaw = decoded['results'];
          if (resRaw is String && resRaw.isNotEmpty) {
            list = jsonDecode(resRaw) as List<dynamic>;
          } else if (resRaw is List) {
            list = resRaw;
          }
        }
        return list
            .map((item) => ChecklistJobPlanItem.fromJson(item as Map<String, dynamic>))
            .where((item) => item.jobPlanName.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('getJobPlans API error: $e');
    }
    return [];
  }

  /// Fetch Checklist Names for Filter dropdown (`maintenanceconfig/api/maintenanceconfig/get-jobplancheklistname-list`)
  Future<List<ChecklistNameItem>> getJobPlanChecklistNames() async {
    try {
      final response = await _getJson(
        '/maintenanceconfig/get-jobplancheklistname-list',
        base: maintenanceConfigBase,
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic> && decoded['response'] != null) {
          list = decoded['response'] is List ? decoded['response'] : [];
        } else if (decoded is Map<String, dynamic> && decoded['results'] != null) {
          final resRaw = decoded['results'];
          if (resRaw is String && resRaw.isNotEmpty) {
            list = jsonDecode(resRaw) as List<dynamic>;
          } else if (resRaw is List) {
            list = resRaw;
          }
        }
        return list
            .map((item) => ChecklistNameItem.fromJson(item as Map<String, dynamic>))
            .where((item) => item.name.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('getJobPlanChecklistNames API error: $e');
    }
    return [];
  }

  /// Fetch Master Checklists configured under Config Maintenance -> Checklists
  Future<List<JobPlanChecklistModel>> getScheduleChecklists({
    String categoryId = '0',
    String jobPlanId = '0',
    String checklistName = '',
    String status = '0',
  }) async {
    try {
      final response = await _postJson(
        '/maintenanceconfig/get-schedule-checklist',
        base: maintenanceConfigBase,
        body: {
          'Params': [
            {'key': 'CategoryId', 'value': categoryId.isNotEmpty ? categoryId : '0'},
            {'key': 'JobPlanId', 'value': jobPlanId.isNotEmpty ? jobPlanId : '0'},
            {'key': 'ChecklistName', 'value': checklistName},
            {'key': 'Status', 'value': status.isNotEmpty ? status : '0'},
          ],
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic> && decoded['response'] != null) {
          list = decoded['response'] is List ? decoded['response'] : [];
        } else if (decoded is Map<String, dynamic> && decoded['results'] != null) {
          final resRaw = decoded['results'];
          if (resRaw is String && resRaw.isNotEmpty) {
            list = jsonDecode(resRaw) as List<dynamic>;
          } else if (resRaw is List) {
            list = resRaw;
          }
        }
        return list
            .map((item) =>
                JobPlanChecklistModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('getScheduleChecklists API error: $e');
    }
    return [];
  }

  /// Get groups and check items configured for a master Checklist
  Future<List<CheckGroupModel>> getChecklistDetails(int checkListId) async {
    try {
      final response = await _postJson(
        '/maintenanceconfig/get-checklist-details',
        base: maintenanceConfigBase,
        body: {
          'Params': [
            {'key': 'CheckListId', 'value': checkListId > 0 ? checkListId.toString() : ''},
          ],
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> rawGroups = [];
        if (decoded is List) {
          rawGroups = decoded;
        } else if (decoded is String && decoded.isNotEmpty) {
          rawGroups = jsonDecode(decoded) as List<dynamic>;
        }

        return rawGroups
            .map((g) => CheckGroupModel.fromJson(g as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('getChecklistDetails API error: $e');
    }
    return [];
  }

  /// Create a new Master Checklist (`maintenanceconfig/api/maintenanceconfig/submit-jobplanchecklist`)
  Future<bool> saveChecklist({
    required int jobPlanId,
    required String checklistName,
    required int categoryId,
    int status = 1,
  }) async {
    try {
      final response = await _postJson(
        '/maintenanceconfig/submit-jobplanchecklist',
        base: maintenanceConfigBase,
        body: {
          'jobplan_id': jobPlanId,
          'jpc_checklist_name': checklistName.trim(),
          'created_user': 1,
          'jpc_category': categoryId,
          'jpc_status': status,
        },
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('saveChecklist API error: $e');
    }
    return false;
  }

  /// Add a new group to a checklist (`maintenanceconfig/api/maintenanceconfig/submit-jobplan-checklist-group`)
  Future<bool> saveChecklistGroup({
    required int checkListId,
    required String groupName,
  }) async {
    try {
      final response = await _postJson(
        '/maintenanceconfig/submit-jobplan-checklist-group',
        base: maintenanceConfigBase,
        body: {
          'JobPlanChecklistId': checkListId,
          'GroupName': groupName.trim(),
          'validFrom': DateTime.now().toIso8601String(),
          'validThru': DateTime.now().add(const Duration(days: 3650)).toIso8601String(),
          'createdBy': 1,
        },
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('saveChecklistGroup API error: $e');
    }
    return false;
  }

  /// Add a new item to a checklist group (`maintenanceconfig/api/maintenanceconfig/submit-jobplan-checklist-group-item`)
  Future<bool> saveChecklistGroupItem({
    required int groupId,
    required String subGroup,
    required String checkDescription,
  }) async {
    try {
      final response = await _postJson(
        '/maintenanceconfig/submit-jobplan-checklist-group-item',
        base: maintenanceConfigBase,
        body: {
          'GroupId': groupId,
          'SubGroup': subGroup.trim(),
          'CheckDescription': checkDescription.trim(),
          'createdBy': 1,
        },
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('saveChecklistGroupItem API error: $e');
    }
    return false;
  }

  /// Update Checklist Name (`maintenanceconfig/api/maintenanceconfig/update-jobplan-checklist-name`)
  Future<bool> updateChecklistName({
    required int jpcId,
    required String checklistName,
    int? jobPlanId,
    int? categoryId,
    int? status,
  }) async {
    try {
      final body = <String, dynamic>{
        'jpc_id': jpcId,
        'jpc_checklist_name': checklistName.trim(),
        'updated_by': 1,
      };
      if (jobPlanId != null && jobPlanId > 0) body['jobplan_id'] = jobPlanId;
      if (categoryId != null && categoryId > 0) body['jpc_category'] = categoryId;
      if (status != null) body['jpc_status'] = status.toString();

      final response = await _postJson(
        '/maintenanceconfig/update-jobplan-checklist-name',
        base: maintenanceConfigBase,
        body: body,
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('updateChecklistName API error: $e');
    }
    return false;
  }

  /// Delete a Checklist (`maintenanceconfig/api/maintenanceconfig/delete-checklist`)
  Future<bool> deleteChecklist({required int jpcId}) async {
    try {
      final response = await _postJson(
        '/maintenanceconfig/delete-checklist',
        base: maintenanceConfigBase,
        body: {
          'Params': [
            {'Key': 'jpc_id', 'Value': jpcId.toString()},
          ],
        },
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('deleteChecklist API error: $e');
    }
    return false;
  }

  /// Delete an item from a group (`maintenanceconfig/api/maintenanceconfig/delete-checklist-group-item`)
  Future<bool> deleteChecklistItem({required int checkItemId}) async {
    try {
      final response = await _postJson(
        '/maintenanceconfig/delete-checklist-group-item',
        base: maintenanceConfigBase,
        body: {
          'Params': [
            {'key': 'jpci_id', 'value': checkItemId.toString()},
          ],
        },
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('deleteChecklistItem API error: $e');
    }
    return false;
  }

  /// Update Checklist Group Name (`maintenanceconfig/api/maintenanceconfig/update-jobplan-checklist-group`)
  Future<bool> updateChecklistGroup({
    required int groupId,
    required String groupName,
  }) async {
    try {
      final response = await _postJson(
        '/maintenanceconfig/update-jobplan-checklist-group',
        base: maintenanceConfigBase,
        body: {
          'groupId': groupId,
          'groupName': groupName.trim(),
          'updated_by': 1,
        },
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('updateChecklistGroup API error: $e');
    }
    return false;
  }

  /// Delete a Checklist Group (`maintenanceconfig/api/maintenanceconfig/delete-checklist-group`)
  Future<bool> deleteChecklistGroup({required int groupId}) async {
    try {
      final response = await _postJson(
        '/maintenanceconfig/delete-checklist-group',
        base: maintenanceConfigBase,
        body: {
          'Params': [
            {'Key': 'jpcg_id', 'Value': groupId.toString()},
          ],
        },
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('deleteChecklistGroup API error: $e');
    }
    return false;
  }

  /// Update Check Item Sub System and Check Description (`maintenanceconfig/api/maintenanceconfig/update-jobplan-checklist-group-item`)
  Future<bool> updateChecklistGroupItem({
    required int checkItemId,
    required String subGroup,
    required String checkDescription,
  }) async {
    try {
      final response = await _postJson(
        '/maintenanceconfig/update-jobplan-checklist-group-item',
        base: maintenanceConfigBase,
        body: {
          'Params': [
            {'key': 'jpci_id', 'value': checkItemId.toString()},
            {'key': 'jpcl_check_description', 'value': checkDescription.trim()},
            {'key': 'jpcl_sub_group', 'value': subGroup.trim()},
            {'key': 'updated_by', 'value': '1'},
          ],
        },
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('updateChecklistGroupItem API error: $e');
    }
    return false;
  }

  // ============================================================
  // NOTIFICATIONS APIS (messaging/api/messaging/...)
  // ============================================================

  /// Fetch notifications list
  Future<List<NotificationModel>> getNotifications({
    String? unitId,
    String? roleId,
  }) async {
    try {
      final response = await _postJson(
        '/messaging/get-notifications',
        base: messagingBase,
        body: {
          'Params': [
            {'key': 'UnitId', 'value': unitId ?? '0'},
            {'key': 'RoleId', 'value': roleId ?? currentRoleId ?? '0'},
          ],
        },
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('getNotifications (messaging service): ${e.toString().split('\n').first}');
    }
    return [];
  }

  /// Get unread notification count
  Future<int> getNotificationsCount({String? userId}) async {
    try {
      final response = await _postJson(
        '/messaging/get-notifications-count',
        base: messagingBase,
        body: {
          'Params': [
            {'key': 'UserId', 'value': userId ?? ''},
          ],
        },
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final status = decoded['status'] ?? decoded['Status'];
          if (status != null) {
            return int.tryParse(status.toString()) ?? 0;
          }
        } else if (decoded is int) {
          return decoded;
        }
      }
    } catch (e) {
      debugPrint('getNotificationsCount (messaging service): ${e.toString().split('\n').first}');
    }
    return 0;
  }

  /// Mark notification as read
  Future<bool> updateNotificationReadStatus({required int messageRecipientId}) async {
    try {
      final response = await _postJson(
        '/messaging/update-read-status',
        base: messagingBase,
        body: {
          'Params': [
            {'key': 'MsgReceipentId', 'value': messageRecipientId.toString()},
          ],
        },
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded['status'] == 1 || decoded['status'] == true;
        }
        return true;
      }
    } catch (e) {
      debugPrint('updateNotificationReadStatus API error: $e');
    }
    return false;
  }

  // ============================================================
  // STAFF DETAILS / PROFILE API (adminService/api/Admin/get-staff-details)
  // ============================================================

  /// Fetch staff details for user profile
  Future<StaffProfileModel?> getStaffDetails({required String staffId}) async {
    try {
      final response = await _postJson(
        '/Admin/get-staff-details',
        base: adminBase,
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
      final response = await _postJson(
        '/Admin/update-profile',
        base: adminBase,
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



