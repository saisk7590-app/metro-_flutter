import 'package:flutter/material.dart';

import '../models/train_model.dart';
import '../repositories/train_repository.dart';

class TrainProvider extends ChangeNotifier {
  final TrainRepository repository = TrainRepository();

  List<TrainModel> trainSets = [];

  bool isLoading = false;
  String error = '';

  Future<void> fetchTrainSets() async {
    try {
      isLoading = true;
      error = '';

      notifyListeners();

      trainSets = await repository.getTrainSets();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
