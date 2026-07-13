import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../providers/farmer_provider.dart';
import '../../models/order_model.dart';
import '../../core/constants/app_enums.dart';

class FarmerOrdersScreen extends ConsumerStatefulWidget {
  const FarmerOrdersScreen({super.key});

  @override
  ConsumerState<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends ConsumerState<FarmerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    final s = status.toUpperCase();
    switch (s) {
      case 'PENDING':
        return Colors.orange;
      case 'ACCEPTED':
      case 'PREPARING':
      case 'READY_FOR_PICKUP':
        return Colors.blue;
      case 'OUT_FOR_DELIVERY':
        return Colors.purple;
      case 'DELIVERED':
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _handleStatusUpdate(String orderId, String status) async {
    final success =
        await ref.read(farmerOrderProvider.notifier).updateOrderStatus(orderId, status);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order updated to $status'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update order status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refresh() async {
    await ref.read(farmerOrderProvider.notifier).loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(farmerOrderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Orders'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
            Tab(text: 'Preparing'),
            Tab(text: 'Ready'),
            Tab(text: 'Delivered'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null && state.errorMessage!.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrderTab(state.pendingOrders, 'PENDING'),
                    _buildOrderTab(state.acceptedOrders, 'ACCEPTED'),
                    _buildOrderTab(state.preparingOrders, 'PREPARING'),
                    _buildOrderTab(state.readyOrders, 'READY_FOR_PICKUP'),
                    _buildOrderTab(state.deliveredOrders, 'DELIVERED'),
                    _buildOrderTab(state.cancelledOrders, 'CANCELLED'),
                  ],
                ),
    );
  }

  Widget _buildOrderTab(List<OrderModel> orders, String statusKey) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No ${_tabLabel(statusKey)} Orders',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: orders.length,
        itemBuilder: (context, index) => _buildOrderCard(orders[index]),
      ),
    );
  }

  String _tabLabel(String status) {
    switch (status) {
      case 'PENDING':
        return 'Pending';
      case 'ACCEPTED':
        return 'Accepted';
      case 'PREPARING':
        return 'Preparing';
      case 'READY_FOR_PICKUP':
        return 'Ready';
      case 'DELIVERED':
        return 'Delivered';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return '';
    }
  }

  Widget _buildOrderCard(OrderModel order) {
    final color = _statusColor(order.status);
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(order.date);
    final displayStatus = OrderStatus.fromApiValue(order.status).displayName;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => context.push('/farmer/orders/${order.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.orderNumber.isNotEmpty ? order.orderNumber : order.id.substring(0, 8)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: color.withOpacity(0.5)),
                    ),
                    child: Text(
                      displayStatus,
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(dateStr, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
              const Divider(height: 20),
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${item.quantity}x ${item.product.name}',
                      style: TextStyle(color: Colors.grey[800], fontSize: 13),
                    ),
                  )),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ₹${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.green,
                    ),
                  ),
                  _buildActionButton(order) ?? const SizedBox.shrink(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildActionButton(OrderModel order) {
    switch (order.status.toUpperCase()) {
      case 'PENDING':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => _handleStatusUpdate(order.id, 'ACCEPTED'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('Accept'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _handleStatusUpdate(order.id, 'REJECTED'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('Reject'),
            ),
          ],
        );
      case 'ACCEPTED':
        return ElevatedButton(
          onPressed: () => _handleStatusUpdate(order.id, 'PREPARING'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('Start Preparing'),
        );
      case 'PREPARING':
        return ElevatedButton(
          onPressed: () => _handleStatusUpdate(order.id, 'READY_FOR_PICKUP'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('Ready for Pickup'),
        );
      case 'READY_FOR_PICKUP':
        return ElevatedButton(
          onPressed: () => _handleStatusUpdate(order.id, 'OUT_FOR_DELIVERY'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('Mark Picked Up'),
        );
      default:
        return null;
    }
  }
}
