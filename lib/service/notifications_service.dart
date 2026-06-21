import 'package:gardproject/Api/api_client.dart';
import 'package:gardproject/models/notifications_model.dart';

class NotificationsService {
  Future<List<NotificationModel>> getNotifications() async {
    final response = await ApiClient.get(
      '/api/notifications',
      queryParameters: {
        'status': 'active',
      },
      requiresAuth: true,
    );

    print("NOTIFICATIONS RESPONSE = $response");

    final container = response['message'] ?? response['data'];

    final List items = container is Map<String, dynamic>
        ? List.from(container['items'] ?? [])
        : [];

    print("NOTIFICATIONS ITEMS LENGTH = ${items.length}");

    return items
        .map((item) => NotificationModel.fromJson(item))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final response = await ApiClient.get(
      '/api/notifications/unread-count',
      requiresAuth: true,
    );

    final container = response['message'] ?? response['data'];

    if (container is Map<String, dynamic>) {
      return container['unreadCount'] ?? 0;
    }

    return 0;
  }

  Future<void> markAsRead(String id) async {
    await ApiClient.patch(
      '/api/notifications/$id/read',
      requiresAuth: true,
    );
  }

  Future<void> markAllAsRead() async {
    await ApiClient.patch(
      '/api/notifications/read-all',
      requiresAuth: true,
    );
  }

  Future<void> resolveNotification(String id) async {
    await ApiClient.patch(
      '/api/notifications/$id/resolve',
      requiresAuth: true,
    );
  }

  Future<void> deleteNotification(String id) async {
    await ApiClient.delete(
      '/api/notifications/$id',
      requiresAuth: true,
    );
  }
}