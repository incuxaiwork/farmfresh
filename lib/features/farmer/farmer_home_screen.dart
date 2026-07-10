import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';

class FarmerHomeScreen extends ConsumerWidget {
  const FarmerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productProvider);
    final orderState = ref.watch(orderProvider);

    // Calculate metrics dynamically
    final activeProductsCount = productState.products.where((p) => p.stock > 0).length;
    final outOfStockCount = productState.products.where((p) => p.stock == 0).length;
    final pendingOrdersCount = orderState.orders.where((o) => o.status != 'Delivered').length;

    // Total Earnings: Sum of delivered orders total
    final totalEarnings = orderState.orders
        .where((o) => o.status == 'Delivered')
        .fold(0.0, (sum, o) => sum + o.total);

    // Filter recent orders
    final recentOrders = orderState.orders.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Dashboard'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: orderState.isLoading || productState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back, Farmer Partner!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Here is your farm performance overview today.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  
                  // Stats Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      _buildStatCard('Total Earnings', '\$${totalEarnings.toStringAsFixed(2)}', Icons.attach_money, Colors.green),
                      _buildStatCard('Active Products', '$activeProductsCount Items', Icons.agriculture, Colors.orange),
                      _buildStatCard('Pending Orders', '$pendingOrdersCount Orders', Icons.pending_actions, Colors.blue),
                      _buildStatCard('Out of Stock', '$outOfStockCount Items', Icons.warning_amber_rounded, Colors.red),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Recent Orders section
                  const Text(
                    'Recent Order Activity',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  
                  recentOrders.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No orders placed yet.', style: TextStyle(color: Colors.grey)),
                          ),
                        )
                      : Column(
                          children: recentOrders.map((order) {
                            final dateStr = DateFormat('MMM dd').format(order.date);
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.green,
                                  child: Icon(Icons.shopping_bag, color: Colors.white),
                                ),
                                title: Text('Order #${order.id} - ${order.items.length} items', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Status: ${order.status} | $dateStr'),
                                trailing: const Icon(Icons.chevron_right),
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
