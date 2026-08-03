import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../data/location_helper.dart';
import '../data/routing_service.dart';
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
  LocationFailure _failure = LocationFailure.none;

  LatLng get _dest => LatLng(widget.place.lat, widget.place.lng);

  @override
  void initState() {
    super.initState();
    _locateAndRoute();
  }

  Future<void> _locateAndRoute() async {
    setState(() {
      _status = 'Locating you…';
      _failure = LocationFailure.none;
    });
    final result = await fastPosition(accuracy: LocationAccuracy.medium);
    if (!mounted) return;
    if (!result.ok) {
      setState(() {
        _failure = result.failure;
        _status = result.hint;
      });
      return;
    }
    setState(() {
      _user = LatLng(result.position!.latitude, result.position!.longitude);
      _status = 'Drawing the route…';
    });
    await _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    final u = _user;
    if (u == null) return;
    // Road geometry from OSRM (free, keyless). The jeepney intelligence stays
    // in our own route data below the map.
    final route = await RoutingService().fetch(u, _dest);
    if (!mounted) return;
    if (route == null) {
      setState(() => _status = 'Route line unavailable — pins only');
      return;
    }
    setState(() {
      _path = route.points;
      _km = route.km;
      _mins = route.minutes;
      _status = '';
    });
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
              right: 10,
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16),
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
            ),
            // Fix-it actions when the lookup failed
            if (_failure != LocationFailure.none)
              Positioned(
                bottom: 10,
                left: 10,
                child: Row(children: [
                  _actionChip('Retry', Icons.refresh, _locateAndRoute),
                  if (!kIsWeb) ...[
                    const SizedBox(width: 8),
                    _actionChip('Settings', Icons.settings, () async {
                      await openLocationFix(_failure);
                    }),
                  ],
                ]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionChip(String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: AppColors.rust,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5)),
          ]),
        ),
      ),
    );
  }
}
