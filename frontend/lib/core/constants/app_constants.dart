import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class AppConstants {
  // ── Platform-resolved backend URL ──────────────────────────────────
  //
  // Priority:
  //   1. --dart-define=API_BASE_URL=...   (always wins)
  //   2. Platform-aware auto-detection:
  //        • Web browser          → http://localhost:3000/api/v1
  //        • Android emulator     → http://10.0.2.2:3000/api/v1
  //        • iOS simulator        → http://localhost:3000/api/v1
  //        • Physical device      → override via --dart-define
  //
  static final String apiBaseUrl = _resolveApiUrl();
  static final String socketBaseUrl = _resolveSocketUrl();

  static String _resolveApiUrl() {
    const env = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (env.isNotEmpty) return env;
    const port = 3000;
    if (kIsWeb) return 'http://localhost:$port/api/v1';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:$port/api/v1';
    }
    return 'http://localhost:$port/api/v1';
  }

  static String _resolveSocketUrl() {
    const env = String.fromEnvironment('SOCKET_BASE_URL', defaultValue: '');
    if (env.isNotEmpty) return env;
    const port = 3000;
    if (kIsWeb) return 'http://localhost:$port';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:$port';
    }
    return 'http://localhost:$port';
  }

  // ── External service URLs ──────────────────────────────────────────

  static const String mapTileUrl = String.fromEnvironment(
    'MAP_TILE_URL',
    defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  static const String routingBaseUrl = String.fromEnvironment(
    'ROUTING_BASE_URL',
    defaultValue: 'https://router.project-osrm.org',
  );

  static const String mapAttribution = '© OpenStreetMap contributors';

  // ── Location & routing constants ───────────────────────────────────

  static const int locationUpdateIntervalSeconds = 10;
  static const double locationUpdateDistanceMeters = 50.0;
  static const double routeRecalculationDistanceMeters = 200.0;

  // ── Helpers ────────────────────────────────────────────────────────

  static String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}min';
    }
    return '${duration.inMinutes} min';
  }

  static String formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.round()} m';
  }
}
