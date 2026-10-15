export 'wheel_tolerances.dart';

/// History item from `search-ts-wm`
class WheelMeasurementListItem {
  final int id;
  final int woId;
  final String woNumber;
  final int tsId;
  final String tsNumber;
  final String measuredDate;
  final String schedule;
  final int scheduleId;
  final double kmReading;
  final String lastMeasuredSchedule;
  final double lastKmReading;
  final String remarks;
  final double averageDia;

  WheelMeasurementListItem({
    required this.id,
    required this.woId,
    required this.woNumber,
    required this.tsId,
    required this.tsNumber,
    required this.measuredDate,
    required this.schedule,
    required this.scheduleId,
    required this.kmReading,
    required this.lastMeasuredSchedule,
    required this.lastKmReading,
    required this.remarks,
    required this.averageDia,
  });

  factory WheelMeasurementListItem.fromJson(Map<String, dynamic> json) {
    return WheelMeasurementListItem(
      id: json['Id'] is int ? json['Id'] : int.tryParse(json['Id']?.toString() ?? '') ?? 0,
      woId: json['WOId'] is int ? json['WOId'] : int.tryParse(json['WOId']?.toString() ?? '') ?? 0,
      woNumber: json['WONumber']?.toString() ?? '',
      tsId: json['TSId'] is int ? json['TSId'] : int.tryParse(json['TSId']?.toString() ?? '') ?? 0,
      tsNumber: json['TSNumber']?.toString() ?? '',
      measuredDate: json['MeasuredDate']?.toString() ?? '',
      schedule: json['Schedule']?.toString() ?? '',
      scheduleId: json['ScheduleId'] is int
          ? json['ScheduleId']
          : int.tryParse(json['ScheduleId']?.toString() ?? '') ?? 0,
      kmReading: (json['KMReading'] is num)
          ? (json['KMReading'] as num).toDouble()
          : double.tryParse(json['KMReading']?.toString() ?? '') ?? 0.0,
      lastMeasuredSchedule: json['LastMeasuredSchedule']?.toString() ?? '',
      lastKmReading: (json['LastKMReading'] is num)
          ? (json['LastKMReading'] as num).toDouble()
          : double.tryParse(json['LastKMReading']?.toString() ?? '') ?? 0.0,
      remarks: json['Remarks']?.toString() ?? '',
      averageDia: (json['AverageDia'] is num)
          ? (json['AverageDia'] as num).toDouble()
          : double.tryParse(json['AverageDia']?.toString() ?? '') ?? 0.0,
    );
  }
}

/// A single wheel under a wheelset
class WheelItem {
  int assetId;
  String assetNo;
  String assetPosition; // e.g., "W1", "W2"
  double? dia;
  double? ovality;
  double? warp;
  double? ft;
  double? fh;
  double? qr;
  double? daf;
  double? dif;

  WheelItem({
    required this.assetId,
    required this.assetNo,
    required this.assetPosition,
    this.dia,
    this.ovality,
    this.warp,
    this.ft,
    this.fh,
    this.qr,
    this.daf,
    this.dif,
  });

  factory WheelItem.fromJson(Map<String, dynamic> json) {
    return WheelItem(
      assetId: json['assetId'] is int ? json['assetId'] : int.tryParse(json['assetId']?.toString() ?? '') ?? 0,
      assetNo: json['assetNo']?.toString() ?? '',
      assetPosition: json['assetPosition']?.toString() ?? '',
      dia: json['dia'] != null ? (json['dia'] as num?)?.toDouble() : null,
      ovality: json['ovality'] != null ? (json['ovality'] as num?)?.toDouble() : null,
      warp: json['warp'] != null ? (json['warp'] as num?)?.toDouble() : null,
      ft: json['ft'] != null ? (json['ft'] as num?)?.toDouble() : null,
      fh: json['fh'] != null ? (json['fh'] as num?)?.toDouble() : null,
      qr: json['qr'] != null ? (json['qr'] as num?)?.toDouble() : null,
      daf: json['daf'] != null ? (json['daf'] as num?)?.toDouble() : null,
      dif: json['dif'] != null ? (json['dif'] as num?)?.toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assetId': assetId,
      'assetNo': assetNo,
      'assetPosition': assetPosition,
      'dia': dia ?? 0.0,
      'ovality': ovality ?? 0.0,
      'warp': warp ?? 0.0,
      'ft': ft ?? 0.0,
      'fh': fh ?? 0.0,
      'qr': qr ?? 0.0,
      'daf': daf ?? 0.0,
      'dif': dif ?? 0.0,
    };
  }
}

/// A wheelset axle containing 2 wheels (LHS & RHS)
class WheelSetItem {
  int assetId;
  String assetNo;
  String assetPosition; // e.g., "WS1", "WS2"
  List<WheelItem> wheels;

  WheelSetItem({
    required this.assetId,
    required this.assetNo,
    required this.assetPosition,
    required this.wheels,
  });

  factory WheelSetItem.fromJson(Map<String, dynamic> json) {
    final rawWheels = json['wheels'] as List<dynamic>? ?? [];
    return WheelSetItem(
      assetId: json['assetId'] is int ? json['assetId'] : int.tryParse(json['assetId']?.toString() ?? '') ?? 0,
      assetNo: json['assetNo']?.toString() ?? '',
      assetPosition: json['assetPosition']?.toString() ?? '',
      wheels: rawWheels.map((w) => WheelItem.fromJson(w as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assetId': assetId,
      'assetNo': assetNo,
      'assetPosition': assetPosition,
      'wheels': wheels.map((w) => w.toJson()).toList(),
    };
  }

  /// Calculates diameter difference between LHS and RHS on this axle
  double? get axleDiaDifference {
    if (wheels.length >= 2 && wheels[0].dia != null && wheels[1].dia != null) {
      return (wheels[0].dia! - wheels[1].dia!).abs();
    }
    return null;
  }
}

/// Bogie under a car
class BogieItem {
  int assetId;
  String assetNo;
  String assetPosition; // e.g., "B1", "B2"

  BogieItem({
    required this.assetId,
    required this.assetNo,
    required this.assetPosition,
  });

  factory BogieItem.fromJson(Map<String, dynamic> json) {
    return BogieItem(
      assetId: json['assetId'] is int ? json['assetId'] : int.tryParse(json['assetId']?.toString() ?? '') ?? 0,
      assetNo: json['assetNo']?.toString() ?? '',
      assetPosition: json['assetPosition']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assetId': assetId,
      'assetNo': assetNo,
      'assetPosition': assetPosition,
    };
  }
}

/// Metro Car (e.g., DMC1, TC, DMC2)
class CarItem {
  int carId;
  String carType; // "DMA CAR", "TC CAR", "DMB CAR"
  String carNum;  // "DMC1", "TC", "DMC2"
  List<BogieItem> bogie;
  List<WheelSetItem> wheelSets;

  CarItem({
    required this.carId,
    required this.carType,
    required this.carNum,
    required this.bogie,
    required this.wheelSets,
  });

  factory CarItem.fromJson(Map<String, dynamic> json) {
    final rawBogies = json['bogie'] as List<dynamic>? ?? [];
    final rawWheelSets = json['wheelSets'] as List<dynamic>? ?? [];
    return CarItem(
      carId: json['carId'] is int ? json['carId'] : int.tryParse(json['carId']?.toString() ?? '') ?? 0,
      carType: json['carType']?.toString() ?? '',
      carNum: json['carNum']?.toString() ?? '',
      bogie: rawBogies.map((b) => BogieItem.fromJson(b as Map<String, dynamic>)).toList(),
      wheelSets: rawWheelSets.map((ws) => WheelSetItem.fromJson(ws as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carId': carId,
      'carType': carType,
      'carNum': carNum,
      'bogie': bogie.map((b) => b.toJson()).toList(),
      'wheelSets': wheelSets.map((ws) => ws.toJson()).toList(),
    };
  }
}

/// Full Wheel Measurement submission model (`save-wo-wm` and `get-wo-wm`)
class WheelMeasurementData {
  int id;
  int woId;
  int trainsetId;
  String trainsetNo;
  int? scheduleId;
  String scheduleCode;
  String remarks;
  int? addedBy;
  double? kmReading;
  double lastKmReading;
  String lastMeasurePurpose;
  String? lastMeasure;
  String? measuredDate;
  List<CarItem> cars;
  int submit; // 0: Draft, 1: Submit

  WheelMeasurementData({
    this.id = 0,
    required this.woId,
    required this.trainsetId,
    required this.trainsetNo,
    this.scheduleId,
    this.scheduleCode = '',
    this.remarks = '',
    this.addedBy,
    this.kmReading,
    this.lastKmReading = 0.0,
    this.lastMeasurePurpose = '',
    this.lastMeasure,
    this.measuredDate,
    required this.cars,
    this.submit = 0,
  });

  factory WheelMeasurementData.fromJson(Map<String, dynamic> json) {
    final rawCars = json['cars'] as List<dynamic>? ?? [];
    return WheelMeasurementData(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      woId: json['woId'] is int ? json['woId'] : int.tryParse(json['woId']?.toString() ?? '') ?? 0,
      trainsetId: json['trainsetId'] is int ? json['trainsetId'] : int.tryParse(json['trainsetId']?.toString() ?? '') ?? 0,
      trainsetNo: json['trainsetNo']?.toString() ?? '',
      scheduleId: json['scheduleId'] as int?,
      scheduleCode: json['scheduleCode']?.toString() ?? '',
      remarks: json['remarks']?.toString() ?? '',
      addedBy: json['addedBy'] as int?,
      kmReading: (json['kmReading'] is num) ? (json['kmReading'] as num).toDouble() : null,
      lastKmReading: (json['lastKMReading'] is num) ? (json['lastKMReading'] as num).toDouble() : 0.0,
      lastMeasurePurpose: json['lastMeasurePurpose']?.toString() ?? '',
      lastMeasure: json['lastMeasure']?.toString(),
      measuredDate: json['measuredDate']?.toString(),
      cars: rawCars.map((c) => CarItem.fromJson(c as Map<String, dynamic>)).toList(),
      submit: json['submit'] is int ? json['submit'] : int.tryParse(json['submit']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'woId': woId,
      'trainsetId': trainsetId,
      'trainsetNo': trainsetNo,
      'scheduleId': scheduleId,
      'scheduleCode': scheduleCode,
      'remarks': remarks,
      'addedBy': addedBy,
      'kmReading': kmReading,
      'lastKMReading': lastKmReading,
      'lastMeasurePurpose': lastMeasurePurpose,
      'lastMeasure': lastMeasure,
      'measuredDate': measuredDate,
      'cars': cars.map((c) => c.toJson()).toList(),
      'submit': submit,
    };
  }
}
