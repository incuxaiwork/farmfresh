import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/farmer_provider.dart';
import '../../models/farmer_dashboard_model.dart';
import '../../models/order_model.dart';

class FarmerDashboardScreen extends ConsumerStatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  ConsumerState<FarmerDashboardScreen> createState() =>
      _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends ConsumerState<FarmerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(farmerDashboardProvider.notifier).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(farmerDashboardProvider);
    final orderState = ref.watch(farmerOrderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Dashboard'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: dashboardState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(farmerDashboardProvider.notifier).loadDashboard(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    const SizedBox(height: 20),
                    _buildStatsGrid(dashboardState.dashboard),
                    const SizedBox(height: 20),
                    _buildMonthlyRevenueSection(dashboardState.dashboard),
                    const SizedBox(height: 20),
                    _buildWeeklyOrdersSection(dashboardState.dashboard),
                    const SizedBox(height: 20),
                    _buildRecentPendingOrders(orderState.pendingOrders),
                    const SizedBox(height: 20),
                    _buildNotificationSummary(dashboardState.dashboard),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.agriculture,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, Farmer Partner!',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Here is your farm performance overview today.',
                    style: TextStyle(fontSize: 13, color: Colors.green[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(FarmerDashboardModel dashboard) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildStatCard(
          "Today's Sales",
          '₹${dashboard.todaySales.toStringAsFixed(2)}',
          Icons.attach_money,
          Colors.green,
        ),
        _buildStatCard(
          'Total Revenue',
          '₹${dashboard.totalRevenue.toStringAsFixed(2)}',
          Icons.account_balance,
          Colors.blue,
        ),
        _buildStatCard(
          'Pending Orders',
          '${dashboard.pendingOrders}',
          Icons.pending_actions,
          Colors.orange,
        ),
        _buildStatCard(
          'Active Products',
          '${dashboard.activeProducts}',
          Icons.agriculture,
          Colors.teal,
        ),
        _buildStatCard(
          'Delivered Orders',
          '${dashboard.deliveredOrders}',
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Out of Stock',
          '${dashboard.outOfStockProducts}',
          Icons.warning_amber_rounded,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyRevenueSection(FarmerDashboardModel dashboard) {
    final monthlyRevenue = dashboard.monthlyRevenue;
    double maxRevenue = 0;
    for (final item in monthlyRevenue) {
      if (item.revenue > maxRevenue) maxRevenue = item.revenue;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text('Monthly Revenue',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            if (monthlyRevenue.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No revenue data available',
                      style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...monthlyRevenue.map((item) {
                final fraction =
                    maxRevenue > 0 ? item.revenue / maxRevenue : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: Text(item.month,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: MediaQuery.of(context).size.width *
                                  0.35 *
                                  fraction,
                              constraints: const BoxConstraints(minWidth: 4),
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 70,
                        child: Text(
                          '₹${item.revenue.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyOrdersSection(FarmerDashboardModel dashboard) {
    final weeklyOrders = dashboard.weeklyOrders;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text('Weekly Orders',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            if (weeklyOrders.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No orders data available',
                      style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...weeklyOrders.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.day, style: const TextStyle(fontSize: 13)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Text(
                            '${item.count} orders',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[800]),
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPendingOrders(List<OrderModel> pendingOrders) {
    final recent = pendingOrders.take(3).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.orange[700]),
                const SizedBox(width: 8),
                const Text('Recent Pending Orders',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (recent.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No pending orders',
                      style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...recent.map((order) {
                final orderDisplay = order.orderNumber.isNotEmpty
                    ? order.orderNumber
                    : order.id.substring(0, 8);
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order #$orderDisplay',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text('${order.items.length} items',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹${order.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(DateFormat('dd/MM').format(order.date),
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[500])),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSummary(FarmerDashboardModel dashboard) {
    final unreadCount = dashboard.unreadNotifications;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: unreadCount > 0 ? Colors.red[50] : Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: unreadCount > 0 ? Colors.red : Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                unreadCount > 0
                    ? Icons.notifications_active
                    : Icons.notifications_none,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Notifications',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(
                    unreadCount > 0
                        ? 'You have $unreadCount unread notification${unreadCount > 1 ? 's' : ''}'
                        : "You're all caught up!",
                    style: TextStyle(
                      fontSize: 13,
                      color: unreadCount > 0
                          ? Colors.red[700]
                          : Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
            if (unreadCount > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text('$unreadCount',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
          ],
        ),
      ),
    );
  }
}
