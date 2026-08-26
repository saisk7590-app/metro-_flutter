class TrainsetMeterReadingModel {
  final int assetId;
  final String assetNo;
  final int assetLocation;
  final String locationCode;
  final String locationName;
  final String previousDate;
  final String previousDateReading;
  final String todayReading;

  TrainsetMeterReadingModel({
    required this.assetId,
    required this.assetNo,
    required this.assetLocation,
    required this.locationCode,
    required this.locationName,
    required this.previousDate,
    required this.previousDateReading,
    required this.todayReading,
  });

  factory TrainsetMeterReadingModel.fromJson(Map<String, dynamic> json) {
    return TrainsetMeterReadingModel(
      assetId: json['asset_id'],
      assetNo: json['asset_no'],
      assetLocation: json['asset_location'],
      locationCode: json['location_code'],
      locationName: json['location_name'],
      previousDate: json['PrevoiusDate'],
      previousDateReading: json['PrevoiusDateReading'],
      todayReading: json['TodayReading'],
    );
  }
}

