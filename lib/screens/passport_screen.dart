import 'package:flutter/material.dart';

import '../data/content_scope.dart';
import '../data/passport_repository.dart';
import '../models.dart';
import '../theme.dart';

/// The Suroy Passport — the user's collected stamps, badges and jeep savings.
class PassportScreen extends StatefulWidget {
  const PassportScreen({super.key});

  @override
  State<PassportScreen> createState() => _PassportScreenState();
}

class _PassportScreenState extends State<PassportScreen> {
  final _repo = PassportRepository();
  Map<String, DateTime> _stamps = {};
  int _rides = 0;
  int _saved = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stamps = await _repo.checkIns();
    final (rides, saved) = await _repo.rideStats();
    if (!mounted) return;
    setState(() {
      _stamps = stamps;
      _rides = rides;
      _saved = saved;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final places = ContentScope.of(context).places;
    final badges = _repo.badges(places, _stamps);
    final earnedBadges = badges.where((b) => b.earned).length;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
              children: [
                Row(children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.ink),
                  ),
                  const SizedBox(width: 4),
                  Text('Suroy Passport',
                      style: t.headlineSmall?.copyWith(fontSize: 24)),
                ]),
                const SizedBox(height: 8),
                Text(
                  'Stamps are earned by actually being there — GPS-verified '
                  'within ${checkInRadiusMeters.round()} m.',
                  style: t.bodyMedium,
                ),
                const SizedBox(height: 18),

                // Stats
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _stat(t, '${_stamps.length}', 'Stamps'),
                      const SizedBox(width: 12),
                      _stat(t, '$earnedBadges/${badges.length}', 'Badges'),
                      const SizedBox(width: 12),
                      _stat(t, '₱$_saved', 'Saved on $_rides jeep rides'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text('Stamps', style: t.headlineSmall?.copyWith(fontSize: 20)),
                const SizedBox(height: 12),
                LayoutBuilder(builder: (context, c) {
                  const gap = 10.0;
                  final w = (c.maxWidth - gap) / 2;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final p in places)
                        SizedBox(width: w, child: _StampCard(
                          place: p,
                          stampedOn: _stamps[p.id],
                        )),
                    ],
                  );
                }),
                const SizedBox(height: 24),

                Text('Badges', style: t.headlineSmall?.copyWith(fontSize: 20)),
                const SizedBox(height: 12),
                for (final b in badges) ...[
                  _BadgeRow(badge: b),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(TextTheme t, String n, String label) => Expanded(
        child: SoftCard(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          child: Column(
            children: [
              Text(n,
                  style: t.headlineMedium
                      ?.copyWith(color: AppColors.rust, fontSize: 26)),
              const SizedBox(height: 4),
              Text(label,
                  textAlign: TextAlign.center,
                  style: t.bodySmall?.copyWith(fontSize: 11.5)),
            ],
          ),
        ),
      );
}

class _StampCard extends StatelessWidget {
  final Place place;
  final DateTime? stampedOn;
  const _StampCard({required this.place, this.stampedOn});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final earned = stampedOn != null;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: earned ? AppColors.surface : AppColors.cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: earned ? AppColors.rust : AppColors.line,
          width: earned ? 1.6 : 1,
          style: earned ? BorderStyle.solid : BorderStyle.solid,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(place.category.icon,
                size: 22,
                color: earned ? AppColors.rust : AppColors.muted),
            const Spacer(),
            Icon(earned ? Icons.verified : Icons.lock_outline,
                size: 18,
                color: earned ? AppColors.rust : AppColors.muted),
          ]),
          const SizedBox(height: 10),
          Text(place.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: t.titleMedium?.copyWith(
                fontSize: 14,
                color: earned ? AppColors.ink : AppColors.muted,
              )),
          const SizedBox(height: 3),
          Text(
            earned
                ? 'Stamped ${_date(stampedOn!)}'
                : place.area,
            style: t.bodySmall?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _date(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _BadgeRow extends StatelessWidget {
  final PassportBadge badge;
  const _BadgeRow({required this.badge});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final earned = badge.earned;
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: earned ? AppColors.rust : AppColors.chip,
            shape: BoxShape.circle,
          ),
          child: Icon(badge.icon,
              size: 22, color: earned ? Colors.white : AppColors.muted),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(badge.name,
                  style: t.titleMedium?.copyWith(
                      color: earned ? AppColors.ink : AppColors.muted)),
              Text(badge.description, style: t.bodySmall),
            ],
          ),
        ),
        Pill(
          earned ? 'Earned' : badge.progress,
          bg: earned ? AppColors.priceBg : AppColors.chip,
          fg: earned ? AppColors.priceInk : AppColors.chipInk,
        ),
      ]),
    );
  }
}
