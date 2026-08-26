class TrainsetMeterModel {
  final int meterType;
  final String meterTypeName;
  final String meterName;
  final int meterAssetId;
  final String associatedAssetName;
  final String associatedAssetNumber;
  final int meterCategory;
  final String previousReadingDate;
  final double previousReading;
  final double currentReading;
  final double cumulativeReading;
  final int reset;
  final String resetRemarks;
  final String remarks;

  TrainsetMeterModel({
    required this.meterType,
    required this.meterTypeName,
    required this.meterName,
    required this.meterAssetId,
    required this.associatedAssetName,
    required this.associatedAssetNumber,
    required this.meterCategory,
    required this.previousReadingDate,
    required this.previousReading,
    required this.currentReading,
    required this.cumulativeReading,
    required this.reset,
    required this.resetRemarks,
    required this.remarks,
  });

  factory TrainsetMeterModel.fromJson(Map<String, dynamic> json) {
    return TrainsetMeterModel(
      meterType: json['mmr_meter_type'],
      meterTypeName: json['mt_name'],
      meterName: json['mmr_meter_name'],
      meterAssetId: json['mmr_meter_assetid'],
      associatedAssetName: json['mmr_assoc_assetname'],
      associatedAssetNumber: json['mmr_assoc_assetnumber'],
      meterCategory: json['mt_category'],
      previousReadingDate: json['mr_previousreadingdate'],
      previousReading: (json['mr_previousreading'] as num).toDouble(),
      currentReading: (json['mr_currentreading'] as num).toDouble(),
      cumulativeReading: (json['mr_cumilativereading'] as num).toDouble(),
      reset: json['mr_reset'],
      resetRemarks: json['mr_reset_remarks'],
      remarks: json['Remarks'],
    );
  }
}

