import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models.dart';
import '../data/content_scope.dart';
import '../data/passport_repository.dart';
import '../theme.dart';
import 'route_map.dart';

/// Opens the "Get directions" placeholder for a place.
///
/// Real turn-by-turn Google Maps navigation (with the user's live location)
/// will render here once Maps API credentials are added. For now this shows a
/// static from → to plan plus the matching ride/fare guide, and can hand off
/// to the Google Maps website/app via a keyless maps URL (no credentials
/// required).
Future<void> showDirections(BuildContext context, Place place) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.cream,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _DirectionsSheet(place: place),
  );
}

class _DirectionsSheet extends StatelessWidget {
  final Place place;
  const _DirectionsSheet({required this.place});

  CommuteRoute? _matchingRoute(List<CommuteRoute> routes) {
    for (final r in routes) {
      if (r.to.toLowerCase().contains(place.name.split(' ').first.toLowerCase())) {
        return r;
      }
    }
    return null;
  }

  Future<void> _openInMaps() async {
    // Keyless Google Maps directions URL — works without API credentials.
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${Uri.encodeComponent(place.mapQuery)}'
      '&travelmode=transit',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final route = _matchingRoute(ContentScope.of(context).routes);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text('Directions to', style: t.bodyMedium),
          const SizedBox(height: 2),
          Text(place.name, style: t.headlineSmall?.copyWith(fontSize: 24)),
          const SizedBox(height: 18),

          // Live map: OSM tiles + GPS + road route (free, keyless). Falls
          // back to a destination-only pin when location is unavailable.
          if (place.hasCoordinates)
            RouteMap(place: place)
          else
            _MapPlaceholder(area: place.area),
          const SizedBox(height: 12),

          // Suroy Passport check-in — only stamps when physically nearby.
          if (place.hasCoordinates) ...[
            _CheckInButton(place: place),
            const SizedBox(height: 12),
          ],

          // From -> To
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _endpoint(
                    Icons.my_location, 'Your location', 'Detected via GPS',
                    dashed: true),
                const Padding(
                  padding: EdgeInsets.only(left: 11),
                  child: SizedBox(
                    height: 22,
                    child: VerticalDivider(
                        color: AppColors.line, thickness: 2, width: 2),
                  ),
                ),
                _endpoint(Icons.place, place.name, place.area),
              ],
            ),
          ),
          const SizedBox(height: 18),

          if (route != null) ...[
            Text('How to get there', style: t.titleLarge?.copyWith(fontSize: 18)),
            const SizedBox(height: 10),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Pill(route.mode,
                          icon: route.modeIcon,
                          bg: AppColors.chip,
                          fg: AppColors.rust),
                      Pill(route.fare,
                          icon: Icons.payments,
                          bg: AppColors.priceBg,
                          fg: AppColors.priceInk),
                      Pill(route.time, icon: Icons.schedule),
                    ],
                  ),
                  const SizedBox(height: 14),
                  for (int i = 0; i < route.steps.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _stepDot(i + 1),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(route.steps[i], style: t.bodyLarge)),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.chip,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            size: 18, color: AppColors.rust),
                        const SizedBox(width: 8),
                        Expanded(child: Text(route.tip, style: t.bodyMedium)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          FilledButton.icon(
            onPressed: _openInMaps,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.rust,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999)),
            ),
            icon: const Icon(Icons.map_outlined),
            label: const Text('Open in Google Maps'),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              place.hasCoordinates
                  ? 'Map by OpenStreetMap · road distance and time are '
                      'approximate.'
                  : 'Map preview unavailable for this place — use the Google '
                      'Maps hand-off above.',
              style: t.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _endpoint(IconData icon, String title, String sub,
      {bool dashed = false}) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.rust),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.ink)),
            Text(sub, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _stepDot(int n) => Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
            color: AppColors.chip, shape: BoxShape.circle),
        child: Text('$n',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.chipInk)),
      );
}

class _MapPlaceholder extends StatelessWidget {
  final String area;
  const _MapPlaceholder({required this.area});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEFE7D6), Color(0xFFE7DCC7)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map, size: 40, color: AppColors.rust),
          const SizedBox(height: 8),
          Text('Map preview · $area',
              style: const TextStyle(
                  color: AppColors.ink, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          const Text('Google Maps placeholder',
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      ),
    );
  }
}

/// "Check in" for the Suroy Passport — stamps only when the user is
/// physically within the check-in radius of the place.
class _CheckInButton extends StatefulWidget {
  final Place place;
  const _CheckInButton({required this.place});

  @override
  State<_CheckInButton> createState() => _CheckInButtonState();
}

class _CheckInButtonState extends State<_CheckInButton> {
  final _repo = PassportRepository();
  bool _stamped = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _repo.isCheckedIn(widget.place.id).then((v) {
      if (mounted && v) setState(() => _stamped = true);
    });
  }

  Future<void> _checkIn() async {
    setState(() => _busy = true);
    final result = await _repo.tryCheckIn(widget.place);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _stamped = result.status == CheckInStatus.stamped ||
          result.status == CheckInStatus.alreadyStamped;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(result.message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_stamped) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.priceBg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified, size: 19, color: AppColors.priceInk),
            SizedBox(width: 8),
            Text('In your Suroy Passport',
                style: TextStyle(
                    color: AppColors.priceInk, fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: _busy ? null : _checkIn,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.rust,
        side: const BorderSide(color: AppColors.rust),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      icon: _busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.approval, size: 19),
      label: Text(_busy ? 'Checking your location…' : 'Check in — stamp this place'),
    );
  }
}
