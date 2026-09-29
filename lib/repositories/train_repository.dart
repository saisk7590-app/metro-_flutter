import '../models/train_model.dart';
import '../services/api_service.dart';

class TrainRepository {
  final ApiService api = ApiService();

  Future<List<TrainModel>> getTrainSets({
    String? token,
    String? userSession,
    String? roleId,
  }) {
    return api.getTrainSets(
      token: token,
      userSession: userSession,
      roleId: roleId,
    );
  }
}
