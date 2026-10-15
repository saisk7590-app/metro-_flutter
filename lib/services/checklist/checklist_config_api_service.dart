import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../models/checklist/checklist_model.dart';
import '../base_api_service.dart';

/// Service handling Master Checklist configuration under Config Maintenance.
class ChecklistConfigApiService extends BaseApiService {
  /// Fetch Asset Categories for Filter dropdown (`assetconfig/api/assetconfig/get-asset-categories`)
  Future<List<ChecklistCategoryItem>> getAssetCategories() async {
    try {
      final response = await postJson(
        '/assetconfig/get-asset-categories',
        base: BaseApiService.assetConfigBase,
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
      final response = await postJson(
        '/maintenanceconfig/get-job-plans',
        base: BaseApiService.maintenanceConfigBase,
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
      final response = await getJson(
        '/maintenanceconfig/get-jobplancheklistname-list',
        base: BaseApiService.maintenanceConfigBase,
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
      final response = await postJson(
        '/maintenanceconfig/get-schedule-checklist',
        base: BaseApiService.maintenanceConfigBase,
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
      final response = await postJson(
        '/maintenanceconfig/get-checklist-details',
        base: BaseApiService.maintenanceConfigBase,
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
      final response = await postJson(
        '/maintenanceconfig/submit-jobplanchecklist',
        base: BaseApiService.maintenanceConfigBase,
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
      final response = await postJson(
        '/maintenanceconfig/submit-jobplan-checklist-group',
        base: BaseApiService.maintenanceConfigBase,
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
      final response = await postJson(
        '/maintenanceconfig/submit-jobplan-checklist-group-item',
        base: BaseApiService.maintenanceConfigBase,
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

      final response = await postJson(
        '/maintenanceconfig/update-jobplan-checklist-name',
        base: BaseApiService.maintenanceConfigBase,
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
      final response = await postJson(
        '/maintenanceconfig/delete-checklist',
        base: BaseApiService.maintenanceConfigBase,
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
      final response = await postJson(
        '/maintenanceconfig/delete-checklist-group-item',
        base: BaseApiService.maintenanceConfigBase,
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
      final response = await postJson(
        '/maintenanceconfig/update-jobplan-checklist-group',
        base: BaseApiService.maintenanceConfigBase,
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
      final response = await postJson(
        '/maintenanceconfig/delete-checklist-group',
        base: BaseApiService.maintenanceConfigBase,
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
      final response = await postJson(
        '/maintenanceconfig/update-jobplan-checklist-group-item',
        base: BaseApiService.maintenanceConfigBase,
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
}
