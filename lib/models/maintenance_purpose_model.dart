class MaintenancePurposeModel {
  final int id;
  final String name;

  MaintenancePurposeModel({required this.id, required this.name});

  factory MaintenancePurposeModel.fromJson(Map<String, dynamic> json) {
    final rawId =
        json['id'] ??
        json['scheduleId'] ??
        json['ScheduleId'] ??
        json['schedule_id'] ??
        json['purposeId'] ??
        json['PurposeId'] ??
        0;
    final rawName =
        json['name'] ??
        json['Name'] ??
        json['scheduleName'] ??
        json['ScheduleName'] ??
        json['scheduleCode'] ??
        json['ScheduleCode'] ??
        json['purposeName'] ??
        json['PurposeName'] ??
        '';

    return MaintenancePurposeModel(
      id: rawId is num ? rawId.toInt() : int.tryParse(rawId.toString()) ?? 0,
      name: rawName.toString(),
    );
  }
}
