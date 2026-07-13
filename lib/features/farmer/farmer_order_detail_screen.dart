import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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

  IconData _statusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.schedule;
      case 'ACCEPTED':
        return Icons.check_circle_outline;
      case 'PREPARING':
        return Icons.restaurant;
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
          backgroundColor: Colors.green,
        ),
      );
      ref.read(orderProvider.notifier).loadOrderById(orderId);
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
    await ref.read(orderProvider.notifier).loadOrderById(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderProvider);
    final order = state.selectedOrder;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          order != null
              ? 'Order #${order.orderNumber.isNotEmpty ? order.orderNumber : order.id.substring(0, 8)}'
              : 'Order Details',
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: state.isLoading && order == null
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null && order == null
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
              : order == null
                  ? const Center(child: Text('Order not found'))
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatusHeader(order),
                            const SizedBox(height: 24),
                            _buildTimeline(order),
                            const SizedBox(height: 24),
                            _buildItemsSection(order),
                            const SizedBox(height: 24),
                            _buildPriceSummary(order),
                            const SizedBox(height: 24),
                            if (order.address != null && order.address!.isNotEmpty)
                              _buildDeliveryAddress(order),
                            const SizedBox(height: 24),
                            if (order.notes != null && order.notes!.isNotEmpty)
                              _buildNotes(order),
                            const SizedBox(height: 24),
                            _buildActionButtons(order),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildStatusHeader(OrderModel order) {
    final color = _statusColor(order.status);
    final displayStatus = OrderStatus.fromApiValue(order.status).displayName;

    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(_statusIcon(order.status), size: 48, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayStatus,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(order.date),
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Progress',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...List.generate(steps.length, (index) {
              final isCompleted = index <= currentStep;
              final isCurrent = index == currentStep;
              return Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted ? Colors.green : Colors.grey[300],
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                        ),
                      ),
                      if (index < steps.length - 1)
                        Container(
                          width: 2,
                          height: 30,
                          color: isCompleted ? Colors.green : Colors.grey[300],
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    steps[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCompleted ? Colors.black87 : Colors.grey,
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

  Widget _buildItemsSection(OrderModel order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Items Ordered',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
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
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (item.product.farmName.isNotEmpty)
                              Text(
                                item.product.farmName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        '${item.quantity}x',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 80,
                        child: Text(
                          '₹${(item.totalPrice).toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary(OrderModel order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildPriceRow('Subtotal', order.subtotal),
            if (order.discount > 0)
              _buildPriceRow('Discount', -order.discount, color: Colors.red),
            _buildPriceRow('Delivery Fee', order.deliveryFee),
            const Divider(),
            _buildPriceRow(
              'Total',
              order.total,
              bold: true,
              color: Colors.green,
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress(OrderModel order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.address!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotes(OrderModel order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Notes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.notes_outlined, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.notes!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(OrderModel order) {
    switch (order.status.toUpperCase()) {
      case 'PENDING':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handleStatusUpdate(order.id, 'ACCEPTED'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Accept Order'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handleStatusUpdate(order.id, 'REJECTED'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Reject Order'),
              ),
            ),
          ],
        );
      case 'ACCEPTED':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _handleStatusUpdate(order.id, 'PREPARING'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Start Preparing'),
          ),
        );
      case 'PREPARING':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _handleStatusUpdate(order.id, 'READY_FOR_PICKUP'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Ready for Pickup'),
          ),
        );
      case 'READY_FOR_PICKUP':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _handleStatusUpdate(order.id, 'OUT_FOR_DELIVERY'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Mark Picked Up'),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
