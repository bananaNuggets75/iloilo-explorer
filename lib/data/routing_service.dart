import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// A driving route: the polyline to draw plus distance and duration.
@immutable
class DrivingRoute {
  final List<LatLng> points;
  final double km;
  final double minutes;
  const DrivingRoute(this.points, this.km, this.minutes);
}

/// Fetches a road route between two points from the public OSRM demo server.
///
/// Free and keyless — OSRM returns *road* geometry only; the jeepney/fare
/// guidance stays in our own data. Isolated from the widget so it can be
/// unit/network-tested with a mock [http.Client]. Returns null on any
/// failure (offline, non-200, malformed body) so callers can fall back to
/// pins-only.
class RoutingService {
  final http.Client _client;
  final Duration timeout;
  RoutingService({http.Client? client, this.timeout = const Duration(seconds: 12)})
      : _client = client ?? http.Client();

  /// Builds the OSRM request URL (exposed for testing).
  static Uri osrmUrl(LatLng from, LatLng to) => Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
        '?overview=full&geometries=geojson',
      );

  /// Parses an OSRM response body into a [DrivingRoute] (exposed for testing).
  static DrivingRoute? parse(String body) {
    try {
      final json0 = json.decode(body) as Map<String, dynamic>;
      final routes = json0['routes'] as List?;
      if (routes == null || routes.isEmpty) return null;
      final route = routes.first as Map<String, dynamic>;
      final coords = ((route['geometry'] as Map<String, dynamic>)['coordinates']
              as List)
          .map((c) =>
              LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList(growable: false);
      if (coords.isEmpty) return null;
      return DrivingRoute(
        coords,
        (route['distance'] as num).toDouble() / 1000,
        (route['duration'] as num).toDouble() / 60,
      );
    } catch (_) {
      return null;
    }
  }

  Future<DrivingRoute?> fetch(LatLng from, LatLng to) async {
    try {
      final res = await _client.get(osrmUrl(from, to)).timeout(timeout);
      if (res.statusCode != 200) return null;
      return parse(res.body);
    } catch (_) {
      return null;
    }
  }
}
