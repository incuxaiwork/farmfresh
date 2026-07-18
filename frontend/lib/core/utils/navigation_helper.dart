import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helper for opening external navigation (Google Maps).
class NavigationHelper {
  /// Open Google Maps navigation to the given coordinates.
  /// Falls back to browser if Maps app is not available.
  static Future<bool> openExternalNavigation({
    required double destinationLatitude,
    required double destinationLongitude,
    String? destinationLabel,
  }) async {
    final label = Uri.encodeComponent(destinationLabel ?? 'Destination');

    // Google Maps URL scheme works on both Android and iOS
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$destinationLatitude,$destinationLongitude'
      '&destination_placeid=$label'
      '&travelmode=driving',
    );

    // Try Google Maps app first
    if (await canLaunchUrl(googleMapsUrl)) {
      final launched = await launchUrl(
        googleMapsUrl,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return true;
    }

    // Fallback: try geo: scheme (Android)
    if (Platform.isAndroid) {
      final geoUrl = Uri.parse(
        'geo:$destinationLatitude,$destinationLongitude?q=$destinationLatitude,$destinationLongitude($label)',
      );
      if (await canLaunchUrl(geoUrl)) {
        return await launchUrl(
          geoUrl,
          mode: LaunchMode.externalApplication,
        );
      }
    }

    debugPrint('[NavigationHelper] Could not open external navigation');
    return false;
  }
}
