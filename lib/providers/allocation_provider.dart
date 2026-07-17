import 'package:flutter/material.dart';
import '../models/allocation.dart';

class AllocationProvider extends ChangeNotifier {
  // Current allocation shown on Dashboard
  final Map<String, Allocation> _currentAllocations = {};

  // Complete history for each bay
  final Map<String, List<Allocation>> _history = {};

  /// Current allocation of a bay
  Allocation? getAllocation(String trackId) {
    return _currentAllocations[trackId];
  }

  /// History of a bay
  List<Allocation> getHistory(String trackId) {
    return _history[trackId] ?? [];
  }

  /// Save allocation
  void allocate(Allocation allocation) {
    // Update current allocation
    _currentAllocations[allocation.trackId] = allocation;

    // Add to history
    _history.putIfAbsent(allocation.trackId, () => []);
    _history[allocation.trackId]!.insert(0, allocation);

    notifyListeners();
  }

  /// Clear current allocation only
  void clearAllocation(String trackId) {
    _currentAllocations.remove(trackId);
    notifyListeners();
  }

  /// Optional: Clear history also
  void clearHistory(String trackId) {
    _history.remove(trackId);
    notifyListeners();
  }
}
