import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../theme.dart';
import '../data/content_scope.dart';
import '../models.dart';
import '../widgets/directions_sheet.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final nav = TabNav.of(context);
    final content = ContentScope.of(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Hero(onPlan: () => nav.goTo(4), onExplore: () => nav.goTo(1)),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _QuickActions(),
              const SizedBox(height: 28),
              _statsRow(t, content),
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
              const SizedBox(height: 4),
            ],
          ),
        ),
        // Horizontally swipeable — a carousel reads as an app, a stacked
        // column of blurbs reads as a blog.
        SizedBox(
          height: 190,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            scrollDirection: Axis.horizontal,
            itemCount: content.places.take(6).length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) =>
                _FeaturedSpot(place: content.places[i]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

  Widget _statsRow(TextTheme t, AppContent content) {
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
          stat('${content.places.length}', 'Curated spots'),
          const SizedBox(width: 12),
          stat('${content.foods.length}', 'Local food picks'),
          const SizedBox(width: 12),
          stat('${content.routes.length}', 'Ride routes with fares'),
        ],
      ),
    );
  }
}

/// Dark-ink hero — continues the Dayon landing's visual language into the
/// app itself instead of switching to a warm editorial gradient.
class _Hero extends StatelessWidget {
  final VoidCallback onPlan;
  final VoidCallback onExplore;
  const _Hero({required this.onPlan, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 26),
      color: DayonColors.ink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const JeepneyPlate('Suroy Iloilo'),
            const Spacer(),
            IconButton(
              onPressed: onExplore,
              icon: const Icon(Icons.search, color: Colors.white),
              tooltip: 'Explore places',
            ),
          ]),
          const SizedBox(height: 14),
          Text(
            'Where in Iloilo\nare you headed?',
            style: GoogleFonts.anton(
                color: Colors.white, fontSize: 32, height: 1.05),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPlan,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.signboard,
                foregroundColor: DayonColors.ink,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.route),
              label: Text('Plan my day',
                  style: GoogleFonts.archivo(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Action {
  final IconData icon;
  final String label;
  final int tab;
  const _Action(this.icon, this.label, this.tab);
}

/// A tappable strip of app shortcuts — dashboard-style navigation instead
/// of paragraphs describing each section.
class _QuickActions extends StatelessWidget {
  const _QuickActions();

  static const _actions = [
    _Action(Icons.place, 'Places', 1),
    _Action(Icons.ramen_dining, 'Food', 2),
    _Action(Icons.directions_bus, 'Rides', 3),
    _Action(Icons.forum, 'Community', 5),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = TabNav.of(context);
    return Row(
      children: [
        for (final a in _actions) ...[
          Expanded(
            child: InkWell(
              onTap: () => nav.goTo(a.tab),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  children: [
                    Icon(a.icon, color: AppColors.rust, size: 22),
                    const SizedBox(height: 6),
                    Text(a.label,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink)),
                  ],
                ),
              ),
            ),
          ),
          if (a != _actions.last) const SizedBox(width: 10),
        ],
      ],
    );
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
    return SizedBox(
      width: 210,
      child: SoftCard(
        onTap: () => showDirections(context, place),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _iconTile(place.category.icon),
            const SizedBox(height: 12),
            Text(place.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.titleMedium),
            const SizedBox(height: 3),
            Row(children: [
              Flexible(
                  child: Text(place.area,
                      overflow: TextOverflow.ellipsis, style: t.bodySmall)),
              const SizedBox(width: 4),
              const Icon(Icons.star, size: 13, color: AppColors.star),
              Text(' ${place.rating}', style: t.bodySmall),
            ]),
            const SizedBox(height: 6),
            Expanded(
              child: Text(place.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodyMedium),
            ),
          ],
        ),
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
