import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';

class FarmerOrdersScreen extends ConsumerStatefulWidget {
  const FarmerOrdersScreen({super.key});

  @override
  ConsumerState<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends ConsumerState<FarmerOrdersScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
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

  void _verifyAndDeliver(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Verify Delivery OTP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ask the customer for their secure order confirmation OTP code to complete delivery.'),
              const SizedBox(height: 16),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '4-Digit OTP',
                  border: OutlineInputBorder(),
                  hintText: 'Enter OTP',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final otpVal = _otpController.text.trim();
                if (otpVal == order.otp) {
                  Navigator.pop(context);
                  _otpController.clear();
                  final success = await ref.read(orderProvider.notifier).updateStatus(order.id, 'Delivered');
                  if (!mounted) return;
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order delivered successfully! Payout credited.'), backgroundColor: Colors.green),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid OTP code. Please verify and try again.'), backgroundColor: Colors.red),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text('Verify & Deliver'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Orders'),
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
                      const Text('No Client Orders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('No client orders have been received yet.', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: orderState.orders.length,
                  itemBuilder: (context, index) {
                    final order = orderState.orders[index];
                    return _buildFarmerOrderItemCard(order);
                  },
                ),
    );
  }

  Widget _buildFarmerOrderItemCard(OrderModel order) {
    final statusColor = _getStatusColor(order.status);
    final dateStr = DateFormat('MMM dd, hh:mm a').format(order.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text('Date: $dateStr', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            const Text('Items Purchased:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ...order.items.map((item) => Text(
                  '- ${item.quantity}x ${item.product.name} (from ${item.product.farmName})',
                  style: TextStyle(color: Colors.grey[800], fontSize: 13),
                )),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Text('Total: \$${order.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green)),
                
                // State processing buttons
                if (order.status == 'Pending')
                  ElevatedButton(
                    onPressed: () => ref.read(orderProvider.notifier).updateStatus(order.id, 'Accepted'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    child: const Text('Accept Order'),
                  ),
                if (order.status == 'Accepted')
                  ElevatedButton(
                    onPressed: () => ref.read(orderProvider.notifier).updateStatus(order.id, 'In Transit'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                    child: const Text('Dispatch Order'),
                  ),
                if (order.status == 'In Transit')
                  ElevatedButton(
                    onPressed: () => _verifyAndDeliver(order),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: const Text('Enter OTP & Deliver'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
