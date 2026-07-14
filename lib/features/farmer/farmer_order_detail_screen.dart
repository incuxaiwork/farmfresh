import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../core/constants/app_enums.dart';

class FarmerOrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;

  const FarmerOrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<FarmerOrderDetailScreen> createState() =>
      _FarmerOrderDetailScreenState();
}

class _FarmerOrderDetailScreenState
    extends ConsumerState<FarmerOrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(orderProvider.notifier).loadOrderById(widget.orderId);
    });
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

  IconData _statusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.schedule_outlined;
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
      case 'CANCELLED':
      case 'REJECTED':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  int _statusStep(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 0;
      case 'ACCEPTED':
        return 1;
      case 'PREPARING':
        return 2;
      case 'READY_FOR_PICKUP':
        return 3;
      case 'OUT_FOR_DELIVERY':
        return 4;
      case 'DELIVERED':
      case 'COMPLETED':
        return 5;
      default:
        return -1;
    }
  }

  Future<void> _handleStatusUpdate(String orderId, String status) async {
    final success =
        await ref.read(orderProvider.notifier).updateStatus(orderId, status);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order updated to $status'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
      ref.read(orderProvider.notifier).loadOrderById(orderId);
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
    await ref.read(orderProvider.notifier).loadOrderById(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderProvider);
    final order = state.selectedOrder;

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
            order != null
                ? 'Order #${order.orderNumber.isNotEmpty ? order.orderNumber : order.id.substring(0, 8)}'
                : 'Order Details',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: Color(0xFF23312B)),
            onPressed: () => context.pop(),
          ),
        ),
        body: state.isLoading && order == null
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
            : state.errorMessage != null && order == null
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
                : order == null
                    ? const Center(child: Text('Order not found'))
                    : RefreshIndicator(
                        color: const Color(0xFF2E7D32),
                        onRefresh: _refresh,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatusHeader(order),
                              const SizedBox(height: 16),
                              _buildTimeline(order),
                              const SizedBox(height: 16),
                              _buildItemsSection(order),
                              const SizedBox(height: 16),
                              _buildPriceSummary(order),
                              const SizedBox(height: 16),
                              if (order.address != null && order.address!.isNotEmpty) ...[
                                _buildDeliveryAddress(order),
                                const SizedBox(height: 16),
                              ],
                              if (order.notes != null && order.notes!.isNotEmpty) ...[
                                _buildNotes(order),
                                const SizedBox(height: 16),
                              ],
                              _buildActionButtons(order),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
      ),
    );
  }

  Widget _buildStatusHeader(OrderModel order) {
    final color = _statusColor(order.status);
    final displayStatus = OrderStatus.fromApiValue(order.status).displayName;

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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon(order.status), size: 30, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayStatus,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy hh:mm a').format(order.date),
                  style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(OrderModel order) {
    final currentStep = _statusStep(order.status);

    if (currentStep < 0) {
      return const SizedBox.shrink();
    }

    const steps = [
      'Pending',
      'Accepted',
      'Preparing',
      'Ready for Pickup',
      'Out for Delivery',
      'Delivered',
    ];

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
          Text(
            'Order Progress',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (index) {
            final isCompleted = index <= currentStep;
            final isCurrent = index == currentStep;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? const Color(0xFF2E7D32) : const Color(0xFFECECEC),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, size: 12, color: Colors.white)
                            : Text(
                                '${index + 1}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF647C72),
                                ),
                              ),
                      ),
                    ),
                    if (index < steps.length - 1)
                      Container(
                        width: 2,
                        height: 24,
                        color: isCompleted ? const Color(0xFF2E7D32) : const Color(0xFFECECEC),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    steps[index],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                      color: isCompleted ? const Color(0xFF23312B) : const Color(0xFF8D99AE),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItemsSection(OrderModel order) {
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
          Text(
            'Items Ordered',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
          ),
          const Divider(height: 24, color: Color(0xFFF3F3F3)),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF23312B),
                            ),
                          ),
                          if (item.product.farmName.isNotEmpty)
                            Text(
                              item.product.farmName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: const Color(0xFF647C72),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '${item.quantity}x',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 80,
                      child: Text(
                        '₹${(item.totalPrice).toStringAsFixed(2)}',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF23312B),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(OrderModel order) {
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
          Text(
            'Price Summary',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
          ),
          const Divider(height: 24, color: Color(0xFFF3F3F3)),
          _buildPriceRow('Subtotal', order.subtotal),
          if (order.discount > 0)
            _buildPriceRow('Discount', -order.discount, color: const Color(0xFFFF4D6D)),
          _buildPriceRow('Delivery Fee', order.deliveryFee),
          const Divider(height: 24, color: Color(0xFFF3F3F3)),
          _buildPriceRow(
            'Total',
            order.total,
            bold: true,
            color: const Color(0xFF2E7D32),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: color ?? const Color(0xFF647C72),
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(
              fontSize: bold ? 14 : 12,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
              color: color ?? const Color(0xFF23312B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress(OrderModel order) {
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
          Text(
            'Delivery Address',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, color: Color(0xFF2E7D32), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.address!,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF647C72), fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotes(OrderModel order) {
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
          Text(
            'Order Notes',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.notes_outlined, color: Color(0xFF2E7D32), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.notes!,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF647C72), fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(OrderModel order) {
    switch (order.status.toUpperCase()) {
      case 'PENDING':
        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _handleStatusUpdate(order.id, 'ACCEPTED'),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Accept Order',
                      style: GoogleFonts.plusJakartaSans(color: const Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _handleStatusUpdate(order.id, 'REJECTED'),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Reject Order',
                      style: GoogleFonts.plusJakartaSans(color: const Color(0xFFFF4D6D), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
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
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6EC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Start Preparing',
                style: GoogleFonts.plusJakartaSans(color: const Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        );
      case 'PREPARING':
        return GestureDetector(
          onTap: () => _handleStatusUpdate(order.id, 'READY_FOR_PICKUP'),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFE28C43), Color(0xFFF3A05B)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Ready for Pickup',
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        );
      case 'READY_FOR_PICKUP':
        return GestureDetector(
          onTap: () => _handleStatusUpdate(order.id, 'OUT_FOR_DELIVERY'),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Mark Picked Up',
                style: GoogleFonts.plusJakartaSans(color: const Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
