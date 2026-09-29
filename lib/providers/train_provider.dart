import 'package:flutter/material.dart';

import '../models/train_model.dart';
import '../repositories/train_repository.dart';

class TrainProvider extends ChangeNotifier {
  final TrainRepository repository = TrainRepository();

  List<TrainModel> trainSets = [];

  bool isLoading = false;
  String error = '';

  Future<void> fetchTrainSets({
    String? token,
    String? userSession,
    String? roleId,
  }) async {
    try {
      isLoading = true;
      error = '';

      notifyListeners();

      trainSets = await repository.getTrainSets(
        token: token,
        userSession: userSession,
        roleId: roleId,
      );
    } catch (e) {
      debugPrint('Error fetching trainsets: $e');
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
