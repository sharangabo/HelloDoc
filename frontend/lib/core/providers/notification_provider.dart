import 'package:flutter/foundation.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String type;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    required this.isRead,
    this.data,
  });
}

class NotificationProvider extends ChangeNotifier {
  List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      _notifications = [
        NotificationItem(
          id: '1',
          title: 'Appointment Confirmed',
          message: 'Your appointment with Dr. Jean Pierre has been confirmed for tomorrow at 2:00 PM.',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          type: 'appointment',
          isRead: false,
        ),
        NotificationItem(
          id: '2',
          title: 'New Facility Available',
          message: 'A new healthcare facility has opened near your location.',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          type: 'facility',
          isRead: true,
        ),
      ];
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final notification = _notifications[index];
        _notifications[index] = NotificationItem(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          timestamp: notification.timestamp,
          type: notification.type,
          isRead: true,
          data: notification.data,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      _notifications = _notifications.map((notification) => NotificationItem(
        id: notification.id,
        title: notification.title,
        message: notification.message,
        timestamp: notification.timestamp,
        type: notification.type,
        isRead: true,
        data: notification.data,
      )).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addNotification({
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = NotificationItem(
        id: 'notification_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        message: message,
        timestamp: DateTime.now(),
        type: type,
        isRead: false,
        data: data,
      );
      
      _notifications.insert(0, notification);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
} 