class TrainsetMeterReadingPage {
  final List<TrainsetMeterReadingModel> items;
  final int totalRows;
  final int pageNo;

  const TrainsetMeterReadingPage({
    required this.items,
    required this.totalRows,
    required this.pageNo,
  });
}

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

  String get formattedPreviousDate {
    if (previousDate.isEmpty) return '-';
    try {
      final datePart = previousDate.split('T').first.split(' ').first;
      final parts = datePart.split('-');
      if (parts.length == 3) {
        // yyyy-MM-dd -> dd-MM-yyyy
        if (parts[0].length == 4) {
          return '${parts[2].padLeft(2, '0')}-${parts[1].padLeft(2, '0')}-${parts[0]}';
        }
        return datePart;
      }
    } catch (_) {}
    return previousDate;
  }

  factory TrainsetMeterReadingModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    String asString(List<String> keys) {
      for (final key in keys) {
        final val = json[key];
        if (val != null && val.toString().trim().isNotEmpty) {
          return val.toString().trim();
        }
      }
      return '';
    }

    return TrainsetMeterReadingModel(
      assetId: toInt(
        json['asset_id'] ??
            json['assetId'] ??
            json['AssetId'] ??
            json['id'] ??
            json['Id'],
      ),
      assetNo: asString(['asset_no', 'assetNo', 'AssetNo', 'trainset', 'Trainset']),
      assetLocation: toInt(
        json['asset_location'] ??
            json['assetLocation'] ??
            json['AssetLocation'] ??
            json['location_id'] ??
            json['locationId'],
      ),
      locationCode: asString(['location_code', 'locationCode', 'LocationCode']),
      locationName: asString(['location_name', 'locationName', 'LocationName']),
      previousDate: asString([
        'PrevoiusDate',
        'PreviousDate',
        'prevoiusDate',
        'previousDate',
        'prevoius_date',
        'previous_date',
      ]),
      previousDateReading: asString([
        'PrevoiusDateReading',
        'PreviousDateReading',
        'prevoiusDateReading',
        'previousDateReading',
        'prevoius_date_reading',
        'previous_date_reading',
      ]),
      todayReading: asString([
        'TodayReading',
        'todayReading',
        'today_reading',
        'CurrentDayStatus',
        'currentDayStatus',
      ]),
    );
  }
}
