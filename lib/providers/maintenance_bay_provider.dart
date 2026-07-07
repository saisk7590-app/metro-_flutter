import 'package:flutter/material.dart';

import '../models/maintenance_bay_model.dart';
import '../repositories/maintenance_bay_repository.dart';

class MaintenanceBayProvider extends ChangeNotifier {
  final MaintenanceBayRepository repository = MaintenanceBayRepository();

  List<MaintenanceBayModel> maintenanceBays = [];

  bool isLoading = false;
  String error = '';

  Future<void> fetchMaintenanceBay(int depotId) async {
    try {
      isLoading = true;
      error = '';

      notifyListeners();

      maintenanceBays = await repository.getMaintenanceBay(depotId);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveMaintenanceBay({
    required int mbId,
    required int mbDepot,
    required int mbSlot,
    required int mbTrainSet,
    required int mbStatus,
    required int mbPurpose,
    required String mbInward,
    required String mbOutward,
    required String mbRemark,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await repository.saveMaintenanceBay(
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

      return response['status'] == 1;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
