import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/seed_data.dart';
import '../models.dart';

class ItineraryTab extends StatelessWidget {
  const ItineraryTab({super.key});

  int get _totalFare => heritageDayPlan.fold(0, (sum, s) {
        final m = RegExp(r'(\d+)').firstMatch(s.fare);
        return sum + (m != null ? int.parse(m.group(1)!) : 0);
      });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 32),
      children: [
        const SectionIntro(
          eyebrow: 'Day plan',
          title: 'A full heritage day in Iloilo',
          subtitle:
              'A ready-made route with the exact jeeps, fares and timing — '
              'just show up and follow along.',
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            const Pill('Full day · ~9 hours', icon: Icons.event_note),
            Pill('~₱$_totalFare in jeep fares',
                icon: Icons.payments,
                bg: AppColors.priceBg,
                fg: AppColors.priceInk),
            const Pill('All by jeepney',
                icon: Icons.directions_bus,
                bg: AppColors.chip,
                fg: AppColors.rust),
          ],
        ),
        const SizedBox(height: 22),
        for (int i = 0; i < heritageDayPlan.length; i++)
          _TimelineRow(
            index: i + 1,
            stop: heritageDayPlan[i],
            isLast: i == heritageDayPlan.length - 1,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final int index;
  final ItineraryStop stop;
  final bool isLast;
  const _TimelineRow(
      {required this.index, required this.stop, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: AppColors.rust, shape: BoxShape.circle),
                child: Text('$index',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.line,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(stop.time,
                          style: t.labelLarge?.copyWith(
                              color: AppColors.rust, fontSize: 15)),
                      const Spacer(),
                      Pill(stop.fare,
                          bg: AppColors.priceBg, fg: AppColors.priceInk),
                    ]),
                    const SizedBox(height: 8),
                    Text(stop.title,
                        style: t.headlineSmall?.copyWith(fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(stop.subtitle, style: t.bodyMedium),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
