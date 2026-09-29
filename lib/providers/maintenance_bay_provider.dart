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

  Future<MaintenanceBayModel?> getMaintenanceBayById(int mbId) async {
    try {
      final data = await repository.getMaintenanceBayById(mbId);
      final raw = data['maintenanceBay'] ?? data['data'] ?? data;
      if (raw is Map<String, dynamic>) {
        return MaintenanceBayModel.fromJson(raw);
      }
    } catch (e) {
      debugPrint('Error fetching maintenance bay by ID: $e');
    }
    return null;
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
    bool isOutward = false,
    int? userId,
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
        isOutward: isOutward,
        userId: userId,
      );

      final status = response['status'] ?? response['statusCode'] ?? response['success'];
      return status == 1 || status == '1' || status == 200 || status == true;
    } catch (e) {
      error = e.toString();
      debugPrint('saveMaintenanceBay error: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Finds the matching MaintenanceBayModel for a given track/marker ID (e.g. UPLIBL1BE, MPSBL1BE, UPLTT1)
  MaintenanceBayModel? findBayForMarker(String markerId) {
    if (maintenanceBays.isEmpty) return null;
    final mUpper = markerId.toUpperCase();
    final mClean = mUpper.replaceAll(RegExp(r'[^A-Z0-9]'), '');

    // 1. Exact match on slotName or buttonId
    for (final bay in maintenanceBays) {
      final sUpper = bay.slotName.toUpperCase();
      final sClean = sUpper.replaceAll(RegExp(r'[^A-Z0-9]'), '');
      if (sUpper == mUpper || (sClean.isNotEmpty && sClean == mClean)) {
        return bay;
      }
    }

    // 2. Suffix or prefix match
    for (final bay in maintenanceBays) {
      final sClean = bay.slotName.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
      if (sClean.isNotEmpty && (mClean.endsWith(sClean) || sClean.endsWith(mClean))) {
        return bay;
      }
    }

    // 3. Fallback for unique single-slot lines (TT, WL, WP)
    if (mUpper.contains('TT')) {
      for (final bay in maintenanceBays) {
        if (bay.slotName.toUpperCase().contains('TT')) return bay;
      }
    }
    if (mUpper.contains('WL')) {
      for (final bay in maintenanceBays) {
        if (bay.slotName.toUpperCase().contains('WL')) return bay;
      }
    }
    if (mUpper.contains('WP')) {
      for (final bay in maintenanceBays) {
        if (bay.slotName.toUpperCase().contains('WP')) return bay;
      }
    }

    return null;
  }

  /// Calculates dynamically the occupied train count for a given section
  int getOccupiedCount(String depot, String section) {
    if (maintenanceBays.isEmpty) return 0;
    int count = 0;
    final secUpper = section.toUpperCase();

    for (final bay in maintenanceBays) {
      if (bay.isAllocated) {
        final slotUpper = bay.slotName.toUpperCase();
        bool matches = false;
        if (secUpper == 'SBL' && slotUpper.contains('SBL')) {
          matches = true;
        } else if (secUpper == 'IBL' && slotUpper.contains('IBL')) {
          matches = true;
        } else if (secUpper == 'MAIN' && slotUpper.contains('MAIN')) {
          matches = true;
        } else if (secUpper == 'PW' && slotUpper.contains('PW')) {
          matches = true;
        } else if (secUpper == 'WP' && slotUpper.contains('WP')) {
          matches = true;
        } else if (secUpper == 'WL' && slotUpper.contains('WL')) {
          matches = true;
        } else if (secUpper == 'TT' && slotUpper.contains('TT')) {
          matches = true;
        }
        if (matches) count++;
      }
    }
    return count;
  }
}

