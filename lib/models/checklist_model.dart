import 'dart:convert';

/// Represents an individual inspection check item inside a checklist group
class CheckItemModel {
  final int id;
  final String subGroup;
  final String checkDescription;
  int compliance; // 0 = No, 1 = Partial, 2 = Full, -1 = Unchecked
  String remarks;
  final int displayOrder;

  // Mobile local state
  bool isSyncing;
  bool isSynced;
  DateTime? lastSyncedAt;
  String? syncError;

  CheckItemModel({
    required this.id,
    required this.subGroup,
    required this.checkDescription,
    this.compliance = 2, // Default compliant or existing
    this.remarks = '',
    this.displayOrder = 0,
    this.isSyncing = false,
    this.isSynced = true,
    this.lastSyncedAt,
    this.syncError,
  });

  factory CheckItemModel.fromJson(Map<String, dynamic> json) {
    int parsedCompliance = 0;
    if (json['Compliance'] != null) {
      parsedCompliance = int.tryParse(json['Compliance'].toString()) ?? 0;
    } else if (json['compliance'] != null) {
      parsedCompliance = int.tryParse(json['compliance'].toString()) ?? 0;
    }

    String parsedRemarks = (json['Remarks'] ?? json['remarks'] ?? '').toString();
    if (parsedRemarks == '--') parsedRemarks = '';

    return CheckItemModel(
      id: json['Id'] ?? json['id'] ?? 0,
      subGroup: (json['SubGroup'] ?? json['subGroup'] ?? '').toString(),
      checkDescription: (json['CheckDescription'] ?? json['checkDescription'] ?? '').toString(),
      compliance: parsedCompliance,
      remarks: parsedRemarks,
      displayOrder: json['displayOrder'] ?? 0,
      isSynced: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'SubGroup': subGroup,
      'CheckDescription': checkDescription,
      'Compliance': compliance,
      'Remarks': remarks,
    };
  }

  /// Compact payload for live item comment/compliance update
  Map<String, dynamic> toCommentJson() {
    return {
      'Id': id,
      'Compliance': compliance,
      'Remarks': remarks.trim(),
    };
  }

  CheckItemModel copyWith({
    int? compliance,
    String? remarks,
    bool? isSyncing,
    bool? isSynced,
    DateTime? lastSyncedAt,
    String? syncError,
  }) {
    return CheckItemModel(
      id: id,
      subGroup: subGroup,
      checkDescription: checkDescription,
      compliance: compliance ?? this.compliance,
      remarks: remarks ?? this.remarks,
      displayOrder: displayOrder,
      isSyncing: isSyncing ?? this.isSyncing,
      isSynced: isSynced ?? this.isSynced,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      syncError: syncError ?? this.syncError,
    );
  }
}

/// Represents a subsystem group of checks (e.g., Bogie, Brake, Electrical)
class CheckGroupModel {
  final String group;
  final int groupId;
  bool expand;
  final List<CheckItemModel> checks;

  CheckGroupModel({
    required this.group,
    this.groupId = 0,
    this.expand = true,
    required this.checks,
  });

  factory CheckGroupModel.fromJson(Map<String, dynamic> json) {
    final groupName = (json['Group'] ?? json['group'] ?? 'General').toString();
    final gId = json['GroupId'] ?? json['groupId'] ?? 0;

    List<CheckItemModel> checkList = [];
    final rawChecks = json['Checks'] ?? json['checks'];
    if (rawChecks is List) {
      checkList = rawChecks
          .map((c) => CheckItemModel.fromJson(c as Map<String, dynamic>))
          .toList();
    } else if (rawChecks is String && rawChecks.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawChecks) as List;
        checkList = decoded
            .map((c) => CheckItemModel.fromJson(c as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    return CheckGroupModel(
      group: groupName,
      groupId: gId is int ? gId : int.tryParse(gId.toString()) ?? 0,
      expand: true,
      checks: checkList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Group': group,
      'GroupId': groupId,
      'Checks': checks.map((c) => c.toJson()).toList(),
    };
  }

  int get totalCount => checks.length;
  int get fullCount => checks.where((c) => c.compliance == 2).length;
  int get partialCount => checks.where((c) => c.compliance == 1).length;
  int get noCount => checks.where((c) => c.compliance == 0).length;
  bool get isCompleted => checks.isNotEmpty && checks.every((c) => c.compliance >= 0);
}

/// Represents a depot Work Order assigned to technicians
class ChecklistWorkOrder {
  final int id;
  final String no;
  final String type;
  final String unit;
  final String assetDetails; // e.g. "TS-01" or "DMC1"
  final String description;
  final String priority;
  final String status;
  final String location;
  final String schedule;
  final String plannedFrom;
  final DateTime? generatedDate;
  int totalChecks;
  int completedChecks;

  ChecklistWorkOrder({
    required this.id,
    required this.no,
    this.type = 'Preventive',
    this.unit = 'Rolling Stock',
    required this.assetDetails,
    required this.description,
    this.priority = 'Medium',
    this.status = 'In Progress',
    this.location = 'Miyapur Depot',
    this.schedule = 'Daily Inspection',
    this.plannedFrom = '',
    this.generatedDate,
    this.totalChecks = 0,
    this.completedChecks = 0,
  });

  factory ChecklistWorkOrder.fromJson(Map<String, dynamic> json) {
    return ChecklistWorkOrder(
      id: json['Id'] ?? json['wo_id'] ?? json['id'] ?? 0,
      no: (json['No'] ?? json['wo_no'] ?? json['no'] ?? 'WO-NEW').toString(),
      type: (json['Type'] ?? json['wo_type'] ?? 'Preventive').toString(),
      unit: (json['Unit'] ?? json['unit_code'] ?? 'Rolling Stock').toString(),
      assetDetails: (json['AssetDetails'] ?? json['wo_asset_details'] ?? 'TS-01').toString(),
      description: (json['Description'] ?? json['wo_description'] ?? 'Inspection Routine').toString(),
      priority: (json['Priority'] ?? json['wo_priority'] ?? 'Medium').toString(),
      status: (json['Status'] ?? json['wo_status'] ?? 'Assigned').toString(),
      location: (json['Location'] ?? json['wo_location'] ?? 'Depot Bay').toString(),
      schedule: (json['Schedule'] ?? json['schedule'] ?? 'Scheduled Check').toString(),
      plannedFrom: (json['PlannedFrom'] ?? json['wo_planned_from'] ?? '').toString(),
    );
  }

  double get progressPercentage =>
      totalChecks > 0 ? (completedChecks / totalChecks).clamp(0.0, 1.0) : 0.0;
}

/// Represents a master Maintenance Checklist configured under Config Maintenance -> Checklists
class JobPlanChecklistModel {
  final int jpcId;
  final int jobplanId;
  final String jobplanName;
  final String jobplanCode;
  final String jpcChecklistName;
  final int scheduleId;
  final String scheduleCode;
  final String scheduleName;
  final String assetCategoryCode;
  final String unitCode;
  final int jpcStatus; // 1 = Active, 2 = Inactive
  final int? jpcCategory;

  JobPlanChecklistModel({
    required this.jpcId,
    required this.jobplanId,
    required this.jobplanName,
    this.jobplanCode = '',
    required this.jpcChecklistName,
    this.scheduleId = 0,
    this.scheduleCode = '',
    required this.scheduleName,
    required this.assetCategoryCode,
    this.unitCode = 'Rolling Stock',
    this.jpcStatus = 1,
    this.jpcCategory,
  });

  factory JobPlanChecklistModel.fromJson(Map<String, dynamic> json) {
    return JobPlanChecklistModel(
      jpcId: json['jpc_id'] ?? json['jpcId'] ?? json['id'] ?? 0,
      jobplanId: json['jobplan_id'] ?? json['jobplanId'] ?? 0,
      jobplanName: (json['jobplan_name'] ?? json['jobplanName'] ?? 'General Inspection').toString(),
      jobplanCode: (json['jobplan_code'] ?? json['jobplanCode'] ?? '').toString(),
      jpcChecklistName: (json['jpc_checklist_name'] ?? json['jpcChecklistName'] ?? json['name'] ?? 'Inspection Checklist').toString(),
      scheduleId: json['schedule_id'] ?? json['scheduleId'] ?? 0,
      scheduleCode: (json['schedule_code'] ?? json['scheduleCode'] ?? '').toString(),
      scheduleName: (json['schedule_name'] ?? json['scheduleName'] ?? 'Scheduled PM').toString(),
      assetCategoryCode: (json['asset_category_code'] ?? json['assetCategoryCode'] ?? 'Rolling Stock').toString(),
      unitCode: (json['unit_code'] ?? json['unitCode'] ?? 'Rolling Stock').toString(),
      jpcStatus: json['jpc_status'] ?? json['jpcStatus'] ?? 1,
      jpcCategory: json['jpc_category'] ?? json['jpcCategory'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jpc_id': jpcId,
      'jobplan_id': jobplanId,
      'jobplan_name': jobplanName,
      'jobplan_code': jobplanCode,
      'jpc_checklist_name': jpcChecklistName,
      'schedule_id': scheduleId,
      'schedule_code': scheduleCode,
      'schedule_name': scheduleName,
      'asset_category_code': assetCategoryCode,
      'unit_code': unitCode,
      'jpc_status': jpcStatus,
    };
  }

  bool get isActive => jpcStatus == 1;
}

/// Represents an Asset Category dropdown option matching website `assetCategories`
class ChecklistCategoryItem {
  final String code; // assetCategoryId e.g. "1"
  final String value; // assetCategoryCode e.g. "RS"

  const ChecklistCategoryItem({required this.code, required this.value});

  factory ChecklistCategoryItem.fromJson(Map<String, dynamic> json) {
    return ChecklistCategoryItem(
      code: (json['assetCategoryId'] ?? json['id'] ?? json['code'] ?? '').toString(),
      value: (json['assetCategoryCode'] ?? json['assetCategoryName'] ?? json['value'] ?? json['name'] ?? '').toString(),
    );
  }
}

/// Represents a Job Plan dropdown option matching website `jobPlans`
class ChecklistJobPlanItem {
  final int jobPlanId;
  final String jobPlanName;
  final String schedule;

  const ChecklistJobPlanItem({
    required this.jobPlanId,
    required this.jobPlanName,
    this.schedule = 'Scheduled Routine',
  });

  factory ChecklistJobPlanItem.fromJson(Map<String, dynamic> json) {
    return ChecklistJobPlanItem(
      jobPlanId: int.tryParse((json['jobPlanId'] ?? json['id'] ?? 0).toString()) ?? 0,
      jobPlanName: (json['jobPlanName'] ?? json['name'] ?? '').toString(),
      schedule: (json['schedule'] ?? json['scheduleName'] ?? json['schedule_name'] ?? 'Scheduled Routine').toString(),
    );
  }
}

/// Represents a Checklist Name dropdown option matching website `jobPlanCheckListNamesItems`
class ChecklistNameItem {
  final int id;
  final String name;

  const ChecklistNameItem({required this.id, required this.name});

  factory ChecklistNameItem.fromJson(Map<String, dynamic> json) {
    return ChecklistNameItem(
      id: int.tryParse((json['id'] ?? 0).toString()) ?? 0,
      name: (json['name'] ?? json['checklistName'] ?? json['code'] ?? '').toString(),
    );
  }
}

