class MeterReading {
  final String meterCode;
  final String meterName;
  final String assetNumber;
  final String previousDate;
  final int previousReading;

  int? currentReading;

  String remarks;

  bool reset;

  String resetRemarks;

  bool isCompleted;

  MeterReading({
    required this.meterCode,
    required this.meterName,
    required this.assetNumber,
    required this.previousDate,
    required this.previousReading,
    this.currentReading,
    this.remarks = '',
    this.reset = false,
    this.resetRemarks = '',
    this.isCompleted = false,
  });

  /// Net Consumption
  int get netReading {
    if (currentReading == null) return 0;

    if (currentReading! < previousReading) {
      return 0;
    }

    return currentReading! - previousReading;
  }

  /// Update completion status
  void updateCompletionStatus() {
    isCompleted =
        currentReading != null &&
        currentReading! >= previousReading &&
        (!reset || resetRemarks.trim().isNotEmpty);
  }

  /// Convert to JSON (for API)
  Map<String, dynamic> toJson() {
    return {
      "meterCode": meterCode,
      "meterName": meterName,
      "assetNumber": assetNumber,
      "previousDate": previousDate,
      "previousReading": previousReading,
      "currentReading": currentReading,
      "netReading": netReading,
      "remarks": remarks,
      "reset": reset,
      "resetRemarks": resetRemarks,
    };
  }
}
