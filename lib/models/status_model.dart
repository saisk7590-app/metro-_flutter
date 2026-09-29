class StatusModel {
  final int id;
  final String name;

  StatusModel({required this.id, required this.name});

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    final rawId =
        json['id'] ??
        json['statusId'] ??
        json['StatusId'] ??
        json['status_id'] ??
        json['value'] ??
        json['lookupId'] ??
        0;
    final rawName =
        json['name'] ??
        json['Name'] ??
        json['statusName'] ??
        json['StatusName'] ??
        json['label'] ??
        json['value'] ??
        '';

    return StatusModel(
      id: rawId is num ? rawId.toInt() : int.tryParse(rawId.toString()) ?? 0,
      name: rawName.toString(),
    );
  }
}
