// Unit tests: itinerary ordering, timing and fare totals.

import 'package:flutter_test/flutter_test.dart';
import 'package:iloilo_travel_buddy/data/trip_planner.dart';
import 'package:iloilo_travel_buddy/models.dart';

Place _p(String id, double lat, double lng) => Place(
      id: id,
      name: id,
      category: PlaceCategory.heritage,
      area: '',
      rating: 4,
      reviews: 1,
      description: '',
      bestTime: '',
      tip: '',
      mapQuery: '',
      lat: lat,
      lng: lng,
    );

void main() {
  final planner = TripPlanner();

  test('formatMinutes renders 12-hour times', () {
    expect(formatMinutes(8 * 60), '8:00 AM');
    expect(formatMinutes(12 * 60), '12:00 PM');
    expect(formatMinutes(13 * 60 + 30), '1:30 PM');
    expect(formatMinutes(0), '12:00 AM');
  });

  test('build lays out stops in time order from the start', () {
    final plan = planner.build(
      selected: [_p('a', 10.70, 122.56), _p('b', 10.72, 122.55)],
      routes: const [],
      startMinutes: 8 * 60,
    );
    expect(plan.stops, hasLength(2));
    expect(plan.stops.first.time, '8:00 AM');
    // second stop is dwell + travel later
    expect(plan.stops[1].time, formatMinutes(8 * 60 + 75 + 25));
    expect(plan.endMinutes, greaterThan(plan.startMinutes));
  });

  test('far trips (Gigantes-distance) are flagged and ordered last', () {
    final near = _p('near', 10.70, 122.56);
    final far = _p('gigantes', 11.60, 123.34); // >30 km from plaza
    final plan = planner.build(selected: [far, near], routes: const []);
    expect(plan.stops.last.place.id, 'gigantes');
    expect(plan.stops.last.farTrip, isTrue);
    expect(plan.hasFarTrip, isTrue);
  });

  test('totalFare sums per-leg fares (default jeep minimum with no routes)', () {
    final plan = planner.build(
      selected: [_p('a', 10.70, 122.56), _p('b', 10.71, 122.57)],
      routes: const [],
    );
    expect(plan.totalFare, TripPlanner.defaultFare * 2);
  });
}
