class MaintenanceBayModel {
  final int id;
  final int slot;
  final String slotName;
  final String slotType;

  MaintenanceBayModel({
    required this.id,
    required this.slot,
    required this.slotName,
    required this.slotType,
  });

  factory MaintenanceBayModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceBayModel(
      id: json['mb_id'] ?? 0,
      slot: json['mb_slot'] ?? 0,
      slotName: json['mb_slot_name'] ?? '',
      slotType: json['mb_slot_type'] ?? '',
    );
  }
}
