import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(order != null
            ? 'Order #${order.orderNumber.isNotEmpty ? order.orderNumber : order.id.substring(0, 8)}'
            : 'Order Details'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: orderState.isLoading && order == null
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? _buildErrorState(orderState.errorMessage ?? 'Order not found')
              : _buildOrderDetail(order),
    );
  }

  Widget _buildOrderDetail(OrderModel order) {
    final displayStatus =
        OrderStatus.fromApiValue(order.status).displayName;
    final statusColor = _getStatusColor(order.status);
    final canCancel = order.status.toUpperCase() == 'PENDING' ||
        order.status.toUpperCase() == 'CONFIRMED';

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(orderProvider.notifier).loadOrderById(widget.orderId),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(order, displayStatus, statusColor),
            if (order.otpCode != null && order.otpCode!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildOtpCard(order.otpCode!),
            ],
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

  Widget _buildOtpCard(String otpCode) {
    return Card(
      color: Colors.green[50],
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.green[200]!, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.vpn_key_outlined, color: Colors.green[700], size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery OTP Code',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    otpCode,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[700],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Share with Driver',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(
      OrderModel order, String displayStatus, Color statusColor) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getStatusIcon(order.status),
                  color: statusColor, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayStatus,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: statusColor)),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy - HH:mm').format(order.date),
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTimeline(OrderModel order) {
    final steps = _getTimelineSteps(order.status);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Timeline',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isLast = index == steps.length - 1;
              final isActive = step['isActive'] as bool;
              final isCompleted = step['isCompleted'] as bool;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green
                              : isActive
                                  ? Colors.orange
                                  : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check,
                                  size: 16, color: Colors.white)
                              : isActive
                                  ? const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold),
                                    ),
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 32,
                          color: isCompleted ? Colors.green : Colors.grey[300],
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['title'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isCompleted || isActive
                                  ? Colors.black87
                                  : Colors.grey,
                            ),
                          ),
                          if (step['subtitle'] != null)
                            Text(
                              step['subtitle'] as String,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500]),
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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Items',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 48,
                          height: 48,
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
                            Text(item.product.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            Text(
                              '${item.quantity}x ₹${item.unitPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _productIcon(dynamic item) {
    return Container(
      color: Colors.green[50],
      child: const Icon(Icons.spa, color: Colors.green, size: 24),
    );
  }

  Widget _buildPriceSummary(OrderModel order) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Price Summary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _priceRow('Subtotal', '₹${order.subtotal.toStringAsFixed(2)}'),
            if (order.discount > 0)
              _priceRow('Discount', '-₹${order.discount.toStringAsFixed(2)}',
                  valueColor: Colors.green),
            _priceRow(
                'Delivery Fee',
                order.deliveryFee == 0
                    ? 'FREE'
                    : '₹${order.deliveryFee.toStringAsFixed(2)}',
                valueColor:
                    order.deliveryFee == 0 ? Colors.green : Colors.black),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  '₹${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress(OrderModel order) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.green, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Delivery Address',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(order.address!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo(OrderModel order) {
    final orderDisplay =
        order.orderNumber.isNotEmpty ? order.orderNumber : order.id.substring(0, 8);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _infoRow('Order ID', orderDisplay),
            _infoRow('Date',
                DateFormat('dd/MM/yyyy - HH:mm').format(order.date)),
            if (order.paymentStatus != null)
              _infoRow('Payment', order.paymentStatus!),
            if (order.notes != null && order.notes!.isNotEmpty)
              _infoRow('Notes', order.notes!),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Flexible(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
                textAlign: TextAlign.end),
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
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/order-tracking', extra: order.id),
              icon: const Icon(Icons.location_on),
              label: const Text('Track Order'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        if (isActive) const SizedBox(height: 12),
        if (canCancel)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showCancelDialog(order),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel Order'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        if (canCancel) const SizedBox(height: 12),
        if (!isActive)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _handleReorder(order),
              icon: const Icon(Icons.replay),
              label: const Text('Reorder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
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
        title: const Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to cancel this order?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Order'),
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
                  const SnackBar(
                    content: Text('Order cancelled successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                if (context.mounted) context.pop();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Order'),
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
          content: const Text('Items added to cart'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () => context.go('/cart'),
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
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ref
                  .read(orderProvider.notifier)
                  .loadOrderById(widget.orderId),
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
}
