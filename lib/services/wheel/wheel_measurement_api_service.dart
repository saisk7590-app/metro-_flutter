import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../models/wheel/wheel_measurement_model.dart';
import '../base_api_service.dart';

/// Service handling wheel measurements inspection, history, and submission.
class WheelMeasurementApiService extends BaseApiService {
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
      final response = await postJson(
        '/workorder/search-ts-wm',
        base: BaseApiService.workOrderBase,
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
      final response = await postJson(
        '/workorder/get-wo-wm',
        base: BaseApiService.workOrderBase,
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
      final response = await postJson(
        '/workorder/save-wo-wm',
        base: BaseApiService.workOrderBase,
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
}
