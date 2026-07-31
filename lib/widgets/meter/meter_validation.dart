import '../../models/meter_reading.dart';

class MeterValidation {
  const MeterValidation._();

  //--------------------------------------------------
  // Current Reading Validation
  //--------------------------------------------------

  static bool isReadingValid({
    required int previousReading,
    required int? currentReading,
  }) {
    if (currentReading == null) {
      return false;
    }

    return currentReading >= previousReading;
  }

  //--------------------------------------------------
  // Net Reading
  //--------------------------------------------------

  static int calculateNetReading({
    required int previousReading,
    required int? currentReading,
  }) {
    if (currentReading == null) {
      return 0;
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
    required int previousReading,
    required int? currentReading,
  }) {
    if (currentReading == null) {
      return "Current Reading is required";
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
    final readingValid =
        meter.currentReading != null &&
        meter.currentReading! >= meter.previousReading;

    final resetValid = !meter.reset || meter.resetRemarks.trim().isNotEmpty;

    return readingValid && resetValid;
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
    return meters.isNotEmpty && meters.every((meter) => meter.isCompleted);
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
