import '../models/maintenance_bay_model.dart';
import '../services/api_service.dart';

class MaintenanceBayRepository {
  final ApiService api = ApiService();

  Future<List<MaintenanceBayModel>> getMaintenanceBay(int depotId) {
    return api.getMaintenanceBay(depotId);
  }

  Future<Map<String, dynamic>> saveMaintenanceBay({
    required int mbId,
    required int mbDepot,
    required int mbSlot,
    required int mbTrainSet,
    required int mbStatus,
    required int mbPurpose,
    required String mbInward,
    required String mbOutward,
    required String mbRemark,
  }) {
    return api.saveMaintenanceBay(
      mbId: mbId,
      mbDepot: mbDepot,
      mbSlot: mbSlot,
      mbTrainSet: mbTrainSet,
      mbStatus: mbStatus,
      mbPurpose: mbPurpose,
      mbInward: mbInward,
      mbOutward: mbOutward,
      mbRemark: mbRemark,
    );
  }
}
