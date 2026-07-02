import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/content_scope.dart';
import '../models.dart';
import '../widgets/directions_sheet.dart';

class PlacesTab extends StatefulWidget {
  const PlacesTab({super.key});

  @override
  State<PlacesTab> createState() => _PlacesTabState();
}

class _PlacesTabState extends State<PlacesTab> {
  PlaceCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final all = ContentScope.of(context).places;
    final visible = _filter == null
        ? all
        : all.where((p) => p.category == _filter).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 32),
      children: [
        const SectionIntro(
          eyebrow: 'Discover',
          title: 'Places & hidden gems',
          subtitle:
              'From coral-stone churches to island day trips — with ratings '
              'and local tips.',
        ),
        const SizedBox(height: 18),
        _filterChips(),
        const SizedBox(height: 18),
        for (final p in visible) ...[
          _PlaceCard(place: p),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _filterChips() {
    Widget chip(String label, bool selected, VoidCallback onTap) => GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.rust : AppColors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                  color: selected ? AppColors.rust : AppColors.line),
            ),
            child: Text(label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.ink,
                  fontWeight: FontWeight.w600,
                )),
          ),
        );
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        chip('All', _filter == null, () => setState(() => _filter = null)),
        for (final c in PlaceCategory.values)
          chip(c.label, _filter == c, () => setState(() => _filter = c)),
      ],
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final Place place;
  const _PlaceCard({required this.place});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    color: AppColors.chip,
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(place.category.icon,
                    color: AppColors.rust, size: 24),
              ),
              const Spacer(),
              Pill(place.category.label),
            ],
          ),
          const SizedBox(height: 14),
          Text(place.name, style: t.headlineSmall?.copyWith(fontSize: 22)),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.place, size: 15, color: AppColors.muted),
            Text(' ${place.area} · ', style: t.bodySmall),
            const Icon(Icons.star, size: 15, color: AppColors.star),
            Text(' ${place.rating} (${_fmt(place.reviews)})', style: t.bodySmall),
          ]),
          const SizedBox(height: 10),
          Text(place.description, style: t.bodyLarge),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.schedule, size: 16, color: AppColors.muted),
            const SizedBox(width: 6),
            Expanded(
              child: Text.rich(TextSpan(children: [
                const TextSpan(
                    text: 'Best time: ',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: AppColors.ink)),
                TextSpan(text: place.bestTime),
              ]), style: t.bodyMedium),
            ),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.chip, borderRadius: BorderRadius.circular(14)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline,
                    size: 18, color: AppColors.rust),
                const SizedBox(width: 8),
                Expanded(child: Text(place.tip, style: t.bodyMedium)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => showDirections(context, place),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.rust,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
              ),
              icon: const Icon(Icons.explore, size: 20),
              label: const Text('Get directions'),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
}
