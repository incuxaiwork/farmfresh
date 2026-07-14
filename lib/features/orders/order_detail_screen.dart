import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../core/constants/app_enums.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(orderProvider.notifier).loadOrderById(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final order = orderState.selectedOrder;

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
        body: orderState.isLoading && order == null
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
            : order == null
                ? _buildErrorState(orderState.errorMessage ?? 'Order not found')
                : _buildOrderDetail(order),
      ),
    );
  }

  Widget _buildOrderDetail(OrderModel order) {
    final displayStatus =
        OrderStatus.fromApiValue(order.status).displayName;
    final statusColor = _getStatusColor(order.status);
    final canCancel = order.status.toUpperCase() == 'PENDING' ||
        order.status.toUpperCase() == 'CONFIRMED';

    return RefreshIndicator(
      color: const Color(0xFF2E7D32),
      onRefresh: () =>
          ref.read(orderProvider.notifier).loadOrderById(widget.orderId),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(order, displayStatus, statusColor),
            const SizedBox(height: 16),
            _buildOrderTimeline(order),
            const SizedBox(height: 16),
            _buildItemsSection(order),
            const SizedBox(height: 16),
            _buildPriceSummary(order),
            if (order.address != null && order.address!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildDeliveryAddress(order),
            ],
            const SizedBox(height: 16),
            _buildOrderInfo(order),
            const SizedBox(height: 24),
            _buildActionButtons(order, canCancel),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(
      OrderModel order, String displayStatus, Color statusColor) {
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
              color: statusColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(_getStatusIcon(order.status), color: statusColor, size: 28),
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
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(order.date),
                  style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTimeline(OrderModel order) {
    final steps = _getTimelineSteps(order.status);

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
            'Order Timeline',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == steps.length - 1;
            final isActive = step['isActive'] as bool;
            final isCompleted = step['isCompleted'] as bool;

            final circleColor = isCompleted
                ? const Color(0xFF2E7D32)
                : isActive
                    ? const Color(0xFFE28C43)
                    : const Color(0xFFECECEC);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: circleColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, size: 12, color: Colors.white)
                            : isActive
                                ? const SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    '${index + 1}',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        color: const Color(0xFF647C72),
                                        fontWeight: FontWeight.bold),
                                  ),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 26,
                        color: isCompleted ? const Color(0xFF2E7D32) : const Color(0xFFECECEC),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isCompleted || isActive
                                ? const Color(0xFF23312B)
                                : const Color(0xFF8D99AE),
                          ),
                        ),
                        if (step['subtitle'] != null)
                          Text(
                            step['subtitle'] as String,
                            style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF647C72), fontWeight: FontWeight.w500),
                          ),
                      ],
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

  List<Map<String, dynamic>> _getTimelineSteps(String status) {
    final s = status.toUpperCase();
    final steps = [
      {
        'title': 'Order Placed',
        'subtitle': 'Your order has been received',
        'isCompleted': true,
        'isActive': false,
      },
      {
        'title': 'Confirmed',
        'subtitle': 'Farmer has accepted your order',
        'isCompleted': s != 'PENDING',
        'isActive': s == 'CONFIRMED',
      },
      {
        'title': 'Preparing',
        'subtitle': 'Your items are being prepared',
        'isCompleted': const {'PREPARING', 'READY_FOR_PICKUP', 'OUT_FOR_DELIVERY', 'DELIVERED', 'COMPLETED'}.contains(s),
        'isActive': s == 'PREPARING',
      },
      {
        'title': 'Ready for Pickup',
        'subtitle': 'Items ready for delivery partner',
        'isCompleted': const {'READY_FOR_PICKUP', 'OUT_FOR_DELIVERY', 'DELIVERED', 'COMPLETED'}.contains(s),
        'isActive': s == 'READY_FOR_PICKUP',
      },
      {
        'title': 'Out for Delivery',
        'subtitle': 'On the way to you',
        'isCompleted': const {'OUT_FOR_DELIVERY', 'DELIVERED', 'COMPLETED'}.contains(s),
        'isActive': s == 'OUT_FOR_DELIVERY',
      },
      {
        'title': 'Delivered',
        'subtitle': 'Successfully delivered',
        'isCompleted': const {'DELIVERED', 'COMPLETED'}.contains(s),
        'isActive': s == 'DELIVERED' || s == 'COMPLETED',
      },
    ];

    if (s == 'CANCELLED' || s == 'REJECTED') {
      return [
        steps[0],
        {
          'title': s == 'CANCELLED' ? 'Cancelled' : 'Rejected',
          'subtitle': 'Order was ${s.toLowerCase()}',
          'isCompleted': true,
          'isActive': true,
        },
      ];
    }

    return steps;
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
            'Order Items',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
          ),
          const Divider(height: 24, color: Color(0xFFF3F3F3)),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: item.product.image.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: item.product.image,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => _productIcon(item),
                              )
                            : _productIcon(item),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFF23312B)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${item.quantity}x ₹${item.unitPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF647C72), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${item.totalPrice.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 12, color: const Color(0xFF23312B)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _productIcon(dynamic item) {
    return Container(
      color: const Color(0xFFE8F5E9),
      child: const Icon(Icons.spa_outlined, color: Color(0xFF2E7D32), size: 20),
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
          _priceRow('Subtotal', '₹${order.subtotal.toStringAsFixed(2)}'),
          if (order.discount > 0)
            _priceRow('Discount', '-₹${order.discount.toStringAsFixed(2)}',
                valueColor: const Color(0xFF2E7D32)),
          _priceRow(
              'Delivery Fee',
              order.deliveryFee == 0
                  ? 'FREE'
                  : '₹${order.deliveryFee.toStringAsFixed(2)}',
              valueColor:
                  order.deliveryFee == 0 ? const Color(0xFF2E7D32) : const Color(0xFF23312B)),
          const Divider(height: 24, color: Color(0xFFF3F3F3)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Price',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
              ),
              Text(
                '₹${order.total.toStringAsFixed(2)}',
                style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2E7D32)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF647C72), fontWeight: FontWeight.w600)),
          Text(value,
              style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? const Color(0xFF23312B))),
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
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: Color(0xFF2E7D32), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Address',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFF23312B)),
                ),
                const SizedBox(height: 2),
                Text(
                  order.address!,
                  style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo(OrderModel order) {
    final orderDisplay =
        order.orderNumber.isNotEmpty ? order.orderNumber : order.id.substring(0, 8);

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
            'Order Information',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
          ),
          const Divider(height: 24, color: Color(0xFFF3F3F3)),
          _infoRow('Order ID', orderDisplay),
          _infoRow('Placed On',
              DateFormat('MMM dd, yyyy • hh:mm a').format(order.date)),
          if (order.paymentStatus != null)
            _infoRow('Payment Method', order.paymentStatus!),
          if (order.notes != null && order.notes!.isNotEmpty)
            _infoRow('Order Notes', order.notes!),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF647C72), fontWeight: FontWeight.w600)),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(OrderModel order, bool canCancel) {
    final isActive = !const {'DELIVERED', 'COMPLETED', 'CANCELLED', 'REJECTED'}
        .contains(order.status.toUpperCase());

    return Column(
      children: [
        if (isActive)
          GestureDetector(
            onTap: () => context.push('/order-tracking', extra: order.id),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFE28C43), Color(0xFFF3A05B)]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1FE28C43),
                    offset: Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on_outlined, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Track Order',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        if (isActive) const SizedBox(height: 12),
        if (canCancel)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showCancelDialog(order),
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: Text(
                'Cancel Order',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF4D6D),
                side: const BorderSide(color: Color(0xFFFF4D6D)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        if (canCancel) const SizedBox(height: 12),
        if (!isActive)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _handleReorder(order),
              icon: const Icon(Icons.replay, size: 18),
              label: Text(
                'Reorder Items',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2E7D32),
                side: const BorderSide(color: Color(0xFF2E7D32)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
      ],
    );
  }

  void _showCancelDialog(OrderModel order) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Order Request', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Are you sure you want to cancel this order?', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              style: GoogleFonts.plusJakartaSans(fontSize: 12),
              decoration: InputDecoration(
                labelText: 'Reason (optional)',
                labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep Order', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(orderProvider.notifier)
                  .cancelOrder(order.id, reason: reasonController.text);
              if (!mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Order cancelled successfully', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                    backgroundColor: const Color(0xFF2E7D32),
                  ),
                );
                if (context.mounted) context.pop();
              }
            },
            child: Text('Cancel Order', style: GoogleFonts.plusJakartaSans(color: const Color(0xFFFF4D6D), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleReorder(OrderModel order) async {
    final success =
        await ref.read(orderProvider.notifier).reorder(order.id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Items added to cart', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF2E7D32),
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () {
              context.push('/cart');
            },
          ),
        ),
      );
    }
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFFF4D6D)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(color: const Color(0xFFFF4D6D))),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ref
                  .read(orderProvider.notifier)
                  .loadOrderById(widget.orderId),
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

  Color _getStatusColor(String status) {
    final s = status.toUpperCase();
    switch (s) {
      case 'PENDING':
        return const Color(0xFFE28C43);
      case 'CONFIRMED':
      case 'ACCEPTED':
      case 'PREPARING':
      case 'READY_FOR_PICKUP':
        return const Color(0xFF2E7D32);
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
}
