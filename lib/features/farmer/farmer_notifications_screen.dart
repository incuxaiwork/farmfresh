import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/notification_model.dart';
import '../../providers/farmer_provider.dart';

class FarmerNotificationsScreen extends ConsumerStatefulWidget {
  const FarmerNotificationsScreen({super.key});

  @override
  ConsumerState<FarmerNotificationsScreen> createState() =>
      _FarmerNotificationsScreenState();
}

class _FarmerNotificationsScreenState
    extends ConsumerState<FarmerNotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(farmerNotificationProvider.notifier).loadMore();
    }
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  IconData _iconForType(String type) {
    switch (type.toUpperCase()) {
      case 'ORDER':
        return Icons.shopping_bag_outlined;
      case 'PRODUCT':
        return Icons.inventory_2_outlined;
      case 'STOCK':
        return Icons.warning_amber_outlined;
      case 'WITHDRAWAL':
        return Icons.account_balance_outlined;
      case 'PROMOTION':
        return Icons.campaign_outlined;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  Color _colorForType(String type) {
    switch (type.toUpperCase()) {
      case 'ORDER':
        return const Color(0xFF219EBC);
      case 'PRODUCT':
        return const Color(0xFF2E7D32);
      case 'STOCK':
        return const Color(0xFFE28C43);
      case 'WITHDRAWAL':
        return const Color(0xFF8338EC);
      case 'PROMOTION':
        return const Color(0xFFFF4D6D);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  void _onNotificationTap(AppNotificationModel notification) {
    if (!notification.isRead) {
      ref.read(farmerNotificationProvider.notifier).markRead(notification.id);
    }

    final type = notification.type.toUpperCase();
    final data = notification.data;

    switch (type) {
      case 'ORDER':
        final orderId = data?['orderId'] as String? ?? data?['order_id'];
        if (orderId != null && mounted) {
          context.push('/farmer-orders');
        }
        break;
      case 'PRODUCT':
        context.push('/farmer-products');
        break;
      case 'STOCK':
        context.push('/farmer-inventory');
        break;
      case 'WITHDRAWAL':
        context.push('/farmer-withdrawal');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(farmerNotificationProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF2F8F4),
            Color(0xFFE6F2EA),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Notifications',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: Color(0xFF23312B)),
            onPressed: () => context.pop(),
          ),
          actions: [
            if (state.unreadCount > 0)
              TextButton(
                onPressed: () {
                  ref
                      .read(farmerNotificationProvider.notifier)
                      .markAllRead();
                },
                child: Text(
                  'Mark All Read',
                  style: GoogleFonts.plusJakartaSans(color: const Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
          ],
        ),
        body: state.isLoading && state.notifications.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
              )
            : state.notifications.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFEAF6EC),
                            ),
                            child: const Icon(
                              Icons.notifications_none_outlined,
                              size: 28,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications yet',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF23312B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'We will alert you on updates regarding your orders, crops, and payouts.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 11, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    color: const Color(0xFF2E7D32),
                    onRefresh: () async {
                      await ref
                          .read(farmerNotificationProvider.notifier)
                          .loadNotifications();
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: state.notifications.length +
                          (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.notifications.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF2E7D32),
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        }

                        final notification = state.notifications[index];
                        return _NotificationCard(
                          notification: notification,
                          timeAgo: _timeAgo(notification.createdAt),
                          icon: _iconForType(notification.type),
                          iconColor: _colorForType(notification.type),
                          onTap: () => _onNotificationTap(notification),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotificationModel notification;
  final String timeAgo;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.timeAgo,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
        border: notification.isRead
            ? null
            : Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: notification.isRead ? FontWeight.bold : FontWeight.w800,
                                fontSize: 13,
                                color: const Color(0xFF23312B),
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E7D32),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notification.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF647C72),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeAgo,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF8D99AE),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF647C72),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
