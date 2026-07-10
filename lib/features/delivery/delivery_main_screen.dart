import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order_model.dart';

class DeliveryMainScreen extends ConsumerStatefulWidget {
  const DeliveryMainScreen({super.key});

  @override
  ConsumerState<DeliveryMainScreen> createState() => _DeliveryMainScreenState();
}

class _DeliveryMainScreenState extends ConsumerState<DeliveryMainScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyDeliveryOtp(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delivery OTP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter the confirmation OTP from the customer to complete this delivery:'),
              const SizedBox(height: 16),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '4-Digit OTP',
                  border: OutlineInputBorder(),
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
                      const SnackBar(content: Text('Delivery confirmed! Status: Delivered.'), backgroundColor: Colors.green),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incorrect OTP code'), backgroundColor: Colors.red),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text('Verify & Complete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final authState = ref.watch(authProvider);

    // Filter orders for delivery partners (in transit or accepted orders ready to be picked up)
    final deliveryOrders = orderState.orders.where((o) => o.status == 'In Transit' || o.status == 'Accepted').toList();
    final completedDeliveries = orderState.orders.where((o) => o.status == 'Delivered').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Partner Portal'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (!mounted) return;
              context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rider Profile card
            Card(
              color: Colors.green[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.local_shipping, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authState.user?.name ?? 'Delivery Partner',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          authState.user?.email ?? 'rider@farmfresh.com',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Active Delivery Tasks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            deliveryOrders.isEmpty
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(
                        child: Text('No active delivery tasks at the moment.', style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  )
                : Column(
                    children: deliveryOrders.map((order) {
                      final dateStr = DateFormat('MMM dd, hh:mm a').format(order.date);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.between,
                                children: [
                                  Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Chip(
                                    label: Text(order.status),
                                    backgroundColor: order.status == 'In Transit' ? Colors.purple[100] : Colors.blue[100],
                                    labelStyle: TextStyle(color: order.status == 'In Transit' ? Colors.purple[900] : Colors.blue[900], fontSize: 11),
                                  ),
                                ],
                              ),
                              Text('Date: $dateStr', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 8),
                              const Text('Destination:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              const Text('123 Delivery Lane, New York, US', style: TextStyle(color: Colors.grey)),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.between,
                                children: [
                                  Text('Order total: \$${order.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  if (order.status == 'Accepted')
                                    ElevatedButton(
                                      onPressed: () => ref.read(orderProvider.notifier).updateStatus(order.id, 'In Transit'),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                                      child: const Text('Pick Up & Start'),
                                    ),
                                  if (order.status == 'In Transit')
                                    ElevatedButton(
                                      onPressed: () => _verifyDeliveryOtp(order),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                      child: const Text('Complete Delivery'),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 24),
            const Text(
              'Completed Deliveries',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            completedDeliveries.isEmpty
                ? const Text('No completed tasks yet.', style: TextStyle(color: Colors.grey))
                : Column(
                    children: completedDeliveries.map((order) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.check_circle, color: Colors.green),
                          title: Text('Order #${order.id} Delivered successfully'),
                          subtitle: Text('Earnings: \$${(order.deliveryFee).toStringAsFixed(2)}'),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
