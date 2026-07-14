import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Farmer Portal',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: Color(0xFF23312B)),
            onPressed: () {
              context.push('/farmer-notifications');
            },
          ),
        ],
      ),
      body: dashboardState.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : RefreshIndicator(
              color: const Color(0xFF2E7D32),
              onRefresh: () =>
                  ref.read(farmerDashboardProvider.notifier).loadDashboard(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    const SizedBox(height: 16),
                    _buildStatsGrid(dashboardState.dashboard),
                    const SizedBox(height: 16),
                    _buildMonthlyRevenueSection(dashboardState.dashboard),
                    const SizedBox(height: 16),
                    _buildRecentPendingOrders(orderState.pendingOrders),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFAF4EF), width: 2),
            ),
            child: ClipOval(
              child: Image.network(
                'https://api.dicebear.com/7.x/adventurer/svg?seed=FarmerJoe',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Farmer Partner!',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF23312B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Here is your farm performance overview today.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF647C72),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(FarmerDashboardModel dashboard) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.45,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _buildStatCard(
          "Today's Sales",
          '₹${dashboard.todaySales.toStringAsFixed(2)}',
          Icons.currency_rupee,
          const Color(0xFF2E7D32),
          const Color(0xFFE8F5E9),
        ),
        _buildStatCard(
          'Total Revenue',
          '₹${dashboard.totalRevenue.toStringAsFixed(2)}',
          Icons.account_balance_wallet_outlined,
          const Color(0xFFE28C43),
          const Color(0xFFFFF1E6),
        ),
        _buildStatCard(
          'Pending Orders',
          '${dashboard.pendingOrders}',
          Icons.pending_actions,
          const Color(0xFFFFB703),
          const Color(0xFFFFFDF0),
        ),
        _buildStatCard(
          'Active Crops',
          '${dashboard.activeProducts}',
          Icons.spa_outlined,
          const Color(0xFF219EBC),
          const Color(0xFFF0F9FB),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, Color bgColor) {
    return Container(
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
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: const Color(0xFF647C72),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF23312B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyRevenueSection(FarmerDashboardModel dashboard) {
    final monthlyRevenue = dashboard.monthlyRevenue;
    double maxRevenue = 0;
    for (final item in monthlyRevenue) {
      if (item.revenue > maxRevenue) maxRevenue = item.revenue;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart, color: Color(0xFF2E7D32), size: 20),
              const SizedBox(width: 8),
              Text(
                'Monthly Revenue',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF23312B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (monthlyRevenue.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No revenue data available',
                  style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 11),
                ),
              ),
            )
          else
            ...monthlyRevenue.map((item) {
              final fraction =
                  maxRevenue > 0 ? item.revenue / maxRevenue : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text(
                        item.month,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF23312B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: fraction,
                          backgroundColor: const Color(0xFFF1F8F4),
                          color: const Color(0xFF2E7D32),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '₹${item.revenue.toStringAsFixed(0)}',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF23312B),
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildRecentPendingOrders(List<OrderModel> pendingOrders) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long, color: Color(0xFF2E7D32), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Incoming Orders',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF23312B),
                    ),
                  ),
                ],
              ),
              if (pendingOrders.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${pendingOrders.length} New',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFFF4D6D),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (pendingOrders.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No pending orders right now.',
                  style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 11),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pendingOrders.length > 3 ? 3 : pendingOrders.length,
              itemBuilder: (context, index) {
                final order = pendingOrders[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFBF9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5EDE7)),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order.orderNumber.isNotEmpty ? order.orderNumber : order.id.substring(0, 6)}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: const Color(0xFF23312B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${order.items.length} items • ${DateFormat('hh:mm a').format(order.date)}',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF647C72),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '₹${order.total.toStringAsFixed(2)}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, size: 16, color: Color(0xFF647C72)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
