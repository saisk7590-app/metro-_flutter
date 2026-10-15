/// Tolerance limits and acceptance criteria from NxAMS specification
class WheelTolerances {
  // Diameter (mm)
  static const double minDia = 780.0;
  static const double maxDia = 860.5;

  // Ovality & Warp (mm)
  static const double maxOvality = 0.5;
  static const double maxWarp = 1.0;

  // Flange Thickness (mm)
  static const double minFT = 25.0;
  static const double maxFT = 33.0;

  // Flange Height (mm)
  static const double minFH = 28.0;
  static const double maxFH = 36.0;

  // QR (mm)
  static const double minQR = 6.5;

  // Distance Internal Flanges (DIF) (mm)
  static const double minDIF = 1358.0;
  static const double maxDIF = 1360.0;

  // Distance Across Flanges (DAF) (mm)
  static const double minDAF = 1408.0;
  static const double maxDAF = 1425.0;

  // Acceptability differences in Dia (mm)
  static const double maxSameAxleDiff = 1.0;
  static const double maxSameBogieMotorDiff = 3.0;
  static const double maxSameBogieTrailerDiff = 6.0;
  static const double maxSameCarMotorDiff = 6.0;
  static const double maxSameCarTrailerDiff = 13.0;

  static String? validateDia(double? val) {
    if (val == null) return "Required";
    if (val < minDia || val > maxDia) {
      return "Dia must be between $minDia - $maxDia mm";
    }
    return null;
  }

  static String? validateOvality(double? val) {
    if (val == null) return null;
    if (val > maxOvality) return "Ovality must be ≤ $maxOvality mm";
    return null;
  }

  static String? validateWarp(double? val) {
    if (val == null) return null;
    if (val > maxWarp) return "Warp must be ≤ $maxWarp mm";
    return null;
  }

  static String? validateFT(double? val) {
    if (val == null) return null;
    if (val < minFT || val > maxFT) {
      return "FT must be between $minFT - $maxFT mm";
    }
    return null;
  }

  static String? validateFH(double? val) {
    if (val == null) return null;
    if (val < minFH || val > maxFH) {
      return "FH must be between $minFH - $maxFH mm";
    }
    return null;
  }

  static String? validateQR(double? val) {
    if (val == null) return null;
    if (val < minQR) return "QR must be ≥ $minQR mm";
    return null;
  }

  static String? validateDIF(double? val) {
    if (val == null) return null;
    if (val < minDIF || val > maxDIF) {
      return "DIF must be between $minDIF - $maxDIF mm";
    }
    return null;
  }

  static String? validateDAF(double? val) {
    if (val == null) return null;
    if (val < minDAF || val > maxDAF) {
      return "DAF must be between $minDAF - $maxDAF mm";
    }
    return null;
  }
}
