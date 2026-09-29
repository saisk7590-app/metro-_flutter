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

      final dynamic resObj = response.containsKey('response') ? response['response'] : response;
      if (resObj is Map<String, dynamic>) {
        final status = resObj['status'] ?? resObj['statusCode'] ?? resObj['success'];
        if (status == 1 || status == '1' || status == 200 || status == true || (status is num && status > 0)) {
          return true;
        }
      } else if (resObj is num && resObj > 0) {
        return true;
      } else if (resObj == true) {
        return true;
      }
      return false;
    } catch (e) {
      error = e.toString();
      debugPrint('saveMaintenanceBay error: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveMaintenanceBayAllocation({
    required int mbaMbId,
    required int mbaDepot,
    required int mbaSlot,
    required int mbaTrainSet,
    required int mbaPurpose,
    required int mbaStatus,
    required String mbaAllocatedOn,
    required String mbaAllocatedBy,
    required String mbaRemarks,
    int? userId,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await repository.saveMaintenanceBayAllocation(
        mbaMbId: mbaMbId,
        mbaDepot: mbaDepot,
        mbaSlot: mbaSlot,
        mbaTrainSet: mbaTrainSet,
        mbaPurpose: mbaPurpose,
        mbaStatus: mbaStatus,
        mbaAllocatedOn: mbaAllocatedOn,
        mbaAllocatedBy: mbaAllocatedBy,
        mbaRemarks: mbaRemarks,
        userId: userId,
      );

      final dynamic resObj = response.containsKey('response') ? response['response'] : response;
      if (resObj is Map<String, dynamic>) {
        final status = resObj['status'] ?? resObj['statusCode'] ?? resObj['success'];
        if (status == 1 || status == '1' || status == 200 || status == true || (status is num && status > 0)) {
          return true;
        }
      } else if (resObj is num && resObj > 0) {
        return true;
      } else if (resObj == true) {
        return true;
      }
      return false;
    } catch (e) {
      error = e.toString();
      debugPrint('saveMaintenanceBayAllocation error: $e');
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
      if (sClean.isNotEmpty &&
          (mClean.startsWith(sClean) ||
              sClean.startsWith(mClean) ||
              mClean.endsWith(sClean) ||
              sClean.endsWith(mClean))) {
        return bay;
      }
    }

    // 3. Fallback for unique single-slot lines (TT, WL, WP)
    if (mUpper.contains('TT')) {
      for (final bay in maintenanceBays) {
        if (bay.slotName.toUpperCase().contains('TT') || bay.slotType.toUpperCase().contains('TT')) {
          return bay;
        }
      }
    }
    if (mUpper.contains('WL')) {
      for (final bay in maintenanceBays) {
        if (bay.slotName.toUpperCase().contains('WL') || bay.slotType.toUpperCase().contains('WL')) {
          return bay;
        }
      }
    }
    if (mUpper.contains('WP')) {
      for (final bay in maintenanceBays) {
        if (bay.slotName.toUpperCase().contains('WP') || bay.slotType.toUpperCase().contains('WP')) {
          return bay;
        }
      }
    }

    // 4. Line and numeric slot match
    final mDigits = RegExp(r'\d+').firstMatch(markerId)?.group(0);
    final mSlot = int.tryParse(mDigits ?? '') ?? 0;
    final mLine = _extractLineCode(markerId);

    if (mSlot > 0 && mLine.isNotEmpty) {
      final mIsOE = mUpper.contains('OE');
      final mIsBE = mUpper.contains('BE');

      for (final bay in maintenanceBays) {
        final bDigits = RegExp(r'\d+').firstMatch(bay.slotName)?.group(0);
        final bSlot = bay.slot > 0 ? bay.slot : (int.tryParse(bDigits ?? '') ?? 0);
        final bLine = bay.slotType.isNotEmpty ? bay.slotType.toUpperCase() : _extractLineCode(bay.slotName);

        if (bSlot == mSlot && bLine == mLine) {
          final bUpper = bay.slotName.toUpperCase();
          if (mIsOE && bUpper.contains('BE')) continue;
          if (mIsBE && bUpper.contains('OE')) continue;
          return bay;
        }
      }
    }

    return null;
  }

  /// Instantly sets or updates a bay allocation locally so CAD maps & tables reflect immediately
  void setOrUpdateBayAllocation({
    required String markerOrSlotName,
    required int depotId,
    required int slot,
    required int trainSetId,
    required String trainSetName,
    required int statusId,
    required String statusName,
    required int purposeId,
    required String purposeName,
    required String inward,
    required String outward,
    required String remark,
    required bool isOutward,
    int id = 0,
  }) {
    final existingIndex = maintenanceBays.indexWhere((b) {
      if (id > 0 && b.id == id) return true;
      final sUpper = b.slotName.toUpperCase();
      final mUpper = markerOrSlotName.toUpperCase();
      if (sUpper.isNotEmpty && sUpper == mUpper) return true;
      if (b.slot == slot && (b.slotType.isNotEmpty && markerOrSlotName.contains(b.slotType))) return true;
      return false;
    });

    final updatedModel = MaintenanceBayModel(
      id: id > 0 ? id : (existingIndex >= 0 ? maintenanceBays[existingIndex].id : 0),
      slot: slot,
      slotName: markerOrSlotName,
      slotType: _extractLineCode(markerOrSlotName),
      trainSetId: trainSetId,
      trainSetName: trainSetName,
      statusId: statusId,
      statusName: statusName,
      purposeId: purposeId,
      purposeName: purposeName,
      inward: inward,
      outward: outward,
      remark: remark,
      isAllocated: trainSetId > 0,
      isOutward: isOutward,
    );

    if (existingIndex >= 0) {
      maintenanceBays[existingIndex] = updatedModel;
    } else {
      maintenanceBays.add(updatedModel);
    }

    notifyListeners();
  }

  static String _extractLineCode(String text) {
    final upper = text.toUpperCase();
    if (upper.contains('SBL')) return 'SBL';
    if (upper.contains('IBL')) return 'IBL';
    if (upper.contains('MAIN')) return 'MAIN';
    if (upper.contains('PW')) return 'PW';
    if (upper.contains('WP')) return 'WP';
    if (upper.contains('WL')) return 'WL';
    if (upper.contains('TT')) return 'TT';
    return '';
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

