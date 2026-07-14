import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
        return const Color(0xFFE28C43);
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
      case 'CANCELLED':
      case 'REJECTED':
        return const Color(0xFFFF4D6D);
      default:
        return const Color(0xFF647C72);
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
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update order status'),
          backgroundColor: Color(0xFFFF4D6D),
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Customer Orders',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF2E7D32),
          unselectedLabelColor: const Color(0xFF647C72),
          indicatorColor: const Color(0xFF2E7D32),
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12),
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
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : state.errorMessage != null && state.errorMessage!.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Color(0xFFFF4D6D)),
                        const SizedBox(height: 12),
                        Text(
                          state.errorMessage!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(color: const Color(0xFFFF4D6D)),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _refresh,
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF1F8F4),
                ),
                child: const Icon(Icons.receipt_long_outlined, size: 28, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 16),
              Text(
                'No ${_tabLabel(statusKey)} Orders',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
              ),
              const SizedBox(height: 4),
              Text(
                'Crops orders with this status will appear here.',
                style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: const Color(0xFF2E7D32),
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          onTap: () => context.push('/farmer-order-detail', extra: order.id),
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
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF23312B)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        displayStatus.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(color: color, fontWeight: FontWeight.w800, fontSize: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF647C72)),
                    const SizedBox(width: 4),
                    Text(
                      dateStr,
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF647C72), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const Divider(height: 24, color: Color(0xFFF3F3F3)),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${item.quantity}x ${item.product.name}',
                        style: GoogleFonts.plusJakartaSans(color: const Color(0xFF23312B), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    )),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ₹${order.total.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    _buildActionButton(order),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(OrderModel order) {
    switch (order.status.toUpperCase()) {
      case 'PENDING':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _handleStatusUpdate(order.id, 'ACCEPTED'),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  'Accept',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _handleStatusUpdate(order.id, 'REJECTED'),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F3),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  'Reject',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFFF4D6D),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        );
      case 'ACCEPTED':
        return GestureDetector(
          onTap: () => _handleStatusUpdate(order.id, 'PREPARING'),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6EC),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Text(
              'Start Preparing',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        );
      case 'PREPARING':
        return GestureDetector(
          onTap: () => _handleStatusUpdate(order.id, 'READY_FOR_PICKUP'),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFE28C43), Color(0xFFF3A05B)]),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Text(
              'Ready for Pickup',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        );
      case 'READY_FOR_PICKUP':
        return GestureDetector(
          onTap: () => _handleStatusUpdate(order.id, 'OUT_FOR_DELIVERY'),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F4),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Text(
              'Mark Picked Up',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
