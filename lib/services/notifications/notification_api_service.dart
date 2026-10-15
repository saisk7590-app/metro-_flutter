import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../models/notifications/notification_model.dart';
import '../base_api_service.dart';

/// Service handling push notifications, messaging, and read status.
class NotificationApiService extends BaseApiService {
  /// Fetch notifications list
  Future<List<NotificationModel>> getNotifications({
    String? unitId,
    String? roleId,
  }) async {
    try {
      final response = await postJson(
        '/messaging/get-notifications',
        base: BaseApiService.messagingBase,
        body: {
          'Params': [
            {'key': 'UnitId', 'value': unitId ?? '0'},
            {'key': 'RoleId', 'value': roleId ?? BaseApiService.currentRoleId ?? '0'},
          ],
        },
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
    } catch (e) {
      if (kIsWeb) {
        debugPrint('[Notifications] Messaging API unavailable on Web (CORS/OPTIONS): ${e.toString().split('\n').first}');
      } else {
        debugPrint('[Notifications] getNotifications error: ${e.toString().split('\n').first}');
      }
    }
    return [];
  }

  /// Get unread notification count
  Future<int> getNotificationsCount({String? userId}) async {
    try {
      final response = await postJson(
        '/messaging/get-notifications-count',
        base: BaseApiService.messagingBase,
        body: {
          'Params': [
            {'key': 'UserId', 'value': userId ?? ''},
          ],
        },
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final status = decoded['status'] ?? decoded['Status'];
          if (status != null) {
            return int.tryParse(status.toString()) ?? 0;
          }
        } else if (decoded is int) {
          return decoded;
        }
      }
    } catch (e) {
      if (kIsWeb) {
        debugPrint('[Notifications] getNotificationsCount unavailable on Web (CORS/OPTIONS): ${e.toString().split('\n').first}');
      } else {
        debugPrint('[Notifications] getNotificationsCount error: ${e.toString().split('\n').first}');
      }
    }
    return 0;
  }

  /// Mark notification as read
  Future<bool> updateNotificationReadStatus({required int messageRecipientId}) async {
    try {
      final response = await postJson(
        '/messaging/update-read-status',
        base: BaseApiService.messagingBase,
        body: {
          'Params': [
            {'key': 'MsgReceipentId', 'value': messageRecipientId.toString()},
          ],
        },
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded['status'] == 1 || decoded['status'] == true;
        }
        return true;
      }
    } catch (e) {
      debugPrint('[Notifications] updateNotificationReadStatus API error: $e');
    }
    return false;
  }
}
