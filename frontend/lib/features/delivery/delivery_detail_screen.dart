import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/delivery_provider.dart';
import '../../models/delivery_model.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/widgets/custom_button.dart';

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
    Future.microtask(() => ref.read(deliveryOrdersProvider.notifier).loadDelivery(widget.deliveryId));
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
        backgroundColor: const Color(0xFFF4F7F2),
        appBar: AppBar(
          title: Text('Loading Details...', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF1E241D))),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E241D)),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),
      );
    }

    final orderIdDisplay = delivery.orderNumber ?? delivery.orderId.substring(0, 8);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(
        title: Text(
          'Order #$orderIdDisplay',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF1E241D)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E241D)),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRouteMapCard(delivery),
                const SizedBox(height: 20),
                _buildLocationsTimeline(delivery),
                const SizedBox(height: 20),
                _buildOrderItemsCard(delivery),
                const SizedBox(height: 20),
                _buildCustomerCard(delivery),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    offset: Offset(0, -4),
                    blurRadius: 16,
                  ),
                ],
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: _buildActionButton(delivery, state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteMapCard(DeliveryOrder delivery) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x0A2E5C45), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            height: 120,
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map_outlined, size: 36, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    'Route Navigation Overview',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRouteMeta('EST. DISTANCE', '${(delivery.distance ?? 3.5).toStringAsFixed(1)} km', Icons.directions_car_outlined),
                Container(width: 1, height: 40, color: const Color(0xFFE4EAE0)),
                _buildRouteMeta('EST. EARNINGS', '₹${(delivery.deliveryFee ?? 50.0).toStringAsFixed(0)}', Icons.account_balance_wallet_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteMeta(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF6B756A)),
            const SizedBox(width: 4),
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF6B756A), fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xFF1E241D))),
      ],
    );
  }

  Widget _buildLocationsTimeline(DeliveryOrder delivery) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x0A2E5C45), blurRadius: 12, offset: Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Timeline & Delivery Route', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1E241D))),
          const Divider(height: 32, color: Color(0xFFE4EAE0)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: const Color(0xFFEAF3E4), shape: BoxShape.circle),
                    child: const Icon(Icons.storefront, color: Color(0xFF2E7D32), size: 16),
                  ),
                  Container(height: 48, width: 2, color: const Color(0xFFE4EAE0)),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: const Color(0xFFFBF0E2), shape: BoxShape.circle),
                    child: const Icon(Icons.location_on, color: Color(0xFFB8722E), size: 16),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PICKUP (FARMER)', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32))),
                    const SizedBox(height: 2),
                    Text(delivery.farmer?.farmName ?? 'Swarna Bharat Farms', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF1E241D))),
                    Text(delivery.pickupAddress?.street ?? 'House No. 12, Main Street, Guntur', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF6B756A), fontSize: 13)),
                    const SizedBox(height: 28),
                    Text('DROP OFF (CUSTOMER)', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFB8722E))),
                    const SizedBox(height: 2),
                    Text(delivery.customer?.name ?? 'Jane Customer', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF1E241D))),
                    Text(delivery.deliveryAddress?.street ?? 'No Drop-off address details', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF6B756A), fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard(DeliveryOrder delivery) {
    final list = delivery.items ?? [];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x0A2E5C45), blurRadius: 12, offset: Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Package Items List', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1E241D))),
          const Divider(height: 24, color: Color(0xFFE4EAE0)),
          if (list.isEmpty)
            Text('No items detailed in payload.', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF6B756A)))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.quantity}x ${item.name}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: const Color(0xFF1E241D), fontSize: 13)),
                      Text('₹${item.totalPrice.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32))),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(DeliveryOrder delivery) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x0A2E5C45), blurRadius: 12, offset: Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Color(0xFFEAF3E4), shape: BoxShape.circle),
            child: const Icon(Icons.person_outline, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(delivery.customer?.name ?? 'Jane Customer', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1E241D))),
                Text(delivery.customer?.phone ?? 'No phone logged', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF6B756A), fontSize: 13)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.phone, color: Colors.white, size: 20),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(DeliveryOrder delivery, DeliveryOrdersState state) {
    if (state.isPerformingAction) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
    }

    switch (delivery.status) {
      case DeliveryOrderStatus.pending:
        return CustomButton(
          text: 'Accept Delivery Job',
          onPressed: () => _acceptJob(delivery.id),
          height: 54,
        );
      case DeliveryOrderStatus.accepted:
        return Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Open Map',
                isOutlined: true,
                onPressed: () => context.push('/delivery-navigation', extra: delivery),
                height: 54,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Start Route',
                onPressed: () => _markPickedUp(delivery.id),
                height: 54,
              ),
            ),
          ],
        );
      case DeliveryOrderStatus.headingToPickup:
        return Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Open Map',
                isOutlined: true,
                onPressed: () => context.push('/delivery-navigation', extra: delivery),
                height: 54,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Confirm Pickup',
                onPressed: () => _confirmPickup(delivery.id),
                backgroundColor: const Color(0xFF2E7D32),
                height: 54,
              ),
            ),
          ],
        );
      case DeliveryOrderStatus.pickedUp:
        return CustomButton(
          text: 'Start Transit to Customer',
          onPressed: () => _startTransit(delivery.id),
          height: 54,
        );
      case DeliveryOrderStatus.outForDelivery:
        return CustomButton(
          text: 'Verify & Complete Delivery',
          onPressed: () => _showOtpDialog(delivery.id),
          height: 54,
        );
      case DeliveryOrderStatus.delivered:
        return CustomButton(
          text: 'Delivery Completed',
          onPressed: null,
          backgroundColor: const Color(0xFF6B756A),
          height: 54,
        );
      case DeliveryOrderStatus.cancelled:
      case DeliveryOrderStatus.rejected:
        return CustomButton(
          text: 'Assignment Inactive',
          onPressed: null,
          backgroundColor: const Color(0xFF6B756A),
          height: 54,
        );
    }
  }

  void _acceptJob(String id) async {
    final ok = await ref.read(deliveryOrdersProvider.notifier).acceptDelivery(id);
    if (mounted && ok) showAppSnackBar(context, 'Job accepted! Routing to farm...', type: SnackBarType.success);
  }

  void _markPickedUp(String id) async {
    final ok = await ref.read(deliveryOrdersProvider.notifier).markPickedUp(id);
    if (mounted && ok) showAppSnackBar(context, 'Route to farm started!', type: SnackBarType.success);
  }

  void _confirmPickup(String id) async {
    final ok = await ref.read(deliveryOrdersProvider.notifier).confirmPickup(id);
    if (mounted && ok) showAppSnackBar(context, 'Packages picked up. Ready for transit!', type: SnackBarType.info);
  }

  void _startTransit(String id) async {
    final ok = await ref.read(deliveryOrdersProvider.notifier).startDelivery(id);
    if (mounted && ok) showAppSnackBar(context, 'Transit started. Heading to customer drop-off.', type: SnackBarType.info);
  }

  void _showOtpDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Enter Delivery OTP', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF1E241D))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please collect the 6-digit OTP code displayed on the customer\'s order tracking screen to complete validation.',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF6B756A)),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8, color: const Color(0xFF2E7D32)),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '000000',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF6B756A), fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: CustomButton(
                  text: 'Verify',
                  onPressed: () async {
                    final otp = _otpController.text.trim();
                    if (otp.length != 6) {
                      showAppSnackBar(context, 'Please enter a valid 6-digit OTP code.', type: SnackBarType.error);
                      return;
                    }
                    Navigator.pop(context);
                    final ok = await ref.read(deliveryOrdersProvider.notifier).verifyOtp(id, otp);
                    if (mounted) {
                      if (ok) {
                        showAppSnackBar(context, 'Order verified and delivered!', type: SnackBarType.success);
                        context.pop();
                      } else {
                        showAppSnackBar(context, 'Invalid OTP code. Please retry.', type: SnackBarType.error);
                      }
                    }
                  },
                  height: 48,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
