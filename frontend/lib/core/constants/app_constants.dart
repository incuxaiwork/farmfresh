
class AppConstants {
  // NestJS Backend API Base URL — loaded from build-time environment.
  // Use --dart-define=API_BASE_URL=http://your-server:3000/api/v1
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://farmfresh-production-01f2.up.railway.app/api/v1',
  );

  static const String socketBaseUrl = String.fromEnvironment(
    'SOCKET_BASE_URL',
    defaultValue: 'https://farmfresh-production-01f2.up.railway.app',
  );

  // Map tile provider URL (OpenStreetMap by default, configurable via build args)
  static const String mapTileUrl = String.fromEnvironment(
    'MAP_TILE_URL',
    defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  // Routing provider URL (OSRM public demo by default, configurable via build args)
  // IMPORTANT: Public OSRM demo servers have rate limits.
  // For production, self-host OSRM or use a paid routing provider.
  static const String routingBaseUrl = String.fromEnvironment(
    'ROUTING_BASE_URL',
    defaultValue: 'https://router.project-osrm.org',
  );

  // Attribution text for map tiles
  static const String mapAttribution =
      '© OpenStreetMap contributors';

  // Location tracking intervals
  static const int locationUpdateIntervalSeconds = 10;
  static const double locationUpdateDistanceMeters = 50.0;

  // Route recalculation thresholds
  static const double routeRecalculationDistanceMeters = 200.0;

  // ETA format helper
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
