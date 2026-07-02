import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/content_scope.dart';
import '../models.dart';

class FoodTab extends StatelessWidget {
  const FoodTab({super.key});

  @override
  Widget build(BuildContext context) {
    final foods = ContentScope.of(context).foods;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 32),
      children: [
        const SectionIntro(
          eyebrow: 'Eat local',
          title: 'Local food & where to find it',
          subtitle:
              'Iloilo is a food capital — here are the dishes and spots worth '
              'the trip.',
        ),
        const SizedBox(height: 18),
        for (final f in foods) ...[
          _FoodCard(food: f),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _FoodCard extends StatelessWidget {
  final FoodSpot food;
  const _FoodCard({required this.food});

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
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                    color: AppColors.chip,
                    borderRadius: BorderRadius.circular(16)),
                child: Icon(food.icon, color: AppColors.rust, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(food.name,
                              style: t.headlineSmall?.copyWith(fontSize: 21)),
                        ),
                        const SizedBox(width: 8),
                        Pill(food.priceRange,
                            bg: AppColors.priceBg, fg: AppColors.priceInk),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      Flexible(
                        child: Text('${food.vendor} · ',
                            style: t.bodySmall,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const Icon(Icons.place, size: 14, color: AppColors.muted),
                      Flexible(
                        child: Text(food.area,
                            style: t.bodySmall,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(food.description, style: t.bodyLarge),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.star, size: 16, color: AppColors.star),
            Text(' ${food.rating} ', style: t.bodyLarge),
            Text('(${_fmt(food.reviews)} reviews)', style: t.bodySmall),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.chip, borderRadius: BorderRadius.circular(14)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.emoji_food_beverage,
                    size: 18, color: AppColors.rust),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(TextSpan(children: [
                    const TextSpan(
                        text: 'Must try: ',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: AppColors.ink)),
                    TextSpan(text: food.mustTry),
                  ]), style: t.bodyMedium),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
}
