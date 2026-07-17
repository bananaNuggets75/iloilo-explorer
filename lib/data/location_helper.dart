import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

/// Fast, permission-safe position lookup shared by the map and the passport.
///
/// Speed tricks:
///  * Web: accept a browser-cached position up to [maxAge] old instead of
///    forcing a cold Wi-Fi/IP lookup every call (which can take 2–10 s).
///  * Mobile: return the OS's last known position instantly when it's
///    available, then let callers refresh if they need precision.
///  * Shorter timeout (8 s) so the UI never hangs on a slow fix.
Future<Position?> fastPosition({
  LocationAccuracy accuracy = LocationAccuracy.medium,
  Duration maxAge = const Duration(minutes: 2),
}) async {
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

    // Instant path on mobile: the OS usually has a recent fix already.
    if (!kIsWeb) {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null &&
          DateTime.now().difference(last.timestamp) < maxAge) {
        return last;
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
    return await Geolocator.getCurrentPosition(locationSettings: settings);
  } catch (_) {
    return null;
  }
}
