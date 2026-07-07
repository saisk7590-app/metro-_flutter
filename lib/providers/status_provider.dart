import 'package:flutter/material.dart';

import '../models/status_model.dart';
import '../repositories/status_repository.dart';

class StatusProvider extends ChangeNotifier {
  final StatusRepository repository = StatusRepository();

  List<StatusModel> statuses = [];

  bool isLoading = false;
  String error = '';

  Future<void> fetchStatuses() async {
    try {
      isLoading = true;
      error = '';

      notifyListeners();

      statuses = await repository.getStatuses();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
