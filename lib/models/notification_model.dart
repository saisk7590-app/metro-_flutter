class NotificationModel {
  final int id;
  final String message;
  final DateTime? date;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.message,
    this.date,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    final rawDate = json['date'] ?? json['nt_date'] ?? json['Date'] ?? json['createdDate'];
    if (rawDate != null) {
      if (rawDate is DateTime) {
        parsedDate = rawDate;
      } else {
        parsedDate = DateTime.tryParse(rawDate.toString());
      }
    }

    final rawId = json['id'] ?? json['nt_id'] ?? json['Id'] ?? json['notificationId'] ?? 0;
    final int id = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

    final rawMessage = json['message'] ?? json['nt_message'] ?? json['Message'] ?? json['msg'] ?? '';

    final rawIsRead = json['isRead'] ?? json['is_read'] ?? json['IsRead'] ?? false;
    final bool isRead = rawIsRead is bool
        ? rawIsRead
        : (rawIsRead.toString() == '1' || rawIsRead.toString().toLowerCase() == 'true');

    return NotificationModel(
      id: id,
      message: rawMessage.toString(),
      date: parsedDate,
      isRead: isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'date': date?.toIso8601String(),
      'isRead': isRead,
    };
  }

  NotificationModel copyWith({
    int? id,
    String? message,
    DateTime? date,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      message: message ?? this.message,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
    );
  }
}
