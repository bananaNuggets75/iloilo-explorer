import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/content_scope.dart';
import '../models.dart';

class CommunityTab extends StatelessWidget {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final content = ContentScope.of(context);
    final events = content.events;
    final tips = content.tips;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 32),
      children: [
        const SectionIntro(
          eyebrow: 'Community',
          title: 'Tips from travelers & highlighted events',
          subtitle:
              "Advice from people who've been, plus what's happening around "
              'the city.',
        ),
        const SizedBox(height: 22),
        Row(children: [
          const Icon(Icons.celebration, color: AppColors.rust, size: 20),
          const SizedBox(width: 8),
          Text('Highlighted events',
              style: t.headlineSmall?.copyWith(fontSize: 20)),
        ]),
        const SizedBox(height: 12),
        for (final e in events) ...[
          _EventCard(event: e),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 16),
        Row(children: [
          const Icon(Icons.forum, color: AppColors.rust, size: 20),
          const SizedBox(width: 8),
          Text('Traveler tips',
              style: t.headlineSmall?.copyWith(fontSize: 20)),
        ]),
        const SizedBox(height: 12),
        for (final tip in tips) ...[
          _TipCard(tip: tip),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(event.name,
                  style: t.headlineSmall?.copyWith(fontSize: 20)),
            ),
            Pill(event.category, bg: AppColors.chip, fg: AppColors.rust),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.event_note, size: 15, color: AppColors.muted),
            const SizedBox(width: 4),
            Flexible(child: Text('${event.schedule} · ', style: t.bodySmall)),
            const Icon(Icons.place, size: 15, color: AppColors.muted),
            Flexible(child: Text(event.location, style: t.bodySmall)),
          ]),
          const SizedBox(height: 10),
          Text(event.description, style: t.bodyLarge),
          const SizedBox(height: 10),
          Text('Organized by ${event.organizer}', style: t.bodySmall),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final TravelerTip tip;
  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.chip,
              child: Text(tip.author.characters.first,
                  style: const TextStyle(
                      color: AppColors.chipInk, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tip.author, style: t.titleMedium),
                  Text(tip.from, style: t.bodySmall),
                ],
              ),
            ),
            Pill(tip.topic),
          ]),
          const SizedBox(height: 12),
          Text('"${tip.text}"',
              style: t.bodyLarge?.copyWith(fontStyle: FontStyle.italic)),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.favorite, size: 15, color: AppColors.rust),
            const SizedBox(width: 6),
            Text('${tip.helpful} found this helpful',
                style: t.bodySmall?.copyWith(color: AppColors.rust)),
          ]),
        ],
      ),
    );
  }
}
