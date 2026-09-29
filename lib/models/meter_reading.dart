class MeterReading {
  final int meterId;
  final int trainsetId;
  final String meterCode;
  final String meterName;
  final String assetNumber;
  final String previousDate;
  final int previousReading;
  final num cumulativeReading;

  int? currentReading;

  String remarks;

  bool reset;

  String resetRemarks;

  bool isCompleted;

  MeterReading({
    this.meterId = 0,
    this.trainsetId = 0,
    required this.meterCode,
    required this.meterName,
    required this.assetNumber,
    required this.previousDate,
    required this.previousReading,
    this.cumulativeReading = 0,
    this.currentReading,
    this.remarks = '',
    this.reset = false,
    this.resetRemarks = '',
    this.isCompleted = false,
  });

  /// Net Consumption
  int get netReading {
    if (currentReading == null) return 0;

    if (reset) {
      return currentReading!;
    }

    if (currentReading! < previousReading) {
      return 0;
    }

    return currentReading! - previousReading;
  }

  /// Update completion status
  void updateCompletionStatus() {
    if (currentReading == null) {
      isCompleted = false;
      return;
    }

    if (reset) {
      isCompleted = currentReading! >= 0 && resetRemarks.trim().isNotEmpty;
    } else {
      isCompleted = currentReading! >= previousReading;
    }
  }

  /// Convert to API JSON matching TrainsetMeterReading backend model
  Map<String, dynamic> toApiJson({
    required int userId,
    required String date,
  }) {
    final net = netReading;
    return {
      "UserId": userId,
      "TrainsetId": trainsetId,
      "MeterReaidngDate": date,
      "MeterId": meterId,
      "CurrentReading": currentReading ?? 0,
      "Remarks": remarks,
      "Reset": reset ? 1 : 0,
      "ResetRemarks": resetRemarks,
      "NetReading": net,
      "CumilativeReading": (cumulativeReading + net).round(),
    };
  }

  /// Convert to JSON (for local display or debug)
  Map<String, dynamic> toJson() {
    return {
      "meterId": meterId,
      "trainsetId": trainsetId,
      "meterCode": meterCode,
      "meterName": meterName,
      "assetNumber": assetNumber,
      "previousDate": previousDate,
      "previousReading": previousReading,
      "currentReading": currentReading,
      "netReading": netReading,
      "cumulativeReading": cumulativeReading,
      "remarks": remarks,
      "reset": reset,
      "resetRemarks": resetRemarks,
      "isCompleted": isCompleted,
    };
  }
}

