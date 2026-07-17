import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

/// Why a location lookup produced no position.
enum LocationFailure { none, serviceOff, denied, deniedForever, unavailable }

class LocationResult {
  final Position? position;
  final LocationFailure failure;
  const LocationResult(this.position, this.failure);

  bool get ok => position != null;

  /// Short, actionable explanation for the user.
  String get hint => switch (failure) {
        LocationFailure.none => '',
        LocationFailure.serviceOff =>
          'Location is turned off on this device.',
        LocationFailure.denied || LocationFailure.deniedForever => kIsWeb
            ? 'Location is blocked for this site — tap the lock icon in the '
                'address bar, allow Location, then retry.'
            : 'Location permission is blocked — enable it in Settings.',
        LocationFailure.unavailable =>
          'Could not get your location — try again.',
      };
}

/// Fast, permission-safe position lookup shared by the map and the passport.
///
/// Speed tricks:
///  * Web: accept a browser-cached position up to [maxAge] old instead of
///    forcing a cold Wi-Fi/IP lookup every call (which can take 2–10 s).
///  * Mobile: return the OS's last known position instantly when it's
///    available, then let callers refresh if they need precision.
///  * Shorter timeout (8 s) so the UI never hangs on a slow fix.
Future<LocationResult> fastPosition({
  LocationAccuracy accuracy = LocationAccuracy.medium,
  Duration maxAge = const Duration(minutes: 2),
}) async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const LocationResult(null, LocationFailure.serviceOff);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return const LocationResult(null, LocationFailure.deniedForever);
    }
    if (permission == LocationPermission.denied) {
      return const LocationResult(null, LocationFailure.denied);
    }

    // Instant path on mobile: the OS usually has a recent fix already.
    if (!kIsWeb) {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null &&
          DateTime.now().difference(last.timestamp) < maxAge) {
        return LocationResult(last, LocationFailure.none);
      }
    }

    final settings = kIsWeb
        ? WebSettings(
            accuracy: accuracy,
            maximumAge: maxAge,
            timeLimit: const Duration(seconds: 8),
          )
        : LocationSettings(
            accuracy: accuracy,
            timeLimit: const Duration(seconds: 8),
          );
    final pos =
        await Geolocator.getCurrentPosition(locationSettings: settings);
    return LocationResult(pos, LocationFailure.none);
  } catch (_) {
    return const LocationResult(null, LocationFailure.unavailable);
  }
}

/// Opens the relevant settings screen on mobile; no-op on web (browsers do
/// not allow sites to open settings — the user must use the address bar).
Future<void> openLocationFix(LocationFailure failure) async {
  if (kIsWeb) return;
  try {
    if (failure == LocationFailure.serviceOff) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
    }
  } catch (_) {/* best effort */}
}
