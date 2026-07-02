import 'package:flutter/material.dart';
import '../models/place.dart';

/// Detail view — this is where the app's differentiator lives:
/// the commute + fare breakdown, plus food and traveler tips.
class PlaceDetailScreen extends StatelessWidget {
  final Place place;

  const PlaceDetailScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(place.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader(context, '${place.category.label} · ${place.area}'),
          Row(
            children: [
              const Icon(Icons.star, size: 18, color: Colors.amber),
              const SizedBox(width: 4),
              Text(place.rating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          Text(place.description),
          if (place.bestTime.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.schedule, size: 18),
                const SizedBox(width: 6),
                Expanded(child: Text('Best time: ${place.bestTime}')),
              ],
            ),
          ],

          // ---- Local food ----
          if (place.localFood.isNotEmpty) ...[
            const SizedBox(height: 24),
            _sectionTitle(context, 'Local food to try'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final food in place.localFood)
                  Chip(
                    avatar: const Icon(Icons.restaurant, size: 16),
                    label: Text(food),
                  ),
              ],
            ),
          ],

          // ---- How to get there ----
          if (place.commutes.isNotEmpty) ...[
            const SizedBox(height: 24),
            _sectionTitle(context, 'How to get there'),
            const SizedBox(height: 8),
            for (final guide in place.commutes) _CommuteCard(guide: guide),
          ],

          // ---- Traveler tips ----
          if (place.tips.isNotEmpty) ...[
            const SizedBox(height: 24),
            _sectionTitle(context, 'Traveler tips'),
            const SizedBox(height: 8),
            for (final tip in place.tips) _TipTile(tip: tip),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                )),
      );

  Widget _sectionTitle(BuildContext context, String text) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      );
}

class _CommuteCard extends StatelessWidget {
  final CommuteGuide guide;
  const _CommuteCard({required this.guide});

  IconData _iconFor(String mode) {
    switch (mode) {
      case 'walk':
        return Icons.directions_walk;
      case 'taxi':
        return Icons.local_taxi;
      case 'bus':
        return Icons.directions_bus;
      case 'modern jeep':
      case 'jeepney':
      default:
        return Icons.airport_shuttle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.surfaceContainerHighest,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.my_location, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('From ${guide.from}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(height: 20),
            for (final step in guide.steps)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(_iconFor(step.mode), size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(step.instruction)),
                    const SizedBox(width: 8),
                    Text(
                      step.fare > 0
                          ? '₱${step.fare.toStringAsFixed(0)} · ${step.minutes}m'
                          : '${step.minutes}m',
                      style: TextStyle(color: scheme.primary),
                    ),
                  ],
                ),
              ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total: ₱${guide.totalFare.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('~${guide.totalMinutes} min'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TipTile extends StatelessWidget {
  final TravelerTip tip;
  const _TipTile({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(child: Text(tip.author.characters.first)),
        title: Text(tip.author),
        subtitle: Text(tip.text),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, size: 14, color: Colors.amber),
            Text('${tip.rating}'),
          ],
        ),
      ),
    );
  }
}
