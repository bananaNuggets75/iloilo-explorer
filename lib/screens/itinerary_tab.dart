import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/content_scope.dart';
import '../data/trip_planner.dart';
import '../models.dart';
import '../widgets/directions_sheet.dart';
import '../widgets/share_helper.dart';

class ItineraryTab extends StatefulWidget {
  const ItineraryTab({super.key});

  @override
  State<ItineraryTab> createState() => _ItineraryTabState();
}

class _ItineraryTabState extends State<ItineraryTab> {
  final _planner = TripPlanner();
  bool _buildMode = false;
  bool _planBuilt = false;
  final Set<String> _selectedIds = {};
  int _startMinutes = 8 * 60;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final saved = await _planner.load();
    if (saved == null || !mounted) return;
    setState(() {
      _buildMode = true;
      _planBuilt = true;
      _selectedIds
        ..clear()
        ..addAll(saved.$1);
      _startMinutes = saved.$2;
    });
  }

  Future<void> _persist() =>
      _planner.save(_selectedIds.toList(), _startMinutes);

  void _togglePlace(Place p) {
    setState(() {
      _selectedIds.contains(p.id)
          ? _selectedIds.remove(p.id)
          : _selectedIds.add(p.id);
    });
    if (_planBuilt) _persist();
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: _startMinutes ~/ 60, minute: _startMinutes % 60),
    );
    if (picked == null) return;
    setState(() => _startMinutes = picked.hour * 60 + picked.minute);
    if (_planBuilt) _persist();
  }

  void _buildPlan() {
    setState(() => _planBuilt = true);
    _persist();
  }

  Future<void> _clearPlan() async {
    await _planner.clear();
    if (!mounted) return;
    setState(() {
      _planBuilt = false;
      _selectedIds.clear();
      _startMinutes = 8 * 60;
    });
  }

  Future<void> _sharePlan(TripPlan plan) async {
    final lines = [
      'My Iloilo day plan — starts ${formatMinutes(plan.startMinutes)}',
      for (int i = 0; i < plan.stops.length; i++)
        '${i + 1}. ${plan.stops[i].time} ${plan.stops[i].place.name}'
            ' (${plan.stops[i].ride?.mode ?? 'jeep'} · P${plan.stops[i].fare})',
      'About P${plan.totalFare} in fares, wraps up around ${plan.endLabel}.',
      'Built with SuroyIloilo.',
    ];
    await shareText(context, lines.join('\n'));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final content = ContentScope.of(context);
    final selectedPlaces =
        content.places.where((p) => _selectedIds.contains(p.id)).toList();
    final plan = _planBuilt && selectedPlaces.isNotEmpty
        ? _planner.build(
            selected: selectedPlaces,
            routes: content.routes,
            startMinutes: _startMinutes,
          )
        : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 32),
      children: [
        const SectionIntro(
          eyebrow: 'Day plan',
          title: 'Plan your Iloilo trip',
          subtitle: 'Follow the ready-made heritage day, or build your own '
              'plan with the jeeps and fares filled in for you.',
        ),
        const SizedBox(height: 18),

        // Mode switch
        Wrap(spacing: 10, children: [
          _modeChip('Heritage day', !_buildMode,
              () => setState(() => _buildMode = false)),
          _modeChip('Build your own', _buildMode,
              () => setState(() => _buildMode = true)),
        ]),
        const SizedBox(height: 20),

        if (!_buildMode)
          ..._readyMade(t, content)
        else ...[
          Text('Pick your spots', style: t.titleLarge?.copyWith(fontSize: 18)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in content.places)
                FilterChip(
                  avatar: Icon(p.category.icon,
                      size: 16,
                      color: _selectedIds.contains(p.id)
                          ? Colors.white
                          : AppColors.rust),
                  label: Text(p.name),
                  selected: _selectedIds.contains(p.id),
                  onSelected: (_) => _togglePlace(p),
                  selectedColor: AppColors.rust,
                  checkmarkColor: Colors.white,
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    color: _selectedIds.contains(p.id)
                        ? Colors.white
                        : AppColors.ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.line),
                ),
            ],
          ),
          const SizedBox(height: 16),

          Row(children: [
            Text('Start the day at',
                style: t.titleMedium?.copyWith(fontSize: 15)),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: _pickStartTime,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.rust,
                side: const BorderSide(color: AppColors.line),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
              ),
              icon: const Icon(Icons.schedule, size: 17),
              label: Text(formatMinutes(_startMinutes)),
            ),
          ]),
          const SizedBox(height: 14),

          if (!_planBuilt)
            FilledButton.icon(
              onPressed: _selectedIds.isEmpty ? null : _buildPlan,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.rust,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
              ),
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: Text(_selectedIds.isEmpty
                  ? 'Pick at least one spot'
                  : 'Build my plan (${_selectedIds.length})'),
            ),

          if (plan != null) ...[
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [
              Pill('${plan.stops.length} stops', icon: Icons.place),
              Pill('~₱${plan.totalFare} in fares',
                  icon: Icons.payments,
                  bg: AppColors.priceBg,
                  fg: AppColors.priceInk),
              Pill('wraps up ~${plan.endLabel}', icon: Icons.schedule),
              if (plan.hasFarTrip)
                const Pill('includes a far trip — consider its own day',
                    icon: Icons.warning_amber,
                    bg: Color(0xFFF2E8CB),
                    fg: Color(0xFF8A6A1F)),
            ]),
            const SizedBox(height: 20),
            for (int i = 0; i < plan.stops.length; i++)
              _TimelineRow(
                index: i + 1,
                time: plan.stops[i].time,
                title: plan.stops[i].place.name,
                subtitle: plan.stops[i].ride?.mode ??
                    '${plan.stops[i].place.area} · tap for directions',
                fare: '₱${plan.stops[i].fare} jeep',
                isLast: i == plan.stops.length - 1,
                onTap: () => showDirections(context, plan.stops[i].place),
              ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _sharePlan(plan),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.rust,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999)),
                  ),
                  icon: const Icon(Icons.ios_share, size: 18),
                  label: const Text('Share plan'),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: _clearPlan,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.muted,
                  side: const BorderSide(color: AppColors.line),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
                ),
                child: const Text('Clear'),
              ),
            ]),
            const SizedBox(height: 8),
            Text(
              'Tap any stop to see the map, the jeep to ride and the fare. '
              'Times are estimates (~75 min per stop plus travel).',
              style: t.bodySmall,
            ),
          ],
        ],
      ],
    );
  }

  List<Widget> _readyMade(TextTheme t, AppContent content) {
    final stops = content.itinerary;
    final totalFare = stops.fold(0, (sum, s) {
      final m = RegExp(r'(\d+)').firstMatch(s.fare);
      return sum + (m != null ? int.parse(m.group(1)!) : 0);
    });
    return [
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          const Pill('Full day · ~9 hours', icon: Icons.event_note),
          Pill('~₱$totalFare in jeep fares',
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
      for (int i = 0; i < stops.length; i++)
        _TimelineRow(
          index: i + 1,
          time: stops[i].time,
          title: stops[i].title,
          subtitle: stops[i].subtitle,
          fare: stops[i].fare,
          isLast: i == stops.length - 1,
        ),
    ];
  }

  Widget _modeChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.rust : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border:
              Border.all(color: selected ? AppColors.rust : AppColors.line),
        ),
        child: Text(label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.ink,
              fontWeight: FontWeight.w600,
            )),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final int index;
  final String time;
  final String title;
  final String subtitle;
  final String fare;
  final bool isLast;
  final VoidCallback? onTap;
  const _TimelineRow({
    required this.index,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.fare,
    required this.isLast,
    this.onTap,
  });

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
                onTap: onTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(time,
                          style: t.labelLarge?.copyWith(
                              color: AppColors.rust, fontSize: 15)),
                      const Spacer(),
                      Pill(fare,
                          bg: AppColors.priceBg, fg: AppColors.priceInk),
                    ]),
                    const SizedBox(height: 8),
                    Text(title,
                        style: t.headlineSmall?.copyWith(fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: t.bodyMedium),
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
