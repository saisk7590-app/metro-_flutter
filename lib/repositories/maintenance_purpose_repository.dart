import '../models/maintenance_purpose_model.dart';
import '../services/api_service.dart';

class MaintenancePurposeRepository {
  final ApiService api = ApiService();

  Future<List<MaintenancePurposeModel>> getMaintenancePurposes() {
    return api.getMaintenancePurposes();
  }
}
