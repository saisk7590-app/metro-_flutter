import 'package:flutter/material.dart';

class TrainAssignment {
  final String depotName;
  final String sectionName;
  final String trackNumber;
  final String trackId;

  final String trainNo;
  final String maintenancePurpose;
  final String status;
  final String remarks;

  TrainAssignment({
    required this.depotName,
    required this.sectionName,
    required this.trackNumber,
    required this.trackId,
    required this.trainNo,
    required this.maintenancePurpose,
    required this.status,
    this.remarks = '',
  });

  Color get statusColor {
    switch (status) {
      case 'Running':
        return Colors.green;
      case 'Maintenance':
        return Colors.orange;
      case 'Failure':
        return Colors.red;
      case 'Idle':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class ActiveTrainsProvider extends ChangeNotifier {
  // Map of trackId -> TrainAssignment
  final Map<String, TrainAssignment> _activeTrains = {};

  Map<String, TrainAssignment> get activeTrains => _activeTrains;

  void assignTrain(TrainAssignment assignment) {
    _activeTrains[assignment.trackId] = assignment;
    notifyListeners();
  }

  void removeTrain(String trackId) {
    if (_activeTrains.containsKey(trackId)) {
      _activeTrains.remove(trackId);
      notifyListeners();
    }
  }

  TrainAssignment? getTrainAtSlot(String trackId) {
    return _activeTrains[trackId];
  }

  int getOccupiedCount(String depotName, String sectionName) {
    return _activeTrains.values
        .where((t) => t.depotName == depotName && t.sectionName == sectionName)
        .length;
  }
}
