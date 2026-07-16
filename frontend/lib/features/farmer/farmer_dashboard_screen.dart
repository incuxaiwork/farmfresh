import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../providers/farmer_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/farmer_dashboard_model.dart';
import '../../models/order_model.dart';
import '../../core/utils/helpers.dart';

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
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: Colors.transparent, // Inherits #F4F7F2 from main_screen
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Good morning,',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF6B756A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      user?.name ?? 'Farmer',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E241D),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => context.push('/farmer-notifications'),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: dashboardState.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : RefreshIndicator(
              color: const Color(0xFF2E7D32),
              onRefresh: () =>
                  ref.read(farmerDashboardProvider.notifier).loadDashboard(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroCard(dashboardState.dashboard),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildPendingOrders(orderState.pendingOrders),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeroCard(FarmerDashboardModel dashboard) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332E7D32),
            offset: Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Earnings",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFFEAF3E4),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${dashboard.todaySales.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildHeroStat('Total Revenue', '₹${dashboard.totalRevenue.toStringAsFixed(0)}'),
              const SizedBox(width: 32),
              _buildHeroStat('Pending', '${dashboard.pendingOrders} Orders'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: const Color(0xFFEAF3E4).withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E241D),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Add Crop',
                Icons.add_circle_outline,
                const Color(0xFFEAF3E4),
                const Color(0xFF2E7D32),
                () => context.push('/farmer-add-product'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                'Manage Orders',
                Icons.receipt_long_outlined,
                const Color(0xFFFBF0E2),
                const Color(0xFFB8722E),
                () {
                  debugPrint('Manage Orders tapped! Updating tab index to 2.');
                  ref.read(farmerTabIndexProvider.notifier).state = 2;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String label, IconData icon, Color bg, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE4EAE0)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E241D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingOrders(List<OrderModel> pendingOrders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pending Orders',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E241D),
              ),
            ),
            Text(
              'See All',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E7D32),
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
                'No pending orders.',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF6B756A),
                  fontSize: 13,
                ),
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
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE4EAE0)),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3E4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF2E7D32), size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.items.isNotEmpty ? order.items.first.product.name : 'Unknown Product',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E241D),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Order #${order.orderNumber.isNotEmpty ? order.orderNumber : order.id.substring(0, 6)} • ${order.items.length} items',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: const Color(0xFF6B756A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        ref.read(farmerOrderProvider.notifier).updateOrderStatus(order.id, 'ACCEPTED');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Accept',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
