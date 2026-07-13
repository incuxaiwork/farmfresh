import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/delivery_provider.dart';
import '../../models/notification_model.dart';

class DeliveryNotificationsScreen extends ConsumerStatefulWidget {
  const DeliveryNotificationsScreen({super.key});

  @override
  ConsumerState<DeliveryNotificationsScreen> createState() => _DeliveryNotificationsScreenState();
}

class _DeliveryNotificationsScreenState extends ConsumerState<DeliveryNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(deliveryNotificationProvider.notifier).loadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(deliveryNotificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (notifState.unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(deliveryNotificationProvider.notifier).markAllRead(),
              child: const Text('Mark All Read', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: notifState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(deliveryNotificationProvider.notifier).loadNotifications(),
              child: notifState.notifications.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No notifications', style: TextStyle(color: Colors.grey, fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: notifState.notifications.length,
                      itemBuilder: (context, index) {
                        final notif = notifState.notifications[index];
                        return _buildNotificationTile(notif);
                      },
                    ),
            ),
    );
  }

  Widget _buildNotificationTile(AppNotificationModel notif) {
    String dateStr = '';
    try {
      dateStr = DateFormat('dd/MM • HH:mm').format(notif.createdAt);
    } catch (_) {
      dateStr = notif.createdAt.toString();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: notif.isRead ? 0 : 1,
      color: notif.isRead ? null : Colors.green.withOpacity(0.03),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notif.isRead ? Colors.grey[200] : Colors.green.withOpacity(0.1),
          child: Icon(
            _getNotificationIcon(notif.type),
            color: notif.isRead ? Colors.grey : Colors.green,
            size: 20,
          ),
        ),
        title: Text(
          notif.title,
          style: TextStyle(
            fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(notif.body, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(dateStr, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          if (!notif.isRead) {
            ref.read(deliveryNotificationProvider.notifier).markRead(notif.id);
          }
        },
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'order_assigned':
        return Icons.assignment;
      case 'order_accepted':
        return Icons.check_circle;
      case 'order_delivered':
        return Icons.flag;
      case 'payment':
        return Icons.attach_money;
      case 'rating':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }
}
