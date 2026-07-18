import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_enums.dart';
import '../../core/services/routing_service.dart';
import '../../core/widgets/custom_button.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  IO.Socket? _socket;
  final StreamController<Map<String, dynamic>> _locationController =
      StreamController<Map<String, dynamic>>.broadcast();

  final MapController _mapController = MapController();
  final RoutingService _routingService = RoutingService();

  String? _driverName;
  LatLng? _driverPosition;
  LatLng? _customerPosition;
  RouteResult? _driverRoute;
  bool _mapInitialized = false;

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
        final lat = data['latitude']?.toDouble();
        final lng = data['longitude']?.toDouble();
        if (lat != null && lng != null) {
          setState(() {
            _driverPosition = LatLng(lat, lng);
          });
          _locationController.add(data);
          _updateDriverRoute();
          _fitMapToAll();
        }
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

  void _updateDriverRoute() {
    if (_driverPosition == null || _customerPosition == null) return;
    _routingService
        .getRoute(origin: _driverPosition!, destination: _customerPosition!)
        .then((route) {
      if (mounted && route != null) {
        setState(() => _driverRoute = route);
      }
    });
  }

  void _fitMapToAll() {
    if (!_mapInitialized) return;
    final points = <LatLng>[
      if (_driverPosition != null) _driverPosition!,
      if (_customerPosition != null) _customerPosition!,
    ];
    if (points.length >= 2) {
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(60),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final order = orderState.selectedOrder;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF2F8F4), Color(0xFFE6F2EA)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Track Order',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF23312B),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: Color(0xFF23312B)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: orderState.isLoading && order == null
            ? const Center(
                child:
                    CircularProgressIndicator(color: Color(0xFF2E7D32)))
            : order == null
                ? _buildErrorState(
                    orderState.errorMessage ?? 'Order not found')
                : _buildTrackingContent(order),
      ),
    );
  }

  Widget _buildTrackingContent(OrderModel order) {
    final displayStatus =
        OrderStatus.fromApiValue(order.status).displayName;
    final progress = _getProgressValue(order.status);
    final isOutForDelivery =
        order.status.toUpperCase() == 'OUT_FOR_DELIVERY';

    return Column(
      children: [
        _buildProgressHeader(displayStatus, progress),
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                isOutForDelivery
                    ? _buildLiveMap(order)
                    : _buildPlaceholderMap(order),
                const SizedBox(height: 16),
                _buildOtpCard(order),
                const SizedBox(height: 16),
                _buildStatusSteps(order),
                const SizedBox(height: 16),
                _buildOrderSummary(order),
                if (order.address != null && order.address!.isNotEmpty) ...[
                  const SizedBox(height: 16),
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

  Widget _buildLiveMap(OrderModel order) {
    // Parse customer coordinates from address if available
    // For now we use a default; in production, parse from order
    _customerPosition ??= const LatLng(16.5062, 80.6480);

    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _customerPosition!,
                initialZoom: 14,
                onMapReady: () {
                  _mapInitialized = true;
                  if (_driverPosition != null) _fitMapToAll();
                },
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: AppConstants.mapTileUrl,
                  userAgentPackageName: 'com.farmfresh.app',
                ),
                if (_driverRoute != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _driverRoute!.points,
                        strokeWidth: 3,
                        color: const Color(0xFF2E7D32),
                      ),
                    ],
                  ),
                MarkerLayer(markers: _buildTrackingMarkers()),
              ],
            ),
            // Driver info overlay
            if (_driverPosition != null && _driverRoute != null)
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping,
                          color: Color(0xFF2E7D32), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _driverName != null
                              ? '$_driverName is on the way'
                              : 'Driver is on the way',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF23312B),
                          ),
                        ),
                      ),
                      Text(
                        '${_driverRoute!.formattedDistance} away',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Marker> _buildTrackingMarkers() {
    final markers = <Marker>[];

    if (_driverPosition != null) {
      markers.add(
        Marker(
          point: _driverPosition!,
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(Icons.local_shipping,
                color: Colors.white, size: 18),
          ),
        ),
      );
    }

    if (_customerPosition != null) {
      markers.add(
        Marker(
          point: _customerPosition!,
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(Icons.home, color: Colors.white, size: 18),
          ),
        ),
      );
    }

    return markers;
  }

  Widget _buildPlaceholderMap(OrderModel order) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Container(
              color: const Color(0xFFFAFBF9),
              child: Center(
                child: Opacity(
                  opacity: 0.05,
                  child: Icon(Icons.map_outlined,
                      size: 180, color: const Color(0xFF2E7D32)),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.navigation_outlined,
                        size: 30, color: Color(0xFF2E7D32)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Live tracking available when\norder is out for delivery',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF23312B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader(String displayStatus, double progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            displayStatus.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFFAFBF9),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}% Complete',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF647C72),
                fontWeight: FontWeight.bold),
          ),
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

  Widget _buildStatusSteps(OrderModel order) {
    final steps = _getTrackingSteps(order.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Status tracking',
              style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF23312B))),
          const Divider(height: 24, color: Color(0xFFF3F3F3)),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == steps.length - 1;
            final isCompleted = step['isCompleted'] as bool;
            final isActive = step['isActive'] as bool;

            final circleColor = isCompleted
                ? const Color(0xFF2E7D32)
                : isActive
                    ? const Color(0xFFE28C43)
                    : const Color(0xFFECECEC);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: circleColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check,
                                size: 12, color: Colors.white)
                            : isActive
                                ? const SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 26,
                        color: isCompleted
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFECECEC),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      step['title'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: isCompleted || isActive
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: isCompleted || isActive
                            ? const Color(0xFF23312B)
                            : const Color(0xFF8D99AE),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
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
        'isCompleted': const {
          'PREPARING',
          'READY_FOR_PICKUP',
          'OUT_FOR_DELIVERY',
          'DELIVERED',
          'COMPLETED'
        }.contains(s),
        'isActive': s == 'PREPARING',
      },
      {
        'title': 'Ready for Pickup',
        'isCompleted': const {
          'READY_FOR_PICKUP',
          'OUT_FOR_DELIVERY',
          'DELIVERED',
          'COMPLETED'
        }.contains(s),
        'isActive': s == 'READY_FOR_PICKUP',
      },
      {
        'title': 'Out for Delivery',
        'isCompleted': const {
          'OUT_FOR_DELIVERY',
          'DELIVERED',
          'COMPLETED'
        }.contains(s),
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
    final orderDisplay = order.orderNumber.isNotEmpty
        ? order.orderNumber
        : order.id.substring(0, 8);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary info',
              style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF23312B))),
          const Divider(height: 24, color: Color(0xFFF3F3F3)),
          _infoRow('Order ID', orderDisplay),
          _infoRow('Status', displayStatus),
          _infoRow('Items Count', '${order.items.length} items'),
          _infoRow(
              'Total Price', '₹${order.total.toStringAsFixed(2)}'),
          _infoRow('Ordered date',
              DateFormat('MMM dd • hh:mm a').format(order.date)),
          if (order.notes != null && order.notes!.isNotEmpty)
            _infoRow('Order Notes', order.notes!),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo(OrderModel order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined,
              color: Color(0xFF2E7D32), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delivering crops to',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: const Color(0xFF23312B))),
                const SizedBox(height: 2),
                Text(order.address!,
                    style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF647C72),
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
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
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF647C72),
                  fontWeight: FontWeight.w600)),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF23312B)),
              textAlign: TextAlign.end,
            ),
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
            const Icon(Icons.error_outline,
                size: 64, color: Color(0xFFFF4D6D)),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFFF4D6D))),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Retry',
              icon: Icons.refresh,
              onPressed: () => ref
                  .read(orderProvider.notifier)
                  .loadOrderById(widget.orderId),
              width: 140,
              height: 44,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpCard(OrderModel order) {
    if (order.otpCode == null || order.otpCode!.isEmpty) {
      return const SizedBox.shrink();
    }
    if (order.status.toUpperCase() == 'DELIVERED' ||
        order.status.toUpperCase() == 'COMPLETED') {
      return const SizedBox.shrink();
    }
    return Card(
      elevation: 2,
      color: const Color(0xFFE8F5E9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFC8E6C9), width: 1.5),
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  const Color(0xFF2E7D32).withOpacity(0.1),
              child:
                  const Icon(Icons.key, color: Color(0xFF2E7D32)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery OTP Code',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF23312B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Share this with your driver to verify and complete delivery.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF647C72),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFC8E6C9), width: 1),
              ),
              child: Text(
                order.otpCode!,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
