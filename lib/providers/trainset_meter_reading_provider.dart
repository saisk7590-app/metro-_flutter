import 'package:flutter/foundation.dart';

import '../models/trainset_meter_reading_model.dart';
import '../repositories/trainset_meter_reading_repository.dart';

class TrainsetMeterReadingProvider extends ChangeNotifier {
  final TrainsetMeterReadingRepository _repository;

  TrainsetMeterReadingProvider({TrainsetMeterReadingRepository? repository})
    : _repository = repository ?? TrainsetMeterReadingRepository();

  bool _isLoading = false;
  String? _errorMessage;
  List<TrainsetMeterReadingModel> _trainsetMeterReadings = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TrainsetMeterReadingModel> get trainsetMeterReadings =>
      _trainsetMeterReadings;

  Future<void> getTrainsetMeterReadings({
    required String date,
    required int pageNo,
    required int pageSize,
    required int pagination,
    required String token,
    required String userSession,
    required String roleId,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result = await _repository.getTrainsetMeterReadings(
        date: date,
        pageNo: pageNo,
        pageSize: pageSize,
        pagination: pagination,
        token: token,
        userSession: userSession,
        roleId: roleId,
      );

      _trainsetMeterReadings = result;

      _isLoading = false;

      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();

      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearData() {
    _trainsetMeterReadings = [];
    notifyListeners();
  }
}
