import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_enums.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  IO.Socket? _socket;
  String? _driverName;
  double? _driverLatitude;
  final StreamController<Map<String, dynamic>> _locationController =
      StreamController<Map<String, dynamic>>.broadcast();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(orderProvider.notifier).loadOrderById(widget.orderId);
      _connectSocket();
    });
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _locationController.close();
    super.dispose();
  }

  Future<void> _connectSocket() async {
    const secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: 'access_token');
    if (token == null) return;

    _socket = IO.io(
      AppConstants.socketBaseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      _socket!.emit('join:order', widget.orderId);
    });

    _socket!.on('order:update', (data) {
      if (!mounted) return;
      final orderId = data['orderId'] ?? data['id'];
      if (orderId == widget.orderId) {
        ref.read(orderProvider.notifier).loadOrderById(widget.orderId);
      }
    });

    _socket!.on('delivery:location', (data) {
      if (!mounted) return;
      if (data['orderId'] == widget.orderId) {
        setState(() {
          _driverLatitude = data['latitude']?.toDouble();
        });
        _locationController.add(data);
      }
    });

    _socket!.on('delivery:status', (data) {
      if (!mounted) return;
      if (data['orderId'] == widget.orderId) {
        setState(() {
          _driverName = data['driverName'];
        });
      }
    });

    _socket!.onDisconnect((_) {});
    _socket!.onError((err) {});
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final order = orderState.selectedOrder;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (_driverName != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  _driverName!,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
      body: orderState.isLoading && order == null
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? _buildErrorState(orderState.errorMessage ?? 'Order not found')
              : _buildTrackingContent(order),
    );
  }

  Widget _buildTrackingContent(OrderModel order) {
    final displayStatus =
        OrderStatus.fromApiValue(order.status).displayName;
    final progress = _getProgressValue(order.status);

    return Column(
      children: [
        _buildProgressHeader(displayStatus, progress),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildLiveMapPlaceholder(order),
                const SizedBox(height: 16),
                _buildStatusSteps(order),
                const SizedBox(height: 16),
                _buildOrderSummary(order),
                if (order.address != null && order.address!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDeliveryInfo(order),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressHeader(String displayStatus, double progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      color: Colors.green[50],
      child: Column(
        children: [
          Text(displayStatus,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.green[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text('${(progress * 100).toInt()}% complete',
              style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        ],
      ),
    );
  }

  double _getProgressValue(String status) {
    final s = status.toUpperCase();
    switch (s) {
      case 'PENDING':
        return 0.1;
      case 'CONFIRMED':
      case 'ACCEPTED':
        return 0.25;
      case 'PREPARING':
        return 0.5;
      case 'READY_FOR_PICKUP':
        return 0.65;
      case 'OUT_FOR_DELIVERY':
        return 0.8;
      case 'DELIVERED':
      case 'COMPLETED':
        return 1.0;
      case 'CANCELLED':
      case 'REJECTED':
        return 0.0;
      default:
        return 0.1;
    }
  }

  Widget _buildLiveMapPlaceholder(OrderModel order) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.green[100]!, Colors.green[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 48, color: Colors.green),
            const SizedBox(height: 8),
            Text(
              _driverLatitude != null
                  ? 'Driver is on the way'
                  : 'Live tracking will appear here',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green[700]),
            ),
            if (_driverLatitude != null)
              StreamBuilder<Map<String, dynamic>>(
                stream: _locationController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Location updated ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSteps(OrderModel order) {
    final steps = _getTrackingSteps(order.status);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Live Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isLast = index == steps.length - 1;
              final isCompleted = step['isCompleted'] as bool;
              final isActive = step['isActive'] as bool;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
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
                                  size: 14, color: Colors.white)
                              : isActive
                                  ? const SizedBox(
                                      width: 10,
                                      height: 10,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 30,
                          color: isCompleted ? Colors.green : Colors.grey[300],
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        step['title'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isCompleted || isActive ? FontWeight.bold : FontWeight.normal,
                          color:
                              isCompleted || isActive ? Colors.black87 : Colors.grey,
                        ),
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

  List<Map<String, dynamic>> _getTrackingSteps(String status) {
    final s = status.toUpperCase();
    return [
      {
        'title': 'Order Confirmed',
        'isCompleted': s != 'PENDING',
        'isActive': s == 'CONFIRMED' || s == 'ACCEPTED',
      },
      {
        'title': 'Being Prepared',
        'isCompleted': const {'PREPARING', 'READY_FOR_PICKUP', 'OUT_FOR_DELIVERY', 'DELIVERED', 'COMPLETED'}.contains(s),
        'isActive': s == 'PREPARING',
      },
      {
        'title': 'Ready for Pickup',
        'isCompleted': const {'READY_FOR_PICKUP', 'OUT_FOR_DELIVERY', 'DELIVERED', 'COMPLETED'}.contains(s),
        'isActive': s == 'READY_FOR_PICKUP',
      },
      {
        'title': 'Out for Delivery',
        'isCompleted': const {'OUT_FOR_DELIVERY', 'DELIVERED', 'COMPLETED'}.contains(s),
        'isActive': s == 'OUT_FOR_DELIVERY',
      },
      {
        'title': 'Delivered',
        'isCompleted': const {'DELIVERED', 'COMPLETED'}.contains(s),
        'isActive': s == 'DELIVERED' || s == 'COMPLETED',
      },
    ];
  }

  Widget _buildOrderSummary(OrderModel order) {
    final displayStatus =
        OrderStatus.fromApiValue(order.status).displayName;
    final orderDisplay =
        order.orderNumber.isNotEmpty ? order.orderNumber : order.id.substring(0, 8);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _infoRow('Order ID', orderDisplay),
            _infoRow('Status', displayStatus),
            _infoRow('Items', '${order.items.length} items'),
            _infoRow('Total', '₹${order.total.toStringAsFixed(2)}'),
            _infoRow(
                'Ordered', DateFormat('dd/MM/yyyy HH:mm').format(order.date)),
            if (order.notes != null && order.notes!.isNotEmpty)
              _infoRow('Notes', order.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo(OrderModel order) {
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
                  const Text('Delivering to',
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
}
