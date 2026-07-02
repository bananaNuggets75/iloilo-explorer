import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/home_tab.dart';
import 'screens/places_tab.dart';
import 'screens/food_tab.dart';
import 'screens/commute_tab.dart';
import 'screens/itinerary_tab.dart';
import 'screens/community_tab.dart';

void main() => runApp(const SuroyIloiloApp());

class SuroyIloiloApp extends StatelessWidget {
  const SuroyIloiloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SuroyIloilo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const AppShell(),
    );
  }
}

/// A simple app-wide notifier so any tab can request a jump to another tab
/// (e.g. the home CTAs open Commute or Itinerary).
class TabNav extends InheritedWidget {
  final void Function(int) goTo;
  const TabNav({super.key, required this.goTo, required super.child});

  static TabNav of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TabNav>()!;

  @override
  bool updateShouldNotify(TabNav oldWidget) => false;
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget page;
  const _NavItem(this.label, this.icon, this.activeIcon, this.page);
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  late final List<_NavItem> _items = const [
    _NavItem('Home', Icons.home_outlined, Icons.home, HomeTab()),
    _NavItem('Places', Icons.place_outlined, Icons.place, PlacesTab()),
    _NavItem('Food', Icons.restaurant_outlined, Icons.restaurant, FoodTab()),
    _NavItem('Rides', Icons.directions_bus_outlined, Icons.directions_bus,
        CommuteTab()),
    _NavItem('Plan', Icons.map_outlined, Icons.map, ItineraryTab()),
    _NavItem('Community', Icons.groups_outlined, Icons.groups, CommunityTab()),
  ];

  void _goTo(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return TabNav(
      goTo: _goTo,
      child: Scaffold(
        // Center the app in a phone-like column so it reads well on desktop
        // web and mirrors the mobile design instead of stretching full width.
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: DecoratedBox(
              decoration: const BoxDecoration(color: AppColors.cream),
              child: SafeArea(
                child: Column(
                  children: [
                    const _BrandHeader(),
                    Expanded(
                      child: IndexedStack(
                        index: _index,
                        children: [for (final item in _items) item.page],
                      ),
                    ),
                    _BottomNav(
                      items: _items,
                      index: _index,
                      onSelect: _goTo,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Slim branded header shown above the content on every tab.
class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(18, 12, 18, 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: BrandMark(),
        ),
      ),
    );
  }
}

/// Bottom navigation bar — the primary way to move between sections on mobile.
class _BottomNav extends StatelessWidget {
  final List<_NavItem> items;
  final int index;
  final ValueChanged<int> onSelect;
  const _BottomNav(
      {required this.items, required this.index, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.chip,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.ink : AppColors.muted,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              size: 24,
              color: selected ? AppColors.rust : AppColors.muted,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: onSelect,
          height: 66,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            for (final item in items)
              NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.activeIcon),
                label: item.label,
              ),
          ],
        ),
      ),
    );
  }
}

/// "SuroyIloilo" wordmark with the compass badge.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.rust,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.explore, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text.rich(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            TextSpan(children: [
              TextSpan(
                text: 'Suroy',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 24, color: AppColors.ink),
              ),
              TextSpan(
                text: 'Iloilo',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 24, color: AppColors.rust),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
