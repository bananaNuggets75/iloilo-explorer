import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models.dart';
import '../theme.dart';

/// Live in-app map for the directions sheet — the Grab-style view.
///
/// Free and keyless end-to-end: OpenStreetMap tiles render the map,
/// the device GPS (with permission) marks where you are, and the public
/// OSRM router draws the road path with distance/ETA. Degrades gracefully:
/// no permission or no network still shows the destination pin.
class RouteMap extends StatefulWidget {
  final Place place;
  const RouteMap({super.key, required this.place});

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  LatLng? _user;
  List<LatLng> _path = const [];
  double? _km;
  double? _mins;
  String _status = 'Locating you…';

  LatLng get _dest => LatLng(widget.place.lat, widget.place.lng);

  @override
  void initState() {
    super.initState();
    _locateAndRoute();
  }

  Future<void> _locateAndRoute() async {
    final pos = await _currentPosition();
    if (!mounted) return;
    if (pos == null) {
      setState(() => _status = 'Location off — showing the destination');
      return;
    }
    setState(() {
      _user = LatLng(pos.latitude, pos.longitude);
      _status = 'Drawing the route…';
    });
    await _fetchRoute();
  }

  Future<Position?> _currentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _fetchRoute() async {
    final u = _user;
    if (u == null) return;
    try {
      // Public OSRM demo server — free, keyless. Road geometry only; the
      // jeepney intelligence stays in our own route data below the map.
      final url = 'https://router.project-osrm.org/route/v1/driving/'
          '${u.longitude},${u.latitude};${_dest.longitude},${_dest.latitude}'
          '?overview=full&geometries=geojson';
      final res =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) throw Exception('OSRM ${res.statusCode}');
      final body = json.decode(res.body) as Map<String, dynamic>;
      final route = (body['routes'] as List).first as Map<String, dynamic>;
      final coords = ((route['geometry']
              as Map<String, dynamic>)['coordinates'] as List)
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList(growable: false);
      if (!mounted) return;
      setState(() {
        _path = coords;
        _km = (route['distance'] as num).toDouble() / 1000;
        _mins = (route['duration'] as num).toDouble() / 60;
        _status = '';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _status = 'Route line unavailable — pins only');
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      Marker(
        point: _dest,
        width: 42,
        height: 42,
        alignment: Alignment.topCenter,
        child: const Icon(Icons.place, size: 42, color: AppColors.rust),
      ),
      if (_user != null)
        Marker(
          point: _user!,
          width: 22,
          height: 22,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A6FDB),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 6),
              ],
            ),
          ),
        ),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 230,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCameraFit: _user == null
                    ? CameraFit.coordinates(
                        coordinates: [_dest], padding: const EdgeInsets.all(48))
                    : CameraFit.coordinates(
                        coordinates: [_dest, _user!],
                        padding: const EdgeInsets.all(48),
                      ),
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'ph.suroyiloilo.app',
                ),
                if (_path.isNotEmpty)
                  PolylineLayer(polylines: [
                    Polyline(
                      points: _path,
                      strokeWidth: 5,
                      color: AppColors.rust,
                    ),
                  ]),
                MarkerLayer(markers: markers),
                const SimpleAttributionWidget(
                  source: Text('OpenStreetMap', style: TextStyle(fontSize: 10)),
                ),
              ],
            ),
            // Status / distance chip
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.line),
                ),
                child: Text(
                  _status.isNotEmpty
                      ? _status
                      : '${_km!.toStringAsFixed(_km! < 10 ? 1 : 0)} km · '
                          '~${_mins!.round()} min by road',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
