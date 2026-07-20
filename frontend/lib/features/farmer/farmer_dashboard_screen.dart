import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/farmer_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/product_image_widget.dart';
import '../../core/theme/colors.dart';

class FarmerDashboardScreen extends ConsumerStatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  ConsumerState<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends ConsumerState<FarmerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(farmerDashboardProvider.notifier).loadDashboard();
      ref.read(farmerOrderProvider.notifier).loadOrders();
      ref.read(farmerProductsProvider.notifier).loadFarmerProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final dashboardState = ref.watch(farmerDashboardProvider);
    final orderState = ref.watch(farmerOrderProvider);
    final productState = ref.watch(farmerProductsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Orders calculations
    final allOrders = [
      ...orderState.pendingOrders, 
      ...orderState.acceptedOrders, 
      ...orderState.deliveredOrders, 
      ...orderState.cancelledOrders
    ];
    
    final today = DateTime.now();
    final todayOrders = allOrders.where((o) => 
      o.date.year == today.year && 
      o.date.month == today.month && 
      o.date.day == today.day
    ).toList();

    final recentOrders = List<OrderModel>.from(allOrders)
      ..sort((a, b) => b.date.compareTo(a.date));
    final last5 = recentOrders.take(5).toList();

    // Products calculations
    final products = productState.products;
    final lowStockProducts = products.where((p) => p.stock < 20).toList();
    
    // Top selling products mock (assuming we just pick the first 3 for now, ideally backend provides this)
    // TODO: backend endpoint needed for true top-selling products sorted by units sold
    final topProducts = products.take(4).toList();

    // Earnings mock
    // TODO: backend endpoint needed for daily earnings chart data
    final weeklyEarnings = [1200.0, 1500.0, 900.0, 2200.0, 1800.0, 2500.0, 3100.0];
    
    return Scaffold(
      backgroundColor: Colors.transparent, // Inherits background from main screen
      body: SafeArea(
        child: Column(
          children: [

            // Profile Header (formerly AppBar)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Navigate to profile tab (index 4)
                      ref.read(farmerTabIndexProvider.notifier).state = 4;
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.farmerPrimary, // Solid primary color
                          backgroundImage: user?.avatar != null ? NetworkImage(user!.avatar!) : null,
                          child: user?.avatar == null 
                              ? Text(
                                  user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'F',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Hi ${user?.name ?? 'Farmer'}!',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/farmer-notifications'),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.farmerPrimary, // Solid green background
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.farmerPrimary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.notifications_none_outlined,
                        color: Colors.white, // White icon for contrast
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Main Body Content
            Expanded(
              child: (orderState.isLoading || dashboardState.isLoading)
                  ? Center(child: CircularProgressIndicator(color: AppColors.farmerPrimary))
                  : RefreshIndicator(
                      color: AppColors.farmerPrimary,
              onRefresh: () async {
                ref.read(farmerDashboardProvider.notifier).loadDashboard();
                await ref.read(farmerOrderProvider.notifier).loadOrders();
                await ref.read(farmerProductsProvider.notifier).loadFarmerProducts();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Quick Stats
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      childAspectRatio: 1.6,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStatCard(context, 'Today\'s Orders', todayOrders.length.toString(), Icons.shopping_bag_outlined),
                        _buildStatCard(context, 'Pending Orders', orderState.pendingOrders.length.toString(), Icons.pending_actions_outlined),
                        _buildStatCard(context, 'Total Earnings', '₹${dashboardState.dashboard.totalRevenue.toStringAsFixed(0)}', Icons.account_balance_wallet_outlined),
                        _buildStatCard(context, 'Products Listed', products.length.toString(), Icons.agriculture_outlined),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 2. Order Status Breakdown (3 tiles)
                    Text(
                      'Order Status',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusMiniTile(context, 'Accepted', orderState.acceptedOrders.length, Colors.blue, 2),
                        _buildStatusMiniTile(context, 'Delivered', orderState.deliveredOrders.length, AppColors.farmerPrimary, 2),
                        _buildStatusMiniTile(context, 'Cancelled', orderState.cancelledOrders.length, Colors.red, 2),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 3. Earnings Chart
                    Text(
                      'Earnings (Last 7 Days)',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildEarningsChart(context, weeklyEarnings),
                    const SizedBox(height: 24),

                    // 4. Quick Actions
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/farmer-add-product'),
                        icon: const Icon(Icons.add, size: 20, color: Colors.white),
                        label: Text(
                          'Add New Product',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 5. Top Selling Products
                    Text(
                      'Top Selling Products',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (topProducts.isEmpty)
                      Text('No products available.', style: theme.textTheme.bodyMedium)
                    else
                      SizedBox(
                        height: 140,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: topProducts.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 12),
                          itemBuilder: (context, index) => _buildTopProductCard(context, topProducts[index]),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // 6. Low Stock Alerts
                    Text(
                      'Low Stock Alerts',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (lowStockProducts.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color ?? colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'All products have sufficient stock.',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ...lowStockProducts.take(3).map((p) => _buildLowStockTile(context, p)).toList(),
                    const SizedBox(height: 24),

                    // 7. Recent Orders
                    Text(
                      'Recent Orders',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (last5.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No recent orders yet.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      )
                    else
                      ...last5.map((order) => _buildRecentOrderTile(context, order)).toList(),
                      
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.farmerPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.farmerPrimary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMiniTile(BuildContext context, String label, int count, Color color, int tabIndex) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(farmerTabIndexProvider.notifier).state = tabIndex; // Nav to Orders screen
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                count.toString(),
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsChart(BuildContext context, List<double> weeklyEarnings) {
    final theme = Theme.of(context);
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 4000,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final style = theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold) ?? const TextStyle(fontSize: 12);
                  String text;
                  switch (value.toInt()) {
                    case 0: text = 'Mon'; break;
                    case 1: text = 'Tue'; break;
                    case 2: text = 'Wed'; break;
                    case 3: text = 'Thu'; break;
                    case 4: text = 'Fri'; break;
                    case 5: text = 'Sat'; break;
                    case 6: text = 'Sun'; break;
                    default: text = ''; break;
                  }
                  return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(text, style: style));
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: weeklyEarnings.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value,
                  color: AppColors.farmerPrimary,
                  width: 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTopProductCard(BuildContext context, ProductModel product) {
    final theme = Theme.of(context);
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: ProductImageWidget(
              imageUrl: product.image,
              height: 70,
              width: double.infinity,
              fit: BoxFit.cover,
              borderRadius: 0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.soldCount} sold', // Real sold count
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.farmerPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockTile(BuildContext context, ProductModel product) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Only ${product.stock.toInt()} (${product.weight}) left in stock',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/farmer-add-product', extra: product), // pass product to edit
            child: Text(
              'Restock',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.farmerPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRecentOrderTile(BuildContext context, OrderModel order) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => context.push('/farmer-order-detail/${order.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.farmerPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.receipt_outlined, color: AppColors.farmerPrimary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.orderNumber.isNotEmpty ? order.orderNumber : order.id.substring(0, 6)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.items.length} items • ₹${order.total.toStringAsFixed(0)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildStatusBadge(order.status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    switch (status.toUpperCase()) {
      case 'PENDING':
        bg = Colors.orange.withOpacity(0.1);
        text = Colors.orange;
        break;
      case 'ACCEPTED':
        bg = Colors.blue.withOpacity(0.1);
        text = Colors.blue;
        break;
      case 'DELIVERED':
        bg = AppColors.farmerPrimary.withOpacity(0.1);
        text = AppColors.farmerPrimary;
        break;
      case 'CANCELLED':
        bg = Colors.red.withOpacity(0.1);
        text = Colors.red;
        break;
      default:
        bg = Colors.grey.withOpacity(0.1);
        text = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }
}
