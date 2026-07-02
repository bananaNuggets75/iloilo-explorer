import 'package:flutter/material.dart';
import '../models/place.dart';

/// Compact list card used on the home screen.
class PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;

  const PlaceCard({super.key, required this.place, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Cheapest commute is a nice thing to surface up front.
    final cheapest = place.commutes.isEmpty
        ? null
        : place.commutes
            .reduce((a, b) => a.totalFare <= b.totalFare ? a : b);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(place.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text(place.rating.toStringAsFixed(1)),
                ],
              ),
              const SizedBox(height: 4),
              Text('${place.category.label} · ${place.area}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      )),
              const SizedBox(height: 8),
              Text(place.description,
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              if (cheapest != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.directions_bus, size: 16),
                    const SizedBox(width: 6),
                    Text('From ${cheapest.from} · '
                        '₱${cheapest.totalFare.toStringAsFixed(0)} · '
                        '${cheapest.totalMinutes} min'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
