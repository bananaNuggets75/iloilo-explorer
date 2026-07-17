import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';

/// Builds a personal day itinerary from the places a user picks.
///
/// Pure client-side logic, no services: orders stops with a nearest-neighbor
/// walk starting from the city plaza, assigns time slots, and attaches the
/// matching jeepney route + fare when our ride data covers the leg.

/// Iloilo City Proper plaza — the default starting point of a day.
const _cityPlaza = LatLng(10.6969, 122.5644);

/// A place is "far" when a jeep won't cut it (Gigantes, Garin Farm...).
const _farTripKm = 30.0;

class TripStop {
  final String time;
  final Place place;
  final CommuteRoute? ride;
  final int fare; // pesos for this leg
  final bool farTrip;

  const TripStop({
    required this.time,
    required this.place,
    this.ride,
    required this.fare,
    this.farTrip = false,
  });
}

class TripPlan {
  final List<TripStop> stops;
  final int startMinutes;
  final int endMinutes;

  const TripPlan({
    required this.stops,
    required this.startMinutes,
    required this.endMinutes,
  });

  int get totalFare => stops.fold(0, (s, x) => s + x.fare);
  bool get hasFarTrip => stops.any((s) => s.farTrip);
  String get endLabel => formatMinutes(endMinutes);
}

String formatMinutes(int minutes) {
  final h24 = (minutes ~/ 60) % 24;
  final m = minutes % 60;
  final suffix = h24 >= 12 ? 'PM' : 'AM';
  final h = h24 % 12 == 0 ? 12 : h24 % 12;
  final mm = m.toString().padLeft(2, '0');
  return '$h:$mm $suffix';
}

class TripPlanner {
  static const dwellMinutes = 75; // time spent enjoying a stop
  static const travelMinutes = 25; // typical jeep hop between stops
  static const farTravelMinutes = 180; // bus leg to a far trip
  static const defaultFare = 13; // jeep minimum when no route matches

  static const _idsKey = 'suroy_trip_place_ids';
  static const _startKey = 'suroy_trip_start_minutes';

  final _distance = const Distance();

  /// Orders [selected] by nearest-neighbor from the plaza and lays out the
  /// day from [startMinutes] (minutes since midnight).
  TripPlan build({
    required List<Place> selected,
    required List<CommuteRoute> routes,
    int startMinutes = 8 * 60,
  }) {
    // Far trips go last so they don't hijack the whole morning ordering.
    final near = selected.where((p) => !_isFar(p)).toList();
    final far = selected.where(_isFar).toList();

    final ordered = <Place>[];
    var cursor = _cityPlaza;
    final pool = [...near];
    while (pool.isNotEmpty) {
      pool.sort((a, b) => _km(cursor, a).compareTo(_km(cursor, b)));
      final next = pool.removeAt(0);
      ordered.add(next);
      if (next.hasCoordinates) cursor = LatLng(next.lat, next.lng);
    }
    ordered.addAll(far);

    final stops = <TripStop>[];
    var clock = startMinutes;
    for (final place in ordered) {
      final farTrip = _isFar(place);
      final ride = _matchRoute(place, routes);
      stops.add(TripStop(
        time: formatMinutes(clock),
        place: place,
        ride: ride,
        fare: _fareOf(ride),
        farTrip: farTrip,
      ));
      clock += dwellMinutes + (farTrip ? farTravelMinutes : travelMinutes);
    }
    return TripPlan(
        stops: stops, startMinutes: startMinutes, endMinutes: clock);
  }

  bool _isFar(Place p) =>
      p.hasCoordinates &&
      _kmLL(_cityPlaza, LatLng(p.lat, p.lng)) > _farTripKm;

  double _km(LatLng a, Place p) => p.hasCoordinates
      ? _distance.as(LengthUnit.Kilometer, a, LatLng(p.lat, p.lng))
      : 5; // unknown pins sort mid-pack

  double _kmLL(LatLng a, LatLng b) =>
      _distance.as(LengthUnit.Kilometer, a, b);

  CommuteRoute? _matchRoute(Place place, List<CommuteRoute> routes) {
    final key = place.name.split(' ').first.toLowerCase();
    for (final r in routes) {
      if (r.to.toLowerCase().contains(key)) return r;
    }
    return null;
  }

  int _fareOf(CommuteRoute? ride) {
    if (ride == null) return defaultFare;
    final m = RegExp(r'(\d+)').firstMatch(ride.fare);
    return m != null ? int.parse(m.group(1)!) : defaultFare;
  }

  // --- persistence -------------------------------------------------------

  Future<void> save(List<String> placeIds, int startMinutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_idsKey, placeIds);
    await prefs.setInt(_startKey, startMinutes);
  }

  Future<(List<String>, int)?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_idsKey);
    if (ids == null || ids.isEmpty) return null;
    return (ids, prefs.getInt(_startKey) ?? 8 * 60);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_idsKey);
    await prefs.remove(_startKey);
  }
}
