import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/admin_provider.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  String _selectedFilter = 'CONFIRMED';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminProvider.notifier).loadOrders(status: _selectedFilter);
      ref.read(adminProvider.notifier).loadDeliveryPartners();
    });
  }

  void _loadOrdersFiltered(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    ref.read(adminProvider.notifier).loadOrders(status: filter);
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final orders = adminState.orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFilterButton('Confirmed', 'CONFIRMED'),
                _buildFilterButton('Pending', 'PENDING'),
                _buildFilterButton('Delivering', 'OUT_FOR_DELIVERY'),
                _buildFilterButton('Delivered', 'DELIVERED'),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: adminState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                    ? Center(
                        child: Text(
                          'No orders in $_selectedFilter state',
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final o = orders[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Order #${o.orderNumber.isNotEmpty ? o.orderNumber : o.id.substring(0, 8)}',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '₹${o.total.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Date: ${DateFormat('dd/MM/yyyy HH:mm').format(o.date)}'),
                                  Text('Status: ${o.status}'),
                                  Text('Address: ${o.address ?? ''}'),
                                  const SizedBox(height: 12),
                                  if (o.status == 'CONFIRMED' || o.status == 'PENDING')
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton.icon(
                                        onPressed: () => _showAssignDriverDialog(o),
                                        icon: const Icon(Icons.delivery_dining),
                                        label: const Text('Assign Driver'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) _loadOrdersFiltered(value);
      },
      selectedColor: Colors.green,
    );
  }

  void _showAssignDriverDialog(OrderModel order) {
    final drivers = ref.read(adminProvider).deliveryPartners;
    String? selectedDriverId = drivers.isNotEmpty ? drivers.first.id : null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Assign Delivery Partner'),
              content: drivers.isEmpty
                  ? const Text('No delivery partners available. Make sure you registered one.')
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Choose a delivery partner to assign to this order:'),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedDriverId,
                          items: drivers.map((d) {
                            return DropdownMenuItem<String>(
                              value: d.id,
                              child: Text(d.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setDialogState(() {
                              selectedDriverId = val;
                            });
                          },
                        ),
                      ],
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                if (drivers.isNotEmpty)
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedDriverId != null) {
                        Navigator.pop(context);
                        final ok = await ref
                            .read(adminProvider.notifier)
                            .assignDelivery(order.id, selectedDriverId!);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok ? 'Driver assigned successfully!' : 'Failed to assign driver.',
                              ),
                              backgroundColor: ok ? Colors.green : Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Assign'),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
