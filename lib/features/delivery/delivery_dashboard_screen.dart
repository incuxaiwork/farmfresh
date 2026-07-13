import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/delivery_provider.dart';
import '../../models/delivery_model.dart';

class DeliveryDashboardScreen extends ConsumerStatefulWidget {
  const DeliveryDashboardScreen({super.key});

  @override
  ConsumerState<DeliveryDashboardScreen> createState() => _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState extends ConsumerState<DeliveryDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(deliveryDashboardProvider.notifier).loadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(deliveryDashboardProvider);
    final ordersState = ref.watch(deliveryOrdersProvider);
    final profileState = ref.watch(deliveryProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          Row(
            children: [
              Text(
                profileState.profile.isAvailable ? 'Online' : 'Offline',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: profileState.profile.isAvailable,
                activeColor: Colors.lightGreenAccent,
                inactiveThumbColor: Colors.grey[400],
                inactiveTrackColor: Colors.grey[700],
                onChanged: (val) async {
                  await ref.read(deliveryProfileProvider.notifier).toggleAvailability();
                },
              ),
            ],
          ),
          const SizedBox(width: 8),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push('/delivery-notifications'),
              ),
              if (dashboardState.dashboard.unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${dashboardState.dashboard.unreadNotifications}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(deliveryDashboardProvider.notifier).loadDashboard();
          await ref.read(deliveryOrdersProvider.notifier).loadDeliveries();
        },
        child: dashboardState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : dashboardState.errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(dashboardState.errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.read(deliveryDashboardProvider.notifier).loadDashboard(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsGrid(dashboardState),
                        const SizedBox(height: 20),
                        _buildEarningsSummary(dashboardState),
                        const SizedBox(height: 20),
                        _buildActiveDeliveries(ordersState),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildStatsGrid(DeliveryDashboardState state) {
    final stats = state.stats;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Today\'s Earnings', '₹${stats.todayEarnings.toStringAsFixed(0)}', Icons.attach_money, Colors.green),
        _buildStatCard('Weekly Earnings', '₹${stats.weeklyEarnings.toStringAsFixed(0)}', Icons.calendar_view_week, Colors.blue),
        _buildStatCard('Completed Today', '${stats.completedToday}', Icons.check_circle, Colors.teal),
        _buildStatCard('Active', '${stats.activeDeliveries}', Icons.local_shipping, Colors.orange),
        _buildStatCard('Pending', '${stats.pendingDeliveries}', Icons.pending, Colors.amber),
        _buildStatCard('Rating', stats.averageRating.toStringAsFixed(1), Icons.star, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const Spacer(),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsSummary(DeliveryDashboardState state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Earnings Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            if (state.dashboard.recentEarnings.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('No earnings data yet', style: TextStyle(color: Colors.grey)),
              )
            else
              ...state.dashboard.recentEarnings.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.period, style: const TextStyle(fontSize: 14)),
                        Text('₹${e.amount.toStringAsFixed(0)} (${e.deliveries} deliveries)',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => context.push('/delivery-earnings'),
                child: const Text('View All Earnings'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveDeliveries(DeliveryOrdersState ordersState) {
    final allActive = [...ordersState.pendingDeliveries, ...ordersState.activeDeliveries];
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Active Deliveries', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${allActive.length}', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const Divider(),
            if (ordersState.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (allActive.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text('No active deliveries', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...allActive.take(5).map((delivery) => _buildDeliveryTile(delivery)),
            if (allActive.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      // Navigate to deliveries tab
                      final mainState = context.findAncestorStateOfType<State>();
                      if (mainState != null && mainState.mounted) {
                        // Use a callback or state management to switch tabs
                      }
                    },
                    child: const Text('View All'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryTile(DeliveryOrder delivery) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(delivery.status).withOpacity(0.1),
        child: Icon(_getStatusIcon(delivery.status), color: _getStatusColor(delivery.status)),
      ),
      title: Text(
        'Order #${delivery.orderId}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        _getStatusText(delivery.status),
        style: TextStyle(color: _getStatusColor(delivery.status), fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/delivery-detail', extra: delivery.id),
    );
  }

  Color _getStatusColor(DeliveryOrderStatus status) {
    switch (status) {
      case DeliveryOrderStatus.pending:
        return Colors.orange;
      case DeliveryOrderStatus.accepted:
        return Colors.blue;
      case DeliveryOrderStatus.pickedUp:
        return Colors.teal;
      case DeliveryOrderStatus.outForDelivery:
        return Colors.purple;
      case DeliveryOrderStatus.delivered:
        return Colors.green;
      case DeliveryOrderStatus.cancelled:
        return Colors.red;
      case DeliveryOrderStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(DeliveryOrderStatus status) {
    switch (status) {
      case DeliveryOrderStatus.pending:
        return Icons.pending;
      case DeliveryOrderStatus.accepted:
        return Icons.check;
      case DeliveryOrderStatus.pickedUp:
        return Icons.inventory;
      case DeliveryOrderStatus.outForDelivery:
        return Icons.local_shipping;
      case DeliveryOrderStatus.delivered:
        return Icons.check_circle;
      case DeliveryOrderStatus.cancelled:
        return Icons.cancel;
      case DeliveryOrderStatus.rejected:
        return Icons.cancel;
    }
  }

  String _getStatusText(DeliveryOrderStatus status) {
    switch (status) {
      case DeliveryOrderStatus.pending:
        return 'Awaiting acceptance';
      case DeliveryOrderStatus.accepted:
        return 'Ready to pick up';
      case DeliveryOrderStatus.pickedUp:
        return 'Picked up from farmer';
      case DeliveryOrderStatus.outForDelivery:
        return 'On the way to customer';
      case DeliveryOrderStatus.delivered:
        return 'Delivered';
      case DeliveryOrderStatus.cancelled:
        return 'Cancelled';
      case DeliveryOrderStatus.rejected:
        return 'Rejected';
    }
  }
}
