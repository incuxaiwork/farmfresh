import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  String _normalizeStatus(String status) {
    final s = status.toUpperCase();
    if (s == 'PENDING') return 'Pending';
    if (s == 'CONFIRMED' || s == 'ACCEPTED' || s == 'PREPARING' || s == 'READY_FOR_PICKUP') {
      return 'Accepted';
    }
    if (s == 'OUT_FOR_DELIVERY') return 'In Transit';
    if (s == 'DELIVERED' || s == 'COMPLETED') return 'Delivered';
    return 'Cancelled';
  }

  Color _getStatusColor(String status) {
    final normalized = _normalizeStatus(status);
    switch (normalized) {
      case 'Pending':
        return Colors.orange;
      case 'Accepted':
        return Colors.blue;
      case 'In Transit':
        return Colors.purple;
      case 'Delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: orderState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderState.orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text('No Orders Found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('You have not placed any orders yet.', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: orderState.orders.length,
                  itemBuilder: (context, index) {
                    final order = orderState.orders[index];
                    return _buildOrderItemCard(context, order);
                  },
                ),
    );
  }

  Widget _buildOrderItemCard(BuildContext context, OrderModel order) {
    final statusColor = _getStatusColor(order.status);
    final normalizedStatus = _normalizeStatus(order.status);
    final dateStr = DateFormat('MMM dd, yyyy - hh:mm a').format(order.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    normalizedStatus,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text('Date: $dateStr', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 8),
            
            // Items purchased
            const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      Text('${item.quantity}x ${item.product.name}', style: const TextStyle(fontSize: 14)),
                      Text('\$${(item.product.price * item.quantity).toStringAsFixed(2)}', style: TextStyle(color: Colors.grey[800])),
                    ],
                  ),
                )),
            
            const Divider(height: 20),
            
            // Price & OTP Code row
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Delivery: \$${order.deliveryFee.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      'Total Paid: \$${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                    ),
                  ],
                ),
                
                // Secure OTP for delivery verification
                if (normalizedStatus != 'Delivered')
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Column(
                      children: [
                        const Text('DELIVERY OTP', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue)),
                        const SizedBox(height: 2),
                        Text(
                          order.otp,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue, letterSpacing: 2),
                        ),
                      ],
                    ),
                  )
              ],
            ),
            
            const SizedBox(height: 12),
            // Custom Visual status stepper
            _buildStatusStepper(normalizedStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStepper(String currentStatus) {
    final stages = ['Pending', 'Accepted', 'In Transit', 'Delivered'];
    final currentIndex = stages.indexOf(currentStatus);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(stages.length, (index) {
          final isCompleted = index <= currentIndex;
          final stepColor = isCompleted ? Colors.green : Colors.grey[300]!;
          
          return Expanded(
            child: Row(
              children: [
                // Step Dot
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: stepColor, width: 2),
                  ),
                  child: Center(
                    child: index < currentIndex
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isCompleted ? Colors.white : Colors.grey,
                            ),
                          ),
                  ),
                ),
                
                // Connector line
                if (index < stages.length - 1)
                  Expanded(
                    child: Container(
                      height: 3,
                      color: index < currentIndex ? Colors.green : Colors.grey[200],
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
