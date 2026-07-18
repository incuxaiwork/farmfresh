import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../constants/app_constants.dart';
import '../services/api_client.dart';
import '../services/location_service.dart';

/// Manages delivery partner location tracking during active deliveries.
/// Throttles GPS updates to reduce battery and network usage.
/// Sends location to backend which broadcasts via Socket.IO.
class DeliveryTrackingService {
  final LocationService _locationService;
  final ApiClient _apiClient;
  Timer? _throttleTimer;
  Position? _lastSentPosition;
  String? _activeDeliveryId;
  bool _isTracking = false;

  DeliveryTrackingService(this._locationService, this._apiClient);

  bool get isTracking => _isTracking;
  String? get activeDeliveryId => _activeDeliveryId;

  /// Start tracking location for a specific delivery.
  void startTracking(String deliveryId) {
    if (_isTracking && _activeDeliveryId == deliveryId) return;

    _activeDeliveryId = deliveryId;
    _isTracking = true;
    _lastSentPosition = null;

    _locationService.startTracking(
      intervalSeconds: AppConstants.locationUpdateIntervalSeconds,
      distanceFilter: AppConstants.locationUpdateDistanceMeters,
    );

    _throttleTimer?.cancel();
    _throttleTimer = Timer.periodic(
      const Duration(seconds: AppConstants.locationUpdateIntervalSeconds),
      (_) => _sendLocationIfNeeded(),
    );

    debugPrint('[DeliveryTracking] Started tracking for delivery $deliveryId');
  }

  /// Stop tracking and clean up.
  void stopTracking() {
    _isTracking = false;
    _activeDeliveryId = null;
    _lastSentPosition = null;
    _throttleTimer?.cancel();
    _throttleTimer = null;
    _locationService.stopTracking();
    debugPrint('[DeliveryTracking] Stopped tracking');
  }

  /// Called when a new position is available from LocationService.
  /// Only sends if the driver moved a meaningful distance.
  void onLocationUpdate(Position position) {
    if (!_isTracking || _activeDeliveryId == null) return;

    if (_lastSentPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastSentPosition!.latitude,
        _lastSentPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      // Only send if moved more than the threshold
      if (distance < AppConstants.locationUpdateDistanceMeters) {
        return;
      }
    }

    _sendLocation(position);
  }

  /// Throttled send - called periodically to catch updates that might
  /// not trigger the distance filter.
  void _sendLocationIfNeeded() {
    if (!_isTracking || _activeDeliveryId == null) return;

    _locationService.getCurrentPosition().then((position) {
      if (position != null) {
        _sendLocation(position);
      }
    });
  }

  /// Send location to the backend API.
  Future<void> _sendLocation(Position position) async {
    if (_activeDeliveryId == null) return;

    _lastSentPosition = position;

    try {
      await _apiClient.dio.patch(
        '/delivery/$_activeDeliveryId/location',
        data: {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
      );
    } catch (e) {
      debugPrint('[DeliveryTracking] Failed to send location: $e');
    }
  }

  void dispose() {
    stopTracking();
  }
}

/// Riverpod provider for DeliveryTrackingService.
final deliveryTrackingServiceProvider = Provider<DeliveryTrackingService>((ref) {
  final locationService = LocationService();
  final apiClient = ref.watch(apiClientProvider);
  final service = DeliveryTrackingService(locationService, apiClient);
  ref.onDispose(() => service.dispose());
  return service;
});
