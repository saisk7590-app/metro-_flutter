import '../models/status_model.dart';
import '../services/api_service.dart';

class StatusRepository {
  final ApiService api = ApiService();

  Future<List<StatusModel>> getStatuses() {
    return api.getMaintenanceStatus();
  }
}
