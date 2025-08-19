import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await ApiService.getNotifications();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await ApiService.markNotificationAsRead(notificationId);
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await ApiService.markAllNotificationsAsRead();
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }
}
