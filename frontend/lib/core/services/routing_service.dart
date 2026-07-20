import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../constants/app_constants.dart';

/// Abstraction for route calculation.
/// Uses OSRM API by default, configurable via AppConstants.routingBaseUrl.
/// Returns route polyline, distance, and duration.
class RoutingService {
  final String _baseUrl;

  RoutingService({String? baseUrl}) : _baseUrl = baseUrl ?? AppConstants.routingBaseUrl;

  /// Fetch a driving route between [origin] and [destination].
  /// Returns a [RouteResult] with polyline points, distance, and duration.
  Future<RouteResult?> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/route/v1/driving/'
        '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}'
        '?overview=full&geometries=geojson&steps=true',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 200) {
        debugPrint('[RoutingService] HTTP ${response.statusCode}: ${response.body}');
        return null;
      }

      final data = json.decode(response.body);

      if (data['code'] != 'Ok' || data['routes'] == null || data['routes'].isEmpty) {
        debugPrint('[RoutingService] No route found');
        return null;
      }

      final route = data['routes'][0];
      final geometry = route['geometry'];
      final distance = route['distance'] as num; // meters
      final duration = route['duration'] as num; // seconds

      // Decode GeoJSON coordinates
      final coordinates = geometry['coordinates'] as List;
      final points = coordinates
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();

      return RouteResult(
        points: points,
        distanceMeters: distance.toDouble(),
        durationSeconds: duration.toDouble(),
      );
    } catch (e) {
      debugPrint('[RoutingService] Error fetching route: $e');
      return null;
    }
  }
}

class RouteResult {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;

  RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  Duration get duration => Duration(seconds: durationSeconds.round());

  String get formattedDistance => AppConstants.formatDistance(distanceMeters);
  String get formattedDuration => AppConstants.formatDuration(duration);
}
