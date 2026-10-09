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
  int _totalRows = 0;
  int _pageNo = 1;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TrainsetMeterReadingModel> get trainsetMeterReadings =>
      _trainsetMeterReadings;
  int get totalRows => _totalRows;
  int get pageNo => _pageNo;

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
      _trainsetMeterReadings = result.items;

      // The API returns totalRows on the first page only. Preserve that
      // value while loading later pages.
      if (pageNo == 1 || result.totalRows > 0) {
        _totalRows = result.totalRows;
      }

      _pageNo = result.pageNo > 0 ? result.pageNo : pageNo;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching meter readings: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<List<TrainsetMeterReadingModel>> getAllForSearch({
    required String date,
    required String token,
    required String userSession,
    required String roleId,
  }) async {
    final result = await _repository.getTrainsetMeterReadings(
      date: date,
      pageNo: 1,
      pageSize: 1000,
      pagination: 1,
      token: token,
      userSession: userSession,
      roleId: roleId,
    );
    return result.items;
  }

  void setErrorMessage(String message) {
    _isLoading = false;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearData() {
    _trainsetMeterReadings = [];
    _totalRows = 0;
    _pageNo = 1;
    notifyListeners();
  }
}
