import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/delivery_model.dart';
import '../../core/services/location_service.dart';
import '../../core/services/routing_service.dart';
import '../../core/services/delivery_tracking_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/navigation_helper.dart';

class DeliveryNavigationScreen extends ConsumerStatefulWidget {
  final DeliveryOrder delivery;

  const DeliveryNavigationScreen({super.key, required this.delivery});

  @override
  ConsumerState<DeliveryNavigationScreen> createState() =>
      _DeliveryNavigationScreenState();
}

class _DeliveryNavigationScreenState
    extends ConsumerState<DeliveryNavigationScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  final RoutingService _routingService = RoutingService();

  LatLng? _currentPosition;
  RouteResult? _currentRoute;
  bool _isLoadingLocation = true;
  bool _isLoadingRoute = true;
  String? _locationError;
  StreamSubscription<Position>? _positionSubscription;

  // Determine navigation target based on delivery status
  bool get _isHeadingToFarmer =>
      widget.delivery.status == DeliveryOrderStatus.accepted ||
      widget.delivery.status == DeliveryOrderStatus.headingToPickup;

  LatLng? get _destination {
    if (_isHeadingToFarmer) {
      if (widget.delivery.farmerLatitude != null &&
          widget.delivery.farmerLongitude != null) {
        return LatLng(
          widget.delivery.farmerLatitude!,
          widget.delivery.farmerLongitude!,
        );
      }
    } else {
      if (widget.delivery.customerLatitude != null &&
          widget.delivery.customerLongitude != null) {
        return LatLng(
          widget.delivery.customerLatitude!,
          widget.delivery.customerLongitude!,
        );
      }
    }
    return null;
  }

  String get _destinationName {
    if (_isHeadingToFarmer) {
      return widget.delivery.farmer?.farmName ?? 'Farmer';
    }
    return widget.delivery.customer?.name ?? 'Customer';
  }

  String get _destinationAddress {
    if (_isHeadingToFarmer) {
      return widget.delivery.pickupAddress?.street ?? 'Pickup location';
    }
    return widget.delivery.deliveryAddress?.street ?? 'Delivery location';
  }

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _locationService.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final permission = await _locationService.checkAndRequestPermission();
    if (permission != LocationPermissionStatus.granted) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _locationError = _getPermissionErrorMessage(permission);
        });
      }
      return;
    }

    final position = await _locationService.getCurrentPosition();
    if (position != null && mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
      _fetchRoute();
      _startLocationTracking();
    } else if (mounted) {
      setState(() {
        _isLoadingLocation = false;
        _locationError = 'Unable to get current location';
      });
    }
  }

  void _startLocationTracking() {
    _locationService.startTracking(intervalSeconds: 5, distanceFilter: 20);
    _positionSubscription = _locationService.onLocationUpdate.listen((pos) {
      if (!mounted) return;
      final newPos = LatLng(pos.latitude, pos.longitude);
      setState(() => _currentPosition = newPos);

      // Send location to backend via tracking service
      ref.read(deliveryTrackingServiceProvider).onLocationUpdate(pos);

      // Recalculate route if deviated significantly
      if (_currentRoute != null && _currentRoute!.points.isNotEmpty) {
        final distanceFromRoute = _distanceFromRoute(newPos);
        if (distanceFromRoute > AppConstants.routeRecalculationDistanceMeters) {
          _fetchRoute();
        }
      }
    });
  }

  double _distanceFromRoute(LatLng point) {
    double minDist = double.infinity;
    for (final routePoint in _currentRoute!.points) {
      final dist = Geolocator.distanceBetween(
        point.latitude,
        point.longitude,
        routePoint.latitude,
        routePoint.longitude,
      );
      if (dist < minDist) minDist = dist;
    }
    return minDist;
  }

  Future<void> _fetchRoute() async {
    if (_currentPosition == null || _destination == null) return;

    setState(() => _isLoadingRoute = true);

    final route = await _routingService.getRoute(
      origin: _currentPosition!,
      destination: _destination!,
    );

    if (mounted) {
      setState(() {
        _currentRoute = route;
        _isLoadingRoute = false;
      });

      if (route != null) {
        _fitMapToRoute();
      }
    }
  }

  void _fitMapToRoute() {
    if (_currentPosition == null || _destination == null) return;

    final bounds = LatLngBounds.fromPoints([
      _currentPosition!,
      _destination!,
      if (_currentRoute != null) ..._currentRoute!.points,
    ]);

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(60),
      ),
    );
  }

  void _recenterMap() {
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 16);
    }
  }

  String _getPermissionErrorMessage(LocationPermissionStatus permission) {
    switch (permission) {
      case LocationPermissionStatus.gpsDisabled:
        return 'Location services are disabled. Please enable GPS.';
      case LocationPermissionStatus.denied:
        return 'Location permission denied. Please grant permission to use navigation.';
      case LocationPermissionStatus.deniedForever:
        return 'Location permission permanently denied. Please open settings to enable it.';
      case LocationPermissionStatus.granted:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navigate to $_destinationName'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_currentPosition != null)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _recenterMap,
              tooltip: 'Recenter',
            ),
        ],
      ),
      body: _locationError != null
          ? _buildErrorView()
          : _isLoadingLocation
              ? const Center(child: CircularProgressIndicator(color: Colors.green))
              : _buildMapView(),
      bottomSheet: _locationError == null ? _buildBottomPanel() : null,
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _locationError!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            if (_locationError!.contains('disabled'))
              ElevatedButton.icon(
                onPressed: () async {
                  await _locationService.openLocationSettings();
                },
                icon: const Icon(Icons.settings),
                label: const Text('Open Location Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              )
            else if (_locationError!.contains('permanently'))
              ElevatedButton.icon(
                onPressed: () async {
                  await _locationService.openAppSettings();
                },
                icon: const Icon(Icons.settings),
                label: const Text('Open App Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: _initLocation,
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

  Widget _buildMapView() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentPosition ?? const LatLng(0, 0),
            initialZoom: 15,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: AppConstants.mapTileUrl,
              userAgentPackageName: 'com.farmfresh.app',
            ),
            if (_currentRoute != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _currentRoute!.points,
                    strokeWidth: 4,
                    color: Colors.green,
                  ),
                ],
              ),
            MarkerLayer(markers: _buildMarkers()),
          ],
        ),
        // Distance/ETA overlay
        if (_currentRoute != null)
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.navigation, color: Colors.green, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'To: $_destinationName',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _infoChip(Icons.straighten, _currentRoute!.formattedDistance),
                              const SizedBox(width: 12),
                              _infoChip(Icons.schedule, _currentRoute!.formattedDuration),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_isLoadingRoute)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),
            ),
          ),
        // Recenter button
        Positioned(
          right: 12,
          bottom: 12,
          child: FloatingActionButton(
            heroTag: 'recenter',
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _recenterMap,
            child: const Icon(Icons.my_location, color: Colors.green),
          ),
        ),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // Current position marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          point: _currentPosition!,
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.navigation, color: Colors.white, size: 20),
          ),
        ),
      );
    }

    // Destination marker
    if (_destination != null) {
      final isFarmer = _isHeadingToFarmer;
      markers.add(
        Marker(
          point: _destination!,
          width: 50,
          height: 50,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isFarmer ? Colors.blue : Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  isFarmer ? Icons.agriculture : Icons.home,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  isFarmer ? 'Pickup' : 'Drop',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: isFarmer ? Colors.blue : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return markers;
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.green),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Address info
            Row(
              children: [
                Icon(
                  _isHeadingToFarmer ? Icons.agriculture : Icons.home,
                  color: _isHeadingToFarmer ? Colors.blue : Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _destinationName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        _destinationAddress,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _destination != null
                        ? () => NavigationHelper.openExternalNavigation(
                              destinationLatitude: _destination!.latitude,
                              destinationLongitude: _destination!.longitude,
                              destinationLabel: _destinationName,
                            )
                        : null,
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Open in Maps'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _locationService.stopTracking();
                      context.pop();
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Arrived'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
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
