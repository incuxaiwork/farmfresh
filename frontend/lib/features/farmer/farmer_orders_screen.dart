import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/farmer_provider.dart';
import '../../models/order_model.dart';
import '../../core/constants/app_enums.dart';
import '../../core/utils/app_snackbar.dart';

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
    _tabController = TabController(length: 4, vsync: this);
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
      showAppSnackBar(
        context,
        'Order updated to $status',
        type: SnackBarType.success,
      );
    } else {
      showAppSnackBar(
        context,
        'Failed to update order status',
        type: SnackBarType.error,
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
          tabAlignment: TabAlignment.center,
          labelColor: const Color(0xFF2E7D32),
          unselectedLabelColor: const Color(0xFF647C72),
          indicatorColor: const Color(0xFF2E7D32),
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12),
          labelPadding: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          dividerHeight: 0,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
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
                    _buildOrderTab([
                      ...state.acceptedOrders,
                      ...state.preparingOrders,
                      ...state.readyOrders
                    ], 'ACCEPTED'),
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4EAE0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/farmer-order-detail', extra: order.id),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                        'Order #${order.orderNumber.isNotEmpty ? order.orderNumber : order.id.substring(0, 8)} • ${order.items.length} items',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: const Color(0xFF6B756A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (order.status.toUpperCase() == 'PENDING')
                  GestureDetector(
                    onTap: () => _handleStatusUpdate(order.id, 'ACCEPTED'),
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
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      displayStatus.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(color: color, fontWeight: FontWeight.w800, fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // _buildActionButton is no longer used for list view
}
