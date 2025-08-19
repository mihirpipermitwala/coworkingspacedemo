import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/notification_provider.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, np, _) {
              final hasUnread = np.unreadCount > 0;
              return TextButton(
                onPressed: hasUnread ? () => np.markAllAsRead() : null,
                child: const Text(
                  'Mark all read',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, np, _) {
          if (np.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (np.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    'Error: ${np.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => np.loadNotifications(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (np.notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => np.loadNotifications(),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'No notifications yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => np.loadNotifications(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: np.notifications.length,
              itemBuilder: (context, index) {
                final n = np.notifications[index];
                return Dismissible(
                  key: ValueKey(n.id),
                  direction: n.isRead
                      ? DismissDirection.none
                      : DismissDirection.startToEnd,
                  onDismissed: (_) {
                    if (!n.isRead) {
                      np.markAsRead(n.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Marked as read')),
                      );
                    }
                  },
                  background: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Row(
                      children: [
                        Icon(Icons.mark_email_read, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Mark as read',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                  child: _NotificationTile(
                    notification: n,
                    onMarkRead:
                        n.isRead ? null : () => np.markAsRead(n.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onMarkRead;

  const _NotificationTile({
    required this.notification,
    this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final timeText = DateFormat('MMM d, h:mm a').format(notification.timestamp);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Stack(
          alignment: Alignment.topRight,
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFE3F2FD),
              child: Icon(Icons.notifications, color: Color(0xFF2196F3)),
            ),
            if (isUnread)
              const Positioned(
                right: 0,
                top: 0,
                child: Icon(Icons.circle, size: 10, color: Colors.redAccent),
              ),
          ],
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message),
            const SizedBox(height: 6),
            Text(
              timeText,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        trailing: isUnread
            ? TextButton(
                onPressed: onMarkRead,
                child: const Text('Mark read'),
              )
            : null,
        onTap: onMarkRead,
      ),
    );
  }
}