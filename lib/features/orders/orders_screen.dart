import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
        return const Color(0xFFE28C43);
      case 'CONFIRMED':
      case 'ACCEPTED':
      case 'PREPARING':
        return const Color(0xFF2E7D32);
      case 'READY_FOR_PICKUP':
        return const Color(0xFF219EBC);
      case 'OUT_FOR_DELIVERY':
        return const Color(0xFF8338EC);
      case 'DELIVERED':
      case 'COMPLETED':
        return const Color(0xFF2E7D32);
      case 'REJECTED':
      case 'CANCELLED':
        return const Color(0xFFFF4D6D);
      default:
        return const Color(0xFF647C72);
    }
  }

  IconData _getStatusIcon(String status) {
    final s = status.toUpperCase();
    switch (s) {
      case 'PENDING':
        return Icons.schedule_outlined;
      case 'CONFIRMED':
      case 'ACCEPTED':
        return Icons.check_circle_outline;
      case 'PREPARING':
        return Icons.spa_outlined;
      case 'READY_FOR_PICKUP':
        return Icons.inventory_2_outlined;
      case 'OUT_FOR_DELIVERY':
        return Icons.local_shipping_outlined;
      case 'DELIVERED':
      case 'COMPLETED':
        return Icons.check_circle;
      case 'REJECTED':
      case 'CANCELLED':
        return Icons.cancel_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);

    ref.listen<OrderState>(orderProvider, (prev, next) {
      if (next.actionMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.actionMessage!, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
        ref.read(orderProvider.notifier).clearMessages();
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFFFF4D6D),
          ),
        );
        ref.read(orderProvider.notifier).clearMessages();
      }
    });

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
            'My Orders',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: Color(0xFF23312B)),
            onPressed: () => context.pop(),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF2E7D32),
            unselectedLabelColor: const Color(0xFF647C72),
            indicatorColor: const Color(0xFF2E7D32),
            labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12),
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
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
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
      ),
    );
  }

  Widget _buildActiveOrders(OrderState orderState) {
    if (orderState.currentOrders.isEmpty) {
      return RefreshIndicator(
        color: const Color(0xFF2E7D32),
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
      color: const Color(0xFF2E7D32),
      onRefresh: () => ref.read(orderProvider.notifier).loadOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        color: const Color(0xFF2E7D32),
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
      color: const Color(0xFF2E7D32),
      onRefresh: () => ref.read(orderProvider.notifier).loadOrders(),
      child: ListView.builder(
        controller: _historyScrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: orderState.historyOrders.length +
            (orderState.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == orderState.historyOrders.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
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
    final dateStr = DateFormat('MMM dd, yyyy • hh:mm a').format(order.date);
    final orderDisplay =
        order.orderNumber.isNotEmpty ? order.orderNumber : order.id.substring(0, 8);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
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
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF23312B)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 10, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            displayStatus.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              color: statusColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 10, fontWeight: FontWeight.w500),
                ),
                const Divider(height: 24, color: Color(0xFFF3F3F3)),
                ...order.items.take(3).map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.quantity}x ${item.product.name}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF23312B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '₹${item.totalPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF647C72), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )),
                if (order.items.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${order.items.length - 3} more item(s)',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF8D99AE), fontWeight: FontWeight.bold),
                    ),
                  ),
                const Divider(height: 24, color: Color(0xFFF3F3F3)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ₹${order.total.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: const Color(0xFF2E7D32)),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF647C72), size: 16),
                  ],
                ),
              ],
            ),
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
            const Icon(Icons.cloud_off_outlined, size: 64, color: Color(0xFFFF4D6D)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(color: const Color(0xFFFF4D6D))),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ref.read(orderProvider.notifier).loadOrders(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
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
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEAF6EC),
              ),
              child: Icon(icon, size: 28, color: const Color(0xFF2E7D32)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
