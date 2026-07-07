import '../models/train_model.dart';
import '../services/api_service.dart';

class TrainRepository {
  final ApiService api = ApiService();

  Future<List<TrainModel>> getTrainSets() {
    return api.getTrainSets();
  }
}
