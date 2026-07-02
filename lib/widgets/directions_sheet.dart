import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models.dart';
import '../data/content_scope.dart';
import '../theme.dart';

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

          // Map placeholder (live Google Maps goes here once credentials exist).
          _MapPlaceholder(area: place.area),
          const SizedBox(height: 18),

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
              'Live in-app navigation is a placeholder pending Maps credentials.',
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
