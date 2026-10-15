import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../models/meter/trainset_meter_reading_model.dart';
import '../base_api_service.dart';

/// Service handling trainset meter readings and recordings.
class MeterReadingApiService extends BaseApiService {
  /// Fetch paginated list of trainset meter readings for a given date
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

    final response = await postJson(
      '/asset-register/get-trainsets-meterreading',
      base: BaseApiService.baseUrl,
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
    if (response.statusCode == 405) {
      debugPrint('[Web 405 Fallback] get-trainsets-meterreading returned 405.');
      throw Exception('Failed to fetch: 405 Method Not Allowed');
    }
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

  /// Fetch meter details for a specific trainset, location, and date
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

    final response = await postJson(
      '/asset-register/get-trainset-meterlist',
      base: BaseApiService.baseUrl,
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

  /// Save or submit newly entered trainset meter readings
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

    final response = await postJson(
      '/asset-register/add-trainset-meterreadings',
      base: BaseApiService.baseUrl,
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
}
