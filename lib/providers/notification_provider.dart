import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _apiService;

  NotificationProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchNotifications({
    String? unitId,
    String? roleId,
    String? userId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _apiService.getNotifications(
        unitId: unitId,
        roleId: roleId,
      );

      _notifications = results;
      if (userId != null && userId.isNotEmpty && userId != '0') {
        _unreadCount = await _apiService.getNotificationsCount(userId: userId);
      } else {
        _unreadCount = _notifications.where((n) => !n.isRead).length;
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Notification fetch handled: $e');
      _notifications = [];
      _unreadCount = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnreadCount({String? userId}) async {
    if (userId == null || userId.isEmpty || userId == '0') return;
    try {
      final count = await _apiService.getNotificationsCount(userId: userId);
      if (count > 0) {
        _unreadCount = count;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Notification count handled: $e');
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _apiService.updateNotificationReadStatus(
        messageRecipientId: notificationId,
      );
    } catch (e) {
      debugPrint('Notification markAsRead handled: $e');
    } finally {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        if (_unreadCount > 0) _unreadCount--;
        notifyListeners();
      }
    }
  }

  void markAllAsReadLocally() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _unreadCount = 0;
    notifyListeners();
  }
}
