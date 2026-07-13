import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/delivery_provider.dart';
import '../../models/delivery_model.dart';

class DeliveryOrdersScreen extends ConsumerStatefulWidget {
  const DeliveryOrdersScreen({super.key});

  @override
  ConsumerState<DeliveryOrdersScreen> createState() => _DeliveryOrdersScreenState();
}

class _DeliveryOrdersScreenState extends ConsumerState<DeliveryOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(deliveryOrdersProvider);

    ref.listen<DeliveryOrdersState>(deliveryOrdersProvider, (prev, next) {
      if (next.actionMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.actionMessage!), backgroundColor: Colors.green.shade600),
        );
        ref.read(deliveryOrdersProvider.notifier).clearMessages();
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red.shade600),
        );
        ref.read(deliveryOrdersProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        title: const Text('My Deliveries', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: 'Available (${ordersState.pendingDeliveries.length})'),
            Tab(text: 'Active (${ordersState.activeDeliveries.length})'),
          ],
        ),
      ),
      body: ordersState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(deliveryOrdersProvider.notifier).loadDeliveries(),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPendingList(ordersState.pendingDeliveries),
                  _buildActiveList(ordersState.activeDeliveries),
                ],
              ),
            ),
    );
  }

  Widget _buildPendingList(List<DeliveryOrder> pending) {
    if (pending.isEmpty) {
      return const _EmptyState(
        icon: Icons.assignment_late_outlined,
        title: 'No available deliveries',
        subtitle: 'New orders ready for pickup will appear here.',
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemCount: pending.length,
      itemBuilder: (context, index) => _AvailableCard(
        delivery: pending[index],
        onAccept: () => _acceptDelivery(pending[index].id),
        onReject: () => _showRejectDialog(pending[index]),
      ),
    );
  }

  Widget _buildActiveList(List<DeliveryOrder> active) {
    if (active.isEmpty) {
      return const _EmptyState(
        icon: Icons.local_shipping_outlined,
        title: 'No active deliveries',
        subtitle: 'Accept an available delivery to get started.',
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemCount: active.length,
      itemBuilder: (context, index) => _ActiveCard(
        delivery: active[index],
        onTap: () => context.push('/delivery-detail', extra: active[index].id),
      ),
    );
  }

  Future<void> _acceptDelivery(String deliveryId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Accept Delivery?'),
        content: const Text('You will be assigned to pick up and deliver this order.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(deliveryOrdersProvider.notifier).acceptDelivery(deliveryId);
    }
  }

  void _showRejectDialog(DeliveryOrder delivery) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Decline Delivery'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Let us know why you are declining this delivery.'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(deliveryOrdersProvider.notifier).rejectDelivery(
                    delivery.id,
                    reason: reasonController.text.trim().isEmpty
                        ? null
                        : reasonController.text.trim(),
                  );
            },
            child: const Text('Decline', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: Colors.green.shade400),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailableCard extends StatelessWidget {
  final DeliveryOrder delivery;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _AvailableCard({
    required this.delivery,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final id = (delivery.orderNumber != null && delivery.orderNumber!.isNotEmpty)
        ? delivery.orderNumber!
        : delivery.orderId;

    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Order #$id',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Earn ₹${(delivery.deliveryFee ?? 0).toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (delivery.customer != null)
              _InfoRow(
                icon: Icons.person_outline,
                iconColor: Colors.blue.shade600,
                label: 'Customer',
                value: delivery.customer!.name,
              ),
            if (delivery.deliveryAddress?.fullAddress != null)
              _InfoRow(
                icon: Icons.location_on_outlined,
                iconColor: Colors.red.shade500,
                label: 'Drop',
                value: delivery.deliveryAddress!.fullAddress,
              ),
            if (delivery.distance != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.straighten, size: 15, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      '${delivery.distance!.toStringAsFixed(1)} km away',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    if (delivery.total != null) ...[
                      const SizedBox(width: 16),
                      Icon(Icons.receipt_long, size: 15, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        '₹${delivery.total!.toStringAsFixed(0)}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      side: BorderSide(color: Colors.red.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveCard extends StatelessWidget {
  final DeliveryOrder delivery;
  final VoidCallback onTap;

  const _ActiveCard({required this.delivery, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final id = (delivery.orderNumber != null && delivery.orderNumber!.isNotEmpty)
        ? delivery.orderNumber!
        : delivery.orderId;
    final color = _statusColor(delivery.status);

    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Order #$id',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _statusText(delivery.status),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (delivery.deliveryAddress?.fullAddress != null)
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.red.shade400),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        delivery.deliveryAddress!.fullAddress,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Earn ₹${(delivery.deliveryFee ?? 0).toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  Icon(Icons.chevron_right, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(DeliveryOrderStatus status) {
    switch (status) {
      case DeliveryOrderStatus.pending:
        return Colors.orange.shade700;
      case DeliveryOrderStatus.accepted:
        return Colors.blue.shade700;
      case DeliveryOrderStatus.pickedUp:
        return Colors.teal.shade700;
      case DeliveryOrderStatus.outForDelivery:
        return Colors.purple.shade700;
      case DeliveryOrderStatus.delivered:
        return Colors.green.shade700;
      case DeliveryOrderStatus.cancelled:
      case DeliveryOrderStatus.rejected:
        return Colors.red.shade700;
    }
  }

  String _statusText(DeliveryOrderStatus status) {
    switch (status) {
      case DeliveryOrderStatus.pending:
        return 'Pending';
      case DeliveryOrderStatus.accepted:
        return 'Accepted';
      case DeliveryOrderStatus.pickedUp:
        return 'Picked Up';
      case DeliveryOrderStatus.outForDelivery:
        return 'Out for Delivery';
      case DeliveryOrderStatus.delivered:
        return 'Delivered';
      case DeliveryOrderStatus.cancelled:
        return 'Cancelled';
      case DeliveryOrderStatus.rejected:
        return 'Rejected';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
