import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/delivery_provider.dart';
import '../../models/delivery_model.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/delivery_tracking_service.dart';

class DeliveryDetailScreen extends ConsumerStatefulWidget {
  final String deliveryId;

  const DeliveryDetailScreen({super.key, required this.deliveryId});

  @override
  ConsumerState<DeliveryDetailScreen> createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends ConsumerState<DeliveryDetailScreen> {
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(deliveryOrdersProvider.notifier).loadDelivery(widget.deliveryId);
      _autoStartTracking();
    });
  }

  void _autoStartTracking() {
    final delivery = ref.read(deliveryOrdersProvider).selectedDelivery;
    if (delivery == null) return;

    final isTrackingStatus =
        delivery.status == DeliveryOrderStatus.headingToPickup ||
        delivery.status == DeliveryOrderStatus.outForDelivery;

    if (isTrackingStatus) {
      ref.read(deliveryTrackingServiceProvider).startTracking(delivery.id);
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deliveryOrdersProvider);
    final delivery = state.selectedDelivery;

    if (state.isLoading || delivery == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading Details...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${delivery.orderNumber ?? delivery.orderId.substring(0, 8)}'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRouteMapCard(delivery),
                const SizedBox(height: 16),
                _buildLocationsTimeline(delivery),
                const SizedBox(height: 16),
                _buildOrderItemsCard(delivery),
                const SizedBox(height: 16),
                _buildCustomerCard(delivery),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: _buildActionButton(delivery, state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteMapCard(DeliveryOrder delivery) {
    // Determine map center
    final hasFarmer = delivery.farmerLatitude != null && delivery.farmerLongitude != null;
    final hasCustomer = delivery.customerLatitude != null && delivery.customerLongitude != null;

    LatLng? center;
    if (hasFarmer) center = LatLng(delivery.farmerLatitude!, delivery.farmerLongitude!);
    else if (hasCustomer) center = LatLng(delivery.customerLatitude!, delivery.customerLongitude!);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            height: 140,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              child: center != null
                  ? FlutterMap(
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: 13,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: AppConstants.mapTileUrl,
                          userAgentPackageName: 'com.farmfresh.app',
                        ),
                        MarkerLayer(markers: [
                          if (hasFarmer)
                            Marker(
                              point: LatLng(delivery.farmerLatitude!, delivery.farmerLongitude!),
                              width: 30,
                              height: 30,
                              child: const Icon(Icons.agriculture, color: Colors.blue, size: 24),
                            ),
                          if (hasCustomer)
                            Marker(
                              point: LatLng(delivery.customerLatitude!, delivery.customerLongitude!),
                              width: 30,
                              height: 30,
                              child: const Icon(Icons.home, color: Colors.green, size: 24),
                            ),
                        ]),
                      ],
                    )
                  : Container(
                      color: Colors.green.shade50,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.map, size: 40, color: Colors.green),
                            const SizedBox(height: 4),
                            Text(
                              'Route Navigation Overview',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRouteMeta('EST. DISTANCE', '${(delivery.distance ?? 3.5).toStringAsFixed(1)} km'),
                _buildRouteMeta('EST. EARNINGS', '₹${(delivery.deliveryFee ?? 50.0).toStringAsFixed(0)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteMeta(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
      ],
    );
  }

  Widget _buildLocationsTimeline(DeliveryOrder delivery) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Timeline & Delivery Route', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const Icon(Icons.store, color: Colors.blue),
                    Container(height: 40, width: 2, color: Colors.grey.shade300),
                    const Icon(Icons.location_on, color: Colors.green),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PICKUP (FARMER)',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        delivery.farmer?.farmName ?? 'Swarna Bharat Farms',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        delivery.pickupAddress?.street ?? 'House No. 12, Main Street, Guntur, AP',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'DROP OFF (CUSTOMER)',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        delivery.customer?.name ?? 'Jane Customer',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        delivery.deliveryAddress?.street ?? 'No Drop-off address details',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsCard(DeliveryOrder delivery) {
    final list = delivery.items ?? [];
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Package Items List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const Divider(height: 24),
            if (list.isEmpty)
              const Text('No items detailed in payload.', style: TextStyle(color: Colors.grey))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item.quantity}x ${item.name}', style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text('₹${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(DeliveryOrder delivery) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green.shade50,
              child: const Icon(Icons.person, color: Colors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    delivery.customer?.name ?? 'Jane Customer',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    delivery.customer?.phone ?? 'No phone logged',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.phone, color: Colors.green),
              onPressed: () {
                // Phone call simulation
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(DeliveryOrder delivery, DeliveryOrdersState state) {
    if (state.isPerformingAction) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (delivery.status) {
      case DeliveryOrderStatus.pending:
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => _acceptJob(delivery.id),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            child: const Text('Accept Delivery Job', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        );
      case DeliveryOrderStatus.accepted:
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => context.push('/delivery-navigation', extra: delivery),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.green), foregroundColor: Colors.green),
                  child: const Text('Open Map / GPS'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _markPickedUp(delivery.id),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  child: const Text('Start Route to Farm', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        );
      case DeliveryOrderStatus.headingToPickup:
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => context.push('/delivery-navigation', extra: delivery),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.green), foregroundColor: Colors.green),
                  child: const Text('Open Map / GPS'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _confirmPickup(delivery.id),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  child: const Text('Confirm Pickup', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        );
      case DeliveryOrderStatus.pickedUp:
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => _startTransit(delivery.id),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            child: const Text('Start Transit to Customer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        );
      case DeliveryOrderStatus.outForDelivery:
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => _showOtpDialog(delivery.id),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
            child: const Text('Verify & Complete Delivery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        );
      case DeliveryOrderStatus.delivered:
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            child: const Text('Delivery Completed Successfully', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      case DeliveryOrderStatus.cancelled:
      case DeliveryOrderStatus.rejected:
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            child: const Text('Delivery Assignment Inactive', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
    }
  }

  void _acceptJob(String id) async {
    final ok = await ref.read(deliveryOrdersProvider.notifier).acceptDelivery(id);
    if (mounted && ok) {
      showAppSnackBar(
        context,
        'Job accepted! Routing to farm...',
        type: SnackBarType.success,
      );
    }
  }

  void _markPickedUp(String id) async {
    final ok = await ref.read(deliveryOrdersProvider.notifier).markPickedUp(id);
    if (mounted && ok) {
      ref.read(deliveryTrackingServiceProvider).startTracking(id);
      showAppSnackBar(
        context,
        'Route to farm started!',
        type: SnackBarType.success,
      );
    }
  }

  void _confirmPickup(String id) async {
    final ok = await ref.read(deliveryOrdersProvider.notifier).confirmPickup(id);
    if (mounted && ok) {
      showAppSnackBar(
        context,
        'Packages picked up. Ready for transit!',
        type: SnackBarType.info,
      );
    }
  }

  void _startTransit(String id) async {
    final ok = await ref.read(deliveryOrdersProvider.notifier).startDelivery(id);
    if (mounted && ok) {
      ref.read(deliveryTrackingServiceProvider).startTracking(id);
      showAppSnackBar(
        context,
        'Transit started. Heading to customer drop-off.',
        type: SnackBarType.info,
      );
    }
  }

  void _showOtpDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Delivery OTP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please collect the 6-digit OTP code displayed on the customer\'s order tracking screen to complete last-mile validation.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: '6-Digit OTP Code',
                border: OutlineInputBorder(),
                counterText: '',
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
              final otp = _otpController.text.trim();
              if (otp.length != 6) {
                showAppSnackBar(
                  context,
                  'Please enter a valid 6-digit OTP code.',
                  type: SnackBarType.error,
                );
                return;
              }
              Navigator.pop(context);
              final ok = await ref.read(deliveryOrdersProvider.notifier).verifyOtp(id, otp);
              if (mounted) {
                if (ok) {
                  ref.read(deliveryTrackingServiceProvider).stopTracking();
                  showAppSnackBar(
                    context,
                    'Order verified and delivered!',
                    type: SnackBarType.success,
                  );
                  context.pop();
                } else {
                  showAppSnackBar(
                    context,
                    'Invalid OTP code. Please retry.',
                    type: SnackBarType.error,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Verify Code'),
          ),
        ],
      ),
    );
  }
}
