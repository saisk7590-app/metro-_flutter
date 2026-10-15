import 'package:flutter/foundation.dart';
import '../../models/checklist/checklist_model.dart';
import 'checklist_config_mixin.dart';

/// Mixin providing Master Checklist CRUD management (create, update, delete groups and items).
mixin ChecklistCrudMixin on ChecklistConfigMixin {
  List<CheckGroupModel> get checklistGroups;
  set syncStatus(String val);

  void addConfigChecklist(JobPlanChecklistModel item) {
    configChecklists.insert(0, item);
    notifyListeners();
  }

  void deleteConfigChecklist(int jpcId) {
    configChecklists.removeWhere((c) => c.jpcId == jpcId);
    notifyListeners();
  }

  /// 1. Create a new Master Checklist (`POST submit-jobplanchecklist`)
  Future<bool> createChecklist({
    required int jobPlanId,
    required String jobPlanName,
    required String checklistName,
    required int categoryId,
    required String categoryCode,
    required String scheduleName,
    required bool isActive,
  }) async {
    try {
      await apiService.saveChecklist(
        jobPlanId: jobPlanId,
        checklistName: checklistName,
        categoryId: categoryId,
        status: isActive ? 1 : 2,
      );

      final newId = DateTime.now().millisecondsSinceEpoch % 100000;
      final newItem = JobPlanChecklistModel(
        jpcId: newId,
        jobplanId: jobPlanId,
        jobplanName: jobPlanName,
        jobplanCode: 'JP-$jobPlanId',
        jpcChecklistName: checklistName,
        scheduleId: 1,
        scheduleCode: 'SCH',
        scheduleName: scheduleName,
        assetCategoryCode: categoryCode,
        unitCode: categoryCode,
        jpcStatus: isActive ? 1 : 2,
        jpcCategory: categoryId,
      );

      configChecklists.insert(0, newItem);
      syncStatus = 'Checklist "$checklistName" created successfully ✓';
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating checklist: $e');
      return false;
    }
  }

  /// 2. Update Checklist Name (`POST update-jobplan-checklist-name`)
  Future<bool> updateChecklistName({
    required int jpcId,
    required String checklistName,
    int? jobPlanId,
    String? jobPlanName,
    int? categoryId,
    String? categoryCode,
    String? scheduleName,
    bool? isActive,
  }) async {
    try {
      final status = isActive == null ? null : (isActive ? 1 : 2);
      final success = await apiService.updateChecklistName(
        jpcId: jpcId,
        checklistName: checklistName,
        jobPlanId: jobPlanId,
        categoryId: categoryId,
        status: status,
      );

      final idx = configChecklists.indexWhere((c) => c.jpcId == jpcId);
      if (idx != -1) {
        final old = configChecklists[idx];
        configChecklists[idx] = JobPlanChecklistModel(
          jpcId: old.jpcId,
          jobplanId: jobPlanId ?? old.jobplanId,
          jobplanName: jobPlanName ?? old.jobplanName,
          jobplanCode: old.jobplanCode,
          jpcChecklistName: checklistName,
          scheduleId: old.scheduleId,
          scheduleCode: old.scheduleCode,
          scheduleName: scheduleName ?? old.scheduleName,
          assetCategoryCode: categoryCode ?? old.assetCategoryCode,
          unitCode: old.unitCode,
          jpcStatus: status ?? old.jpcStatus,
          jpcCategory: categoryId ?? old.jpcCategory,
        );
      }
      if (selectedConfigChecklist?.jpcId == jpcId) {
        final old = selectedConfigChecklist!;
        selectedConfigChecklist = JobPlanChecklistModel(
          jpcId: old.jpcId,
          jobplanId: jobPlanId ?? old.jobplanId,
          jobplanName: jobPlanName ?? old.jobplanName,
          jobplanCode: old.jobplanCode,
          jpcChecklistName: checklistName,
          scheduleId: old.scheduleId,
          scheduleCode: old.scheduleCode,
          scheduleName: scheduleName ?? old.scheduleName,
          assetCategoryCode: categoryCode ?? old.assetCategoryCode,
          unitCode: old.unitCode,
          jpcStatus: status ?? old.jpcStatus,
          jpcCategory: categoryId ?? old.jpcCategory,
        );
      }
      syncStatus = 'Checklist updated successfully ✓';
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('Error updating checklist name: $e');
      return false;
    }
  }

  /// 3. Delete Checklist (`POST delete-checklist`)
  Future<bool> deleteChecklist({required int jpcId}) async {
    try {
      await apiService.deleteChecklist(jpcId: jpcId);
      configChecklists.removeWhere((c) => c.jpcId == jpcId);
      if (selectedConfigChecklist?.jpcId == jpcId) {
        selectedConfigChecklist = configChecklists.firstOrNull;
      }
      syncStatus = 'Checklist deleted ✓';
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting checklist: $e');
      return false;
    }
  }

  /// 4. Add Group to Checklist (`POST submit-jobplan-checklist-group`)
  Future<bool> createChecklistGroup({
    required int checklistId,
    required String groupName,
  }) async {
    try {
      await apiService.saveChecklistGroup(
        checkListId: checklistId,
        groupName: groupName,
      );

      final newGroupId = DateTime.now().millisecondsSinceEpoch % 100000;
      checklistGroups.add(
        CheckGroupModel(
          groupId: newGroupId,
          group: groupName,
          checks: [],
          expand: true,
        ),
      );
      syncStatus = 'Group "$groupName" added ✓';
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding checklist group: $e');
      return false;
    }
  }

  /// 5. Add Group Item (`POST submit-jobplan-checklist-group-item`)
  Future<bool> createChecklistGroupItem({
    required int groupId,
    required String subGroup,
    required String checkDescription,
  }) async {
    try {
      await apiService.saveChecklistGroupItem(
        groupId: groupId,
        subGroup: subGroup,
        checkDescription: checkDescription,
      );

      final group = checklistGroups.where((g) => g.groupId == groupId).firstOrNull;
      if (group != null) {
        final newItemId = DateTime.now().millisecondsSinceEpoch % 100000;
        group.checks.add(
          CheckItemModel(
            id: newItemId,
            checkDescription: checkDescription,
            subGroup: subGroup,
            compliance: -1,
            remarks: '',
            isSynced: true,
          ),
        );
        syncStatus = 'Item added to ${group.group} ✓';
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error adding checklist group item: $e');
      return false;
    }
  }

  /// 6. Delete Group Item (`POST delete-checklist-group-item`)
  Future<bool> deleteChecklistGroupItem({
    required int groupId,
    required int checkItemId,
  }) async {
    try {
      await apiService.deleteChecklistItem(checkItemId: checkItemId);
      final group = checklistGroups.where((g) => g.groupId == groupId).firstOrNull;
      if (group != null) {
        group.checks.removeWhere((c) => c.id == checkItemId);
        syncStatus = 'Item #$checkItemId removed ✓';
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error deleting checklist group item: $e');
      return false;
    }
  }

  /// 7. Update Checklist Group Name (`POST update-jobplan-checklist-group`)
  Future<bool> updateChecklistGroup({
    required int groupId,
    required String groupName,
  }) async {
    try {
      await apiService.updateChecklistGroup(
        groupId: groupId,
        groupName: groupName,
      );

      final idx = checklistGroups.indexWhere((g) => g.groupId == groupId);
      if (idx != -1) {
        final old = checklistGroups[idx];
        checklistGroups[idx] = CheckGroupModel(
          group: groupName.trim(),
          groupId: old.groupId,
          expand: old.expand,
          checks: old.checks,
        );
      }
      syncStatus = 'Group renamed to "$groupName" ✓';
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating checklist group: $e');
      return false;
    }
  }

  /// 8. Delete Checklist Group (`POST delete-checklist-group`)
  Future<bool> deleteChecklistGroup({required int groupId}) async {
    try {
      await apiService.deleteChecklistGroup(groupId: groupId);
      checklistGroups.removeWhere((g) => g.groupId == groupId);
      syncStatus = 'Group removed ✓';
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting checklist group: $e');
      return false;
    }
  }

  /// 9. Update Check Item Sub System and Description (`POST update-jobplan-checklist-group-item`)
  Future<bool> updateChecklistGroupItem({
    required int groupId,
    required int checkItemId,
    required String subGroup,
    required String checkDescription,
  }) async {
    try {
      await apiService.updateChecklistGroupItem(
        checkItemId: checkItemId,
        subGroup: subGroup,
        checkDescription: checkDescription,
      );

      final group = checklistGroups.where((g) => g.groupId == groupId).firstOrNull;
      if (group != null) {
        final cIdx = group.checks.indexWhere((c) => c.id == checkItemId);
        if (cIdx != -1) {
          final old = group.checks[cIdx];
          group.checks[cIdx] = CheckItemModel(
            id: old.id,
            subGroup: subGroup.trim(),
            checkDescription: checkDescription.trim(),
            compliance: old.compliance,
            remarks: old.remarks,
            displayOrder: old.displayOrder,
            isSyncing: false,
            isSynced: true,
            lastSyncedAt: DateTime.now(),
          );
        }
      }
      syncStatus = 'Check item updated ✓';
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating check item: $e');
      return false;
    }
  }
}
