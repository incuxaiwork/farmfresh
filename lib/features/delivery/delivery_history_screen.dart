import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/delivery_provider.dart';
import '../../models/delivery_model.dart';

class DeliveryHistoryScreen extends ConsumerStatefulWidget {
  const DeliveryHistoryScreen({super.key});

  @override
  ConsumerState<DeliveryHistoryScreen> createState() => _DeliveryHistoryScreenState();
}

class _DeliveryHistoryScreenState extends ConsumerState<DeliveryHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(deliveryHistoryProvider.notifier).loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(deliveryHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery History'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: historyState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(deliveryHistoryProvider.notifier).loadHistory(),
              child: historyState.orders.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No delivery history', style: TextStyle(color: Colors.grey, fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: historyState.orders.length,
                      itemBuilder: (context, index) {
                        final order = historyState.orders[index];
                        return _buildHistoryCard(order);
                      },
                    ),
            ),
    );
  }

  Widget _buildHistoryCard(DeliveryOrder order) {
    final statusColor = _getStatusColor(order.status);
    String dateStr = '';
    try {
      if (order.deliveredAt != null) {
        final parsed = DateTime.parse(order.deliveredAt!);
        dateStr = DateFormat('dd/MM/yyyy • HH:mm').format(parsed);
      } else if (order.assignedAt != null) {
        final parsed = DateTime.parse(order.assignedAt!);
        dateStr = DateFormat('dd/MM/yyyy • HH:mm').format(parsed);
      }
    } catch (_) {}

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/delivery-detail', extra: order.id),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order #${order.orderId}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(order.status),
                      style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (order.deliveryAddress?.fullAddress != null)
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.deliveryAddress?.fullAddress ?? 'No address',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (dateStr.isNotEmpty)
                    Text(dateStr, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  Row(
                    children: [
                      Text('₹${(order.deliveryFee ?? 0).toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      if (order.rating != null) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        Text('${order.rating}', style: const TextStyle(fontSize: 12)),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(DeliveryOrderStatus status) {
    switch (status) {
      case DeliveryOrderStatus.delivered:
        return Colors.green;
      case DeliveryOrderStatus.cancelled:
        return Colors.red;
      case DeliveryOrderStatus.rejected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(DeliveryOrderStatus status) {
    switch (status) {
      case DeliveryOrderStatus.delivered:
        return 'Delivered';
      case DeliveryOrderStatus.cancelled:
        return 'Cancelled';
      case DeliveryOrderStatus.rejected:
        return 'Rejected';
      default:
        return status.apiValue;
    }
  }
}
