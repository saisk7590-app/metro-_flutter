import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../models/checklist/checklist_model.dart';
import '../base_api_service.dart';
import 'checklist_config_api_service.dart';

export 'checklist_config_api_service.dart';

/// Service handling Work Order Checklists (Mobile Execution & Sync).
/// Inherits ChecklistConfigApiService to provide unified access to checklist configurations.
class ChecklistApiService extends ChecklistConfigApiService {
  // ===========================================================================
  // WORK ORDER CHECKLIST APIS (MOBILE EXECUTION & SYNC)
  // ===========================================================================

  /// Fetch Work Orders for technicians to inspect
  Future<List<ChecklistWorkOrder>> getWorkOrdersForChecklist({
    String woNo = '',
    String unit = '0',
    String status = '0',
  }) async {
    try {
      final response = await postJson(
        '/workorder/get-workorder-list',
        base: BaseApiService.workOrderBase,
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
      final response = await postJson(
        '/workorder/get-workorder-checklist-details',
        base: BaseApiService.workOrderBase,
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
  Future<bool> updateWorkOrderChecksheetItem({
    required int id,
    required int compliance,
    required String remarks,
  }) async {
    try {
      final response = await postJson(
        '/workorder/update-wo-checksheet-comment',
        base: BaseApiService.workOrderBase,
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

      final response = await postJson(
        '/workorder/save-workorder-checksheet',
        base: BaseApiService.workOrderBase,
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
}
