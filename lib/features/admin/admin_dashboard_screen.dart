import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminProvider.notifier).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final stats = adminState.dashboard.stats;
    final topSelling = adminState.dashboard.topSellingProducts;
    final topFarmers = adminState.dashboard.topFarmers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: adminState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(adminProvider.notifier).loadDashboard(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Platform Overview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _buildStatCard(
                        'Total Sales',
                        '₹${_formatStat(stats['totalSales'] ?? stats['totalRevenue'])}',
                        Icons.payments,
                        Colors.green,
                      ),
                      _buildStatCard(
                        'Total Orders',
                        '${stats['totalOrders'] ?? 0}',
                        Icons.receipt_long,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Farmers',
                        '${stats['totalFarmers'] ?? stats['farmersCount'] ?? 0}',
                        Icons.agriculture,
                        Colors.teal,
                      ),
                      _buildStatCard(
                        'Customers',
                        '${stats['totalCustomers'] ?? stats['customersCount'] ?? 0}',
                        Icons.people,
                        Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (topSelling.isNotEmpty) ...[
                    const Text(
                      'Top Selling Products',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: topSelling.length,
                        separatorBuilder: (c, i) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = topSelling[index];
                          return ListTile(
                            title: Text(item['name'] ?? 'Product'),
                            trailing: Text(
                              '${item['soldCount'] ?? item['quantity'] ?? 0} sold',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (topFarmers.isNotEmpty) ...[
                    const Text(
                      'Top Farmer Partners',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: topFarmers.length,
                        separatorBuilder: (c, i) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = topFarmers[index];
                          return ListTile(
                            title: Text(item['farmName'] ?? item['name'] ?? 'Farmer'),
                            subtitle: Text('KYC: ${item['kycStatus'] ?? 'APPROVED'}'),
                            trailing: const Icon(Icons.star, color: Colors.amber),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  String _formatStat(dynamic v) {
    if (v == null) return '0.00';
    if (v is num) return v.toStringAsFixed(2);
    if (v is String) {
      final parsed = double.tryParse(v);
      if (parsed != null) return parsed.toStringAsFixed(2);
      return v;
    }
    return v.toString();
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
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
