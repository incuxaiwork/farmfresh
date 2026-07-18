import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../constants/app_constants.dart';

/// Abstraction for device location services.
/// Handles permissions, GPS state, and location streams.
class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  final StreamController<Position> _locationController =
      StreamController<Position>.broadcast();

  /// Stream of position updates (broadcast).
  Stream<Position> get onLocationUpdate => _locationController.stream;

  /// Check and request location permissions.
  /// Returns the permission status.
  Future<LocationPermissionStatus> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.gpsDisabled;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationPermissionStatus.denied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    }

    return LocationPermissionStatus.granted;
  }

  /// Get the current position (single read).
  Future<Position?> getCurrentPosition() async {
    try {
      final status = await checkAndRequestPermission();
      if (status != LocationPermissionStatus.granted) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
    } catch (e) {
      debugPrint('[LocationService] getCurrentPosition error: $e');
      return null;
    }
  }

  /// Start continuous location tracking with throttling.
  void startTracking({
    int intervalSeconds = AppConstants.locationUpdateIntervalSeconds,
    double distanceFilter = AppConstants.locationUpdateDistanceMeters,
  }) {
    stopTracking();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50,
      timeLimit: Duration(seconds: 15),
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (position) {
        _locationController.add(position);
      },
      onError: (e) {
        debugPrint('[LocationService] Position stream error: $e');
      },
    );
  }

  /// Stop location tracking.
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Open device location settings.
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Open app settings (for permanently denied permission).
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  void dispose() {
    stopTracking();
    _locationController.close();
  }
}

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  gpsDisabled,
}
