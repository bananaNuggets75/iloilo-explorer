import 'package:flutter/material.dart';
import '../main.dart';
import '../theme.dart';
import '../data/seed_data.dart';
import '../models.dart';
import '../widgets/directions_sheet.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final nav = TabNav.of(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Hero(onExplore: () => nav.goTo(1), onFares: () => nav.goTo(3)),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FeatureGrid(),
              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('Featured spots',
                        style: t.headlineSmall?.copyWith(fontSize: 24)),
                  ),
                  TextButton(
                    onPressed: () => nav.goTo(1),
                    child: const Text('See all  →',
                        style: TextStyle(color: AppColors.rust)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final p in places.take(3)) ...[
                _FeaturedSpot(place: p),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 16),
              _statsRow(t),
              const SizedBox(height: 24),

              _CtaBanner(onView: () => nav.goTo(4)),
              const SizedBox(height: 28),
              const _Footer(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statsRow(TextTheme t) {
    Widget stat(String n, String l) => Expanded(
          child: SoftCard(
            padding: const EdgeInsets.symmetric(vertical: 22),
            child: Column(
              children: [
                Text(n,
                    style: t.headlineMedium
                        ?.copyWith(color: AppColors.rust, fontSize: 34)),
                const SizedBox(height: 4),
                Text(l, textAlign: TextAlign.center, style: t.bodyMedium),
              ],
            ),
          ),
        );
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          stat('${places.length}', 'Curated spots'),
          const SizedBox(width: 12),
          stat('${foods.length}', 'Local food picks'),
          const SizedBox(width: 12),
          stat('${routes.length}', 'Ride routes with fares'),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final VoidCallback onExplore;
  final VoidCallback onFares;
  const _Hero({required this.onExplore, required this.onFares});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF6C98A), Color(0xFFF3D9C2), Color(0xFFFBF6EC)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Pill('PILOT CITY · ILOILO',
              icon: Icons.explore, bg: AppColors.surface, fg: AppColors.rust),
          const SizedBox(height: 18),
          Text('Explore Iloilo like a local — spots, food, and how to get '
              'there.',
              style: t.displaySmall?.copyWith(fontSize: 40)),
          const SizedBox(height: 16),
          Text(
            'One companion for heritage sites, hidden eats, jeepney routes with '
            'fares, day plans, and tips from travelers who\'ve been there.',
            style: t.bodyLarge?.copyWith(color: AppColors.ink, fontSize: 16),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(
                onPressed: onExplore,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.rust,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
                ),
                child: const Text('Start exploring'),
              ),
              OutlinedButton(
                onPressed: onFares,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.line),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
                ),
                child: const Text('Ride & fare guide'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String body;
  final int tab;
  const _Feature(this.icon, this.title, this.body, this.tab);
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  static const _features = [
    _Feature(Icons.place, 'Places & hidden gems',
        'Heritage sites, nature trips and local-only spots.', 1),
    _Feature(Icons.ramen_dining, 'Local food',
        'Batchoy, pancit molo, inasal — where locals actually eat.', 2),
    _Feature(Icons.directions_bus, 'Commute & fares',
        'Which jeep to ride, transfers, and honest fare estimates.', 3),
    _Feature(Icons.map, 'Day itineraries',
        'Ready-made plans with routes and fares built in.', 4),
    _Feature(Icons.forum, 'Traveler tips',
        'Real advice from travelers and Ilonggo locals.', 5),
    _Feature(Icons.celebration, 'Events',
        'Dinagyang, Paraw Regatta, food crawls and night markets.', 5),
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final nav = TabNav.of(context);
    return LayoutBuilder(builder: (context, c) {
      const spacing = 12.0;
      final cols = c.maxWidth > 680 ? 3 : (c.maxWidth > 440 ? 2 : 1);
      final cardW = (c.maxWidth - spacing * (cols - 1)) / cols;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final f in _features)
            SizedBox(
              width: cardW,
              child: SoftCard(
                onTap: () => nav.goTo(f.tab),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _iconTile(f.icon),
                    const SizedBox(height: 16),
                    Text(f.title, style: t.titleMedium),
                    const SizedBox(height: 6),
                    Text(f.body, style: t.bodyMedium),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }
}

Widget _iconTile(IconData icon) => Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.chip,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: AppColors.rust, size: 24),
    );

class _FeaturedSpot extends StatelessWidget {
  final Place place;
  const _FeaturedSpot({required this.place});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SoftCard(
      onTap: () => showDirections(context, place),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconTile(place.category.icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place.name, style: t.titleMedium),
                const SizedBox(height: 2),
                Row(children: [
                  Text('${place.area} · ', style: t.bodySmall),
                  const Icon(Icons.star, size: 14, color: AppColors.star),
                  Text(' ${place.rating}', style: t.bodySmall),
                ]),
                const SizedBox(height: 6),
                Text(place.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaBanner extends StatelessWidget {
  final VoidCallback onView;
  const _CtaBanner({required this.onView});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.rust,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text('Coming to Iloilo? Plan a whole day in minutes.',
              textAlign: TextAlign.center,
              style: t.headlineSmall?.copyWith(color: Colors.white)),
          const SizedBox(height: 12),
          Text('A ready heritage day plan with the exact jeeps, fares and '
              'timings.',
              textAlign: TextAlign.center,
              style: t.bodyLarge?.copyWith(color: Colors.white70)),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onView,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.ink,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: const Text('View the day plan'),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        const BrandMark(),
        const SizedBox(height: 12),
        Text('Your local travel companion — pilot edition for Iloilo City.',
            style: t.bodyMedium),
        const SizedBox(height: 6),
        Text('Prototype · fares & times are community estimates for demo '
            'purposes.',
            style: t.bodySmall),
      ],
    );
  }
}
