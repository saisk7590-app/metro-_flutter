class MaintenanceBayModel {
  final int id;
  final int slot;
  final String slotName;
  final String slotType;
  final int trainSetId;
  final String trainSetName;
  final int statusId;
  final String statusName;
  final int purposeId;
  final String purposeName;
  final String inward;
  final String outward;
  final String remark;
  final bool isAllocated;
  final bool isOutward;

  MaintenanceBayModel({
    required this.id,
    required this.slot,
    required this.slotName,
    required this.slotType,
    this.trainSetId = 0,
    this.trainSetName = '',
    this.statusId = 0,
    this.statusName = '',
    this.purposeId = 0,
    this.purposeName = '',
    this.inward = '',
    this.outward = '',
    this.remark = '',
    this.isAllocated = false,
    this.isOutward = false,
  });

  factory MaintenanceBayModel.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic value) =>
        value is num ? value.toInt() : int.tryParse('$value') ?? 0;

    String asString(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }
      return '';
    }

    bool asBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      return false;
    }

    final trainSetId = asInt(json['mb_train_set'] ?? json['mbTrainSet'] ?? json['MbaTrainSet'] ?? json['mbaTrainSet']);
    final trainSetName = asString([
      'mb_train_set_name',
      'mbTrainSetName',
      'mbaTrainSetName',
      'trainSetName',
    ]);

    final rawAllocated = json['mb_isallocated'] ?? json['mbIsallocated'] ?? json['MbIsallocated'];
    final computedAllocated = (trainSetId > 0 || trainSetName.isNotEmpty) || (rawAllocated != null && asBool(rawAllocated));

    return MaintenanceBayModel(
      id: asInt(json['mb_id'] ?? json['mbId'] ?? json['MbId'] ?? json['MbaMbId'] ?? json['id']),
      slot: asInt(json['mb_slot'] ?? json['mbSlot'] ?? json['MbSlot'] ?? json['slot']),
      slotName: asString([
        'mb_slot_name',
        'mbSlotName',
        'MbSlotName',
        'mbaSlotName',
        'MbButtonId',
        'mbButtonId',
        'buttonId',
        'slotName',
      ]),
      slotType: asString(['mb_slot_type', 'mbSlotType', 'MbSlotType']),
      trainSetId: trainSetId,
      trainSetName: trainSetName,
      statusId: asInt(json['mb_status'] ?? json['mbStatus'] ?? json['MbStatus'] ?? json['status']),
      statusName: asString(['mb_status_name', 'mbStatusName', 'MbStatusName', 'statusName']),
      purposeId: asInt(json['mb_purpose'] ?? json['mbPurpose'] ?? json['MbPurpose'] ?? json['purpose']),
      purposeName: asString([
        'mb_purpose_name',
        'mbPurposeName',
        'MbPurposeName',
        'purposeName',
      ]),
      inward: asString(['mb_inward', 'mbInward', 'MbInward', 'mbaAllocatedOn', 'createdOn', 'created_on']),
      outward: asString(['mb_outward', 'mbOutward', 'MbOutward']),
      remark: asString(['mb_remark', 'mbRemark', 'MbRemark', 'mbaRemarks', 'remarks']),
      isAllocated: computedAllocated,
      isOutward: asBool(json['isOutward'] ?? json['IsOutward'] ?? json['mb_isOutward'] ?? json['mbIsOutward']),
    );
  }
}

