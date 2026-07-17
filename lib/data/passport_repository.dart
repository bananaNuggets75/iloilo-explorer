import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';
import 'location_helper.dart';

/// The Suroy Passport — GPS-verified check-in stamps, badges and a
/// fare-saved counter. Entirely local and anonymous: shared_preferences on
/// this device, no accounts, no payment, no new services.

/// How close (meters) you must be to stamp a place. Generous because the
/// pilot pins are approximate.
const checkInRadiusMeters = 500.0;

/// Rough taxi/ride-hail cost of a cross-city trip, used for the
/// "saved vs taxi" counter. Illustrative pilot figure.
const taxiEstimatePesos = 150;

enum CheckInStatus { stamped, alreadyStamped, tooFar, noLocation, noCoords }

class CheckInResult {
  final CheckInStatus status;
  final double distanceMeters;
  const CheckInResult(this.status, [this.distanceMeters = 0]);

  String get message => switch (status) {
        CheckInStatus.stamped => 'Stamped! Added to your Suroy Passport.',
        CheckInStatus.alreadyStamped => 'Already in your passport.',
        CheckInStatus.tooFar => distanceMeters >= 1000
            ? "You're ${(distanceMeters / 1000).toStringAsFixed(1)} km away — "
                'get closer to stamp this place.'
            : "You're ${distanceMeters.round()} m away — get closer to stamp "
                'this place.',
        CheckInStatus.noLocation =>
          'Location is off — enable it to stamp places.',
        CheckInStatus.noCoords => 'This place has no map pin yet.',
      };
}

class PassportBadge {
  final String name;
  final String description;
  final IconData icon;
  final bool earned;
  final String progress;

  const PassportBadge({
    required this.name,
    required this.description,
    required this.icon,
    required this.earned,
    required this.progress,
  });
}

class PassportRepository {
  static const _checkInsKey = 'suroy_checkins';
  static const _ridesKey = 'suroy_rides';
  static const _savedKey = 'suroy_fare_saved';

  Future<Map<String, DateTime>> checkIns() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_checkInsKey);
    if (raw == null) return {};
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return map.map((k, v) =>
          MapEntry(k, DateTime.tryParse('$v') ?? DateTime.now()));
    } catch (_) {
      return {};
    }
  }

  Future<bool> isCheckedIn(String placeId) async =>
      (await checkIns()).containsKey(placeId);

  /// GPS-verified stamp: only succeeds within [checkInRadiusMeters] of the
  /// place. That physical constraint is the whole point of the passport.
  Future<CheckInResult> tryCheckIn(Place place) async {
    if (!place.hasCoordinates) {
      return const CheckInResult(CheckInStatus.noCoords);
    }
    final existing = await checkIns();
    if (existing.containsKey(place.id)) {
      return const CheckInResult(CheckInStatus.alreadyStamped);
    }

    final pos = await _currentPosition();
    if (pos == null) return const CheckInResult(CheckInStatus.noLocation);

    final distance = Geolocator.distanceBetween(
        pos.latitude, pos.longitude, place.lat, place.lng);
    if (distance > checkInRadiusMeters) {
      return CheckInResult(CheckInStatus.tooFar, distance);
    }

    existing[place.id] = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _checkInsKey,
      json.encode(
          existing.map((k, v) => MapEntry(k, v.toIso8601String()))),
    );
    return CheckInResult(CheckInStatus.stamped, distance);
  }

  // Check-ins tolerate a slightly stale fix (people move at walking speed
  // and the radius is generous), so a 1-minute cache keeps stamping snappy.
  Future<Position?> _currentPosition() => fastPosition(
        accuracy: LocationAccuracy.high,
        maxAge: const Duration(minutes: 1),
      );

  /// Log a jeepney ride from a route card; returns (pesos saved this ride,
  /// cumulative saved).
  Future<(int, int)> logRide(String fareLabel) async {
    final m = RegExp(r'(\d+)').firstMatch(fareLabel);
    final fare = m != null ? int.parse(m.group(1)!) : 13;
    final saved = (taxiEstimatePesos - fare).clamp(0, taxiEstimatePesos);
    final prefs = await SharedPreferences.getInstance();
    final rides = (prefs.getInt(_ridesKey) ?? 0) + 1;
    final total = (prefs.getInt(_savedKey) ?? 0) + saved;
    await prefs.setInt(_ridesKey, rides);
    await prefs.setInt(_savedKey, total);
    return (saved, total);
  }

  Future<(int rides, int saved)> rideStats() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getInt(_ridesKey) ?? 0, prefs.getInt(_savedKey) ?? 0);
  }

  /// Badges are computed from check-ins against place categories, so they
  /// keep working when places come from Supabase.
  List<PassportBadge> badges(
      List<Place> places, Map<String, DateTime> stamps) {
    int inCategories(Set<PlaceCategory> cats) => places
        .where((p) => cats.contains(p.category) && stamps.containsKey(p.id))
        .length;
    int total(Set<PlaceCategory> cats) =>
        places.where((p) => cats.contains(p.category)).length;

    PassportBadge badge(String name, String desc, IconData icon, int have,
            int need) =>
        PassportBadge(
          name: name,
          description: desc,
          icon: icon,
          earned: have >= need,
          progress: '${have.clamp(0, need)}/$need',
        );

    return [
      badge('First Suroy', 'Stamp your first place', Icons.flag,
          stamps.length, 1),
      badge(
          'Heritage Hunter',
          'Stamp 3 heritage sites & landmarks',
          Icons.account_balance,
          inCategories({PlaceCategory.heritage, PlaceCategory.landmark}),
          3),
      badge('Museum Buff', 'Stamp 2 museums', Icons.museum,
          inCategories({PlaceCategory.museum}), 2),
      badge('Nature Roamer', 'Stamp 2 nature spots', Icons.landscape,
          inCategories({PlaceCategory.nature}), 2),
      badge('Gem Finder', 'Stamp a hidden gem', Icons.diamond,
          inCategories({PlaceCategory.hiddenGem}), 1),
      badge('City Collector', 'Stamp every place in the pilot',
          Icons.workspace_premium, stamps.length,
          places.isEmpty ? 8 : total(PlaceCategory.values.toSet())),
    ];
  }
}
