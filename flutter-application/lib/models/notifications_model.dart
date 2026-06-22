class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final String type;
  final String category;
  final String severity;
  final String status;
  final String actionType;
  final String? relatedId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.type,
    required this.category,
    required this.severity,
    required this.status,
    required this.actionType,
    this.relatedId,
  });

  factory NotificationModel.fromJson(dynamic json) {
    final map = Map<String, dynamic>.from(json as Map);

    return NotificationModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      time: map['timeAgo']?.toString() ?? '',
      isRead: map['isRead'] == true,
      type: map['type']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      severity: map['severity']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      actionType: map['actionType']?.toString() ?? 'none',
      relatedId: map['relatedId']?.toString(),
    );
  }
}