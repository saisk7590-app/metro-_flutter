import 'package:flutter/material.dart';

import '../models/maintenance_purpose_model.dart';
import '../repositories/maintenance_purpose_repository.dart';

class MaintenancePurposeProvider extends ChangeNotifier {
  final MaintenancePurposeRepository repository =
      MaintenancePurposeRepository();

  List<MaintenancePurposeModel> purposes = [];

  bool isLoading = false;
  String error = '';

  Future<void> fetchMaintenancePurposes() async {
    try {
      isLoading = true;
      error = '';

      notifyListeners();

      purposes = await repository.getMaintenancePurposes();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
