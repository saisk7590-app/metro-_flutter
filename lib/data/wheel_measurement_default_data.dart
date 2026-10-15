import '../models/wheel/wheel_measurement_model.dart';

class WheelMeasurementDefaultData {
  static List<CarItem> generateDefaultCarHierarchy() {
    return [
      _createCar(1, "DMA CAR", "DMC1"),
      _createCar(2, "TC CAR", "TC"),
      _createCar(3, "DMB CAR", "DMC2"),
    ];
  }

  static CarItem _createCar(int carId, String carType, String carNum) {
    return CarItem(
      carId: carId,
      carType: carType,
      carNum: carNum,
      bogie: [
        BogieItem(assetId: carId * 10 + 1, assetNo: "BG-01", assetPosition: "B1"),
        BogieItem(assetId: carId * 10 + 2, assetNo: "BG-02", assetPosition: "B2"),
      ],
      wheelSets: [
        WheelSetItem(
          assetId: carId * 100 + 1,
          assetNo: "WS-01",
          assetPosition: "WS1",
          wheels: [
            WheelItem(assetId: carId * 1000 + 1, assetNo: "W-01", assetPosition: "W1 (LHS)", dia: 840.0, ft: 30.0, fh: 30.0, qr: 8.5, ovality: 0.1, warp: 0.2, daf: 1412.0, dif: 1359.0),
            WheelItem(assetId: carId * 1000 + 2, assetNo: "W-02", assetPosition: "W2 (RHS)", dia: 840.2, ft: 30.0, fh: 30.0, qr: 8.5, ovality: 0.1, warp: 0.2, daf: 1412.0, dif: 1359.0),
          ],
        ),
        WheelSetItem(
          assetId: carId * 100 + 2,
          assetNo: "WS-02",
          assetPosition: "WS2",
          wheels: [
            WheelItem(assetId: carId * 1000 + 3, assetNo: "W-03", assetPosition: "W3 (LHS)", dia: 839.8, ft: 29.5, fh: 30.2, qr: 8.4, ovality: 0.15, warp: 0.2, daf: 1412.0, dif: 1359.0),
            WheelItem(assetId: carId * 1000 + 4, assetNo: "W-04", assetPosition: "W4 (RHS)", dia: 840.0, ft: 29.8, fh: 30.1, qr: 8.4, ovality: 0.12, warp: 0.2, daf: 1412.0, dif: 1359.0),
          ],
        ),
        WheelSetItem(
          assetId: carId * 100 + 3,
          assetNo: "WS-03",
          assetPosition: "WS3",
          wheels: [
            WheelItem(assetId: carId * 1000 + 5, assetNo: "W-05", assetPosition: "W5 (LHS)", dia: 841.0, ft: 30.2, fh: 29.8, qr: 8.6, ovality: 0.1, warp: 0.3, daf: 1413.0, dif: 1359.0),
            WheelItem(assetId: carId * 1000 + 6, assetNo: "W-06", assetPosition: "W6 (RHS)", dia: 841.1, ft: 30.1, fh: 29.9, qr: 8.5, ovality: 0.1, warp: 0.2, daf: 1413.0, dif: 1359.0),
          ],
        ),
        WheelSetItem(
          assetId: carId * 100 + 4,
          assetNo: "WS-04",
          assetPosition: "WS4",
          wheels: [
            WheelItem(assetId: carId * 1000 + 7, assetNo: "W-07", assetPosition: "W7 (LHS)", dia: 840.9, ft: 30.0, fh: 30.0, qr: 8.5, ovality: 0.11, warp: 0.2, daf: 1413.0, dif: 1359.0),
            WheelItem(assetId: carId * 1000 + 8, assetNo: "W-08", assetPosition: "W8 (RHS)", dia: 841.0, ft: 30.0, fh: 30.0, qr: 8.5, ovality: 0.10, warp: 0.2, daf: 1413.0, dif: 1359.0),
          ],
        ),
      ],
    );
  }
}
