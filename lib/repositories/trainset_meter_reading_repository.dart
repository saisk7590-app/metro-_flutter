import '../models/trainset_meter_reading_model.dart';
import '../services/api_service.dart';

class TrainsetMeterReadingRepository {
  final ApiService _apiService;

  TrainsetMeterReadingRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<List<TrainsetMeterReadingModel>> getTrainsetMeterReadings({
    required String date,
    required int pageNo,
    required int pageSize,
    required int pagination,
    required String token,
    required String userSession,
  }) async {
    return await _apiService.getTrainsetMeterReadings(
      date: date,
      pageNo: pageNo,
      pageSize: pageSize,
      pagination: pagination,
      token: token,
      userSession: userSession,
    );
  }
}
