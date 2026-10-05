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
import '../utils/token_diagnostics.dart';
import '../utils/password_encryption.dart';

class ApiService {
  static const String baseUrl =
      'https://nxamsdev.winfocus.co.in/NxAmsDevServices/assetregister/api';
  static const String assetConfigBase =
      'https://nxamsdev.winfocus.co.in/NxAmsDevServices/assetconfig/api';
  static const String maintenanceConfigBase =
      'https://nxamsdev.winfocus.co.in/NxAmsDevServices/maintenanceconfig/api';

  static String? currentToken;
  static String? currentUserSession;
  static String? currentRoleId;
  static final http.Client _client = getAppHttpClient();

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

  Future<http.Response> _postJson(
    String endpoint, {
    String base = '',
    Map<String, dynamic>? body,
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
    final body = jsonEncode({
      'Params': [
        {'key': 'Date', 'value': date},
        {'key': 'PageNo', 'value': pageNo.toString()},
        {'key': 'PageSize', 'value': pageSize.toString()},
        {'key': 'Pagenation', 'value': pagination.toString()},
      ],
    });
    final hashCheck = crypto.Hmac(
      crypto.sha256,
      utf8.encode('UW1nF0cu5S'),
    ).convert(utf8.encode(body)).toString();

    final jwtToken = sanitizeToken(token.isNotEmpty ? token : (currentToken ?? ''));
    final effSession = userSession.isNotEmpty ? userSession : (currentUserSession ?? '');
    final effRoleId = roleId.isNotEmpty ? roleId : (currentRoleId ?? '1');

    final response = await _client.post(
      Uri.parse(
        'https://nxamsdev.winfocus.co.in/NxAmsDevServices/assetregister/api/asset-register/get-trainsets-meterreading',
      ),
      headers: {
        'Accept': 'application/json, text/plain, */*',
        'Content-Type': 'application/json',
        'Hash-Check': hashCheck,
        'Authorization': 'Bearer $jwtToken',
        'Role-Id': effRoleId,
        'userSession': effSession,
      },
      body: body,
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
    final body = jsonEncode({
      'Params': [
        {'key': 'Trainset', 'value': trainsetId.toString()},
        {'key': 'location', 'value': location},
        {'key': 'Date', 'value': date},
      ],
    });
    final hashCheck = crypto.Hmac(
      crypto.sha256,
      utf8.encode('UW1nF0cu5S'),
    ).convert(utf8.encode(body)).toString();
    final jwtToken = sanitizeToken(token.isNotEmpty ? token : (currentToken ?? ''));
    final effSession = userSession.isNotEmpty ? userSession : (currentUserSession ?? '');
    final effRoleId = roleId.isNotEmpty ? roleId : (currentRoleId ?? '1');

    final response = await _client.post(
      Uri.parse(
        'https://nxamsdev.winfocus.co.in/NxAmsDevServices/assetregister/api/asset-register/get-trainset-meterlist',
      ),
      headers: {
        'Accept': 'application/json, text/plain, */*',
        'Content-Type': 'application/json',
        'Hash-Check': hashCheck,
        'Authorization': 'Bearer $jwtToken',
        'Role-Id': effRoleId,
        'userSession': effSession,
      },
      body: body,
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
    final body = jsonEncode(readings);
    final hashCheck = crypto.Hmac(
      crypto.sha256,
      utf8.encode('UW1nF0cu5S'),
    ).convert(utf8.encode(body)).toString();
    final jwtToken = sanitizeToken(token.isNotEmpty ? token : (currentToken ?? ''));
    final effSession = userSession.isNotEmpty ? userSession : (currentUserSession ?? '');
    final effRoleId = roleId.isNotEmpty ? roleId : (currentRoleId ?? '1');

    final response = await _client.post(
      Uri.parse(
        'https://nxamsdev.winfocus.co.in/NxAmsDevServices/assetregister/api/asset-register/add-trainset-meterreadings',
      ),
      headers: {
        'Accept': 'application/json, text/plain, */*',
        'Content-Type': 'application/json',
        'Hash-Check': hashCheck,
        'Authorization': 'Bearer $jwtToken',
        'Role-Id': effRoleId,
        'userSession': effSession,
      },
      body: body,
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
}
