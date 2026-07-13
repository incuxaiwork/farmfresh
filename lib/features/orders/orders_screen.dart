import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../core/constants/app_enums.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _historyScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _historyScrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _historyScrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_historyScrollController.position.pixels >=
        _historyScrollController.position.maxScrollExtent - 200) {
      ref.read(orderProvider.notifier).loadMoreHistory();
    }
  }

  Color _getStatusColor(String status) {
    final s = status.toUpperCase();
    switch (s) {
      case 'PENDING':
        return Colors.orange;
      case 'CONFIRMED':
      case 'ACCEPTED':
      case 'PREPARING':
      case 'READY_FOR_PICKUP':
        return Colors.blue;
      case 'OUT_FOR_DELIVERY':
        return Colors.purple;
      case 'DELIVERED':
      case 'COMPLETED':
        return Colors.green;
      case 'REJECTED':
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    final s = status.toUpperCase();
    switch (s) {
      case 'PENDING':
        return Icons.schedule;
      case 'CONFIRMED':
      case 'ACCEPTED':
        return Icons.check_circle_outline;
      case 'PREPARING':
        return Icons.restaurant;
      case 'READY_FOR_PICKUP':
        return Icons.inventory_2;
      case 'OUT_FOR_DELIVERY':
        return Icons.local_shipping;
      case 'DELIVERED':
      case 'COMPLETED':
        return Icons.check_circle;
      case 'REJECTED':
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.receipt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);

    ref.listen<OrderState>(orderProvider, (prev, next) {
      if (next.actionMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.actionMessage!),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(orderProvider.notifier).clearMessages();
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(orderProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              text: orderState.currentOrders.isNotEmpty
                  ? 'Active (${orderState.currentOrders.length})'
                  : 'Active',
            ),
            const Tab(text: 'History'),
          ],
        ),
      ),
      body: orderState.isLoading && orderState.currentOrders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : orderState.errorMessage != null &&
                  orderState.currentOrders.isEmpty &&
                  orderState.historyOrders.isEmpty
              ? _buildErrorState(orderState.errorMessage!)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildActiveOrders(orderState),
                    _buildHistoryOrders(orderState),
                  ],
                ),
    );
  }

  Widget _buildActiveOrders(OrderState orderState) {
    if (orderState.currentOrders.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.read(orderProvider.notifier).loadOrders(),
        child: ListView(
          children: const [
            SizedBox(height: 100),
            EmptyOrdersWidget(
              icon: Icons.receipt_long_outlined,
              title: 'No Active Orders',
              message: 'You don\'t have any orders in progress.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(orderProvider.notifier).loadOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: orderState.currentOrders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(orderState.currentOrders[index]);
        },
      ),
    );
  }

  Widget _buildHistoryOrders(OrderState orderState) {
    if (orderState.historyOrders.isEmpty && !orderState.isLoading) {
      return RefreshIndicator(
        onRefresh: () => ref.read(orderProvider.notifier).loadOrders(),
        child: ListView(
          children: const [
            SizedBox(height: 100),
            EmptyOrdersWidget(
              icon: Icons.history,
              title: 'No Order History',
              message: 'Your completed and cancelled orders will appear here.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(orderProvider.notifier).loadOrders(),
      child: ListView.builder(
        controller: _historyScrollController,
        padding: const EdgeInsets.all(12),
        itemCount: orderState.historyOrders.length +
            (orderState.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == orderState.historyOrders.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _buildOrderCard(orderState.historyOrders[index]);
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final statusColor = _getStatusColor(order.status);
    final statusIcon = _getStatusIcon(order.status);
    final displayStatus = OrderStatus.fromApiValue(order.status).displayName;
    final dateStr = DateFormat('dd/MM/yyyy - HH:mm').format(order.date);
    final orderDisplay =
        order.orderNumber.isNotEmpty ? order.orderNumber : order.id.substring(0, 8);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/order-detail', extra: order.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #$orderDisplay',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          displayStatus,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(dateStr, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(height: 8),
              ...order.items.take(3).map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.product.name}',
                            style: const TextStyle(fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '₹${item.totalPrice.toStringAsFixed(2)}',
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  )),
              if (order.items.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${order.items.length - 3} more item(s)',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ₹${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.green),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(orderProvider.notifier).loadOrders(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyOrdersWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const EmptyOrdersWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
