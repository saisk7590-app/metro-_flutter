import '../../models/meter_reading.dart';

class MeterValidation {
  const MeterValidation._();

  //--------------------------------------------------
  // Current Reading Validation
  //--------------------------------------------------

  static bool isReadingValid({
    required num previousReading,
    required num? currentReading,
    bool isReset = false,
  }) {
    if (currentReading == null) {
      return false;
    }

    if (isReset) {
      return currentReading >= 0;
    }

    return currentReading >= previousReading;
  }

  //--------------------------------------------------
  // Net Reading
  //--------------------------------------------------

  static num calculateNetReading({
    required num previousReading,
    required num? currentReading,
    bool isReset = false,
  }) {
    if (currentReading == null) {
      return 0;
    }

    if (isReset) {
      return currentReading;
    }

    if (currentReading < previousReading) {
      return 0;
    }

    return currentReading - previousReading;
  }

  //--------------------------------------------------
  // Error Text
  //--------------------------------------------------

  static String? readingError({
    required num previousReading,
    required num? currentReading,
    bool isReset = false,
  }) {
    if (currentReading == null) {
      return "Current Reading is required";
    }

    if (isReset) {
      if (currentReading < 0) {
        return "Current Reading must be greater than or equal to 0";
      }
      return null;
    }

    if (currentReading < previousReading) {
      return "Current Reading must be greater than or equal to Previous Reading";
    }

    return null;
  }

  //--------------------------------------------------
  // Meter Completed
  //--------------------------------------------------

  static bool isMeterCompleted(MeterReading meter) {
    if (meter.currentReading == null) return false;

    if (meter.reset) {
      return meter.currentReading! >= 0 && meter.resetRemarks.trim().isNotEmpty;
    }

    return meter.currentReading! >= meter.previousReading;
  }

  //--------------------------------------------------
  // Update Meter Status
  //--------------------------------------------------

  static void updateMeterStatus(MeterReading meter) {
    meter.isCompleted = isMeterCompleted(meter);
  }

  //--------------------------------------------------
  // Completed Count
  //--------------------------------------------------

  static int completedMeters(List<MeterReading> meters) {
    return meters.where((meter) => meter.isCompleted).length;
  }

  //--------------------------------------------------
  // Save Button Validation
  //--------------------------------------------------

  static bool canSave(List<MeterReading> meters) {
    return meters.isNotEmpty && meters.any((meter) => meter.isCompleted);
  }

  //--------------------------------------------------
  // Entire Payload Validation
  //--------------------------------------------------

  static bool validateAllMeters(List<MeterReading> meters) {
    for (final meter in meters) {
      if (!isMeterCompleted(meter)) {
        return false;
      }
    }

    return true;
  }
}

