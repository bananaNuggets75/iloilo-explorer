import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/content_scope.dart';
import '../models.dart';

class CommuteTab extends StatelessWidget {
  const CommuteTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final routes = ContentScope.of(context).routes;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 32),
      children: [
        const SectionIntro(
          eyebrow: 'Ride & fares',
          title: "How to get there — and what you'll pay",
          subtitle:
              'The part most travel apps skip: which jeep to ride, transfers, '
              'and honest fare estimates.',
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.chip, borderRadius: BorderRadius.circular(18)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.info_outline, size: 18, color: AppColors.rust),
                const SizedBox(width: 8),
                Text('Fare basics', style: t.titleMedium),
              ]),
              const SizedBox(height: 8),
              Text.rich(
                const TextSpan(children: [
                  TextSpan(
                      text: 'Jeepney minimum fare is around ₱13. Say '),
                  TextSpan(
                      text: '"bayad"',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: ' when passing your fare forward, and '),
                  TextSpan(
                      text: '"para"',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(
                      text: ' when you want to get off. Grab/taxi is available '
                          'but limited at rush hour.'),
                ]),
                style: t.bodyLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        for (final r in routes) ...[
          _RouteCard(route: r),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _RouteCard extends StatelessWidget {
  final CommuteRoute route;
  const _RouteCard({required this.route});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Flexible(
              child: Text(route.from,
                  style: t.titleMedium?.copyWith(fontSize: 17)),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 18, color: AppColors.rust),
          ]),
          const SizedBox(height: 4),
          Text(route.to, style: t.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Pill(route.mode,
                  icon: route.modeIcon, bg: AppColors.chip, fg: AppColors.rust),
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
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: AppColors.chip, shape: BoxShape.circle),
                    child: Text('${i + 1}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.chipInk)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(route.steps[i], style: t.bodyLarge)),
                ],
              ),
            ),
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
                Expanded(child: Text(route.tip, style: t.bodyMedium)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
