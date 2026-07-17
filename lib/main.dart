import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'config/env.dart';
import 'data/content_repository.dart';
import 'data/content_scope.dart';
import 'screens/home_tab.dart';
import 'screens/places_tab.dart';
import 'screens/food_tab.dart';
import 'screens/commute_tab.dart';
import 'screens/itinerary_tab.dart';
import 'screens/community_tab.dart';
import 'screens/landing_screen.dart';
import 'screens/passport_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Best-effort: load secrets and connect Supabase. If either is missing the
  // app still runs fully on bundled seed data.
  await Env.load();
  await ContentRepository.init();
  // The Dayon welcome screen shows on first launch only.
  bool seenLanding = false;
  try {
    final prefs = await SharedPreferences.getInstance();
    seenLanding = prefs.getBool(LandingScreen.seenKey) ?? false;
  } catch (_) {/* fall through to showing the landing */}
  runApp(SuroyIloiloApp(showLanding: !seenLanding));
}

class SuroyIloiloApp extends StatelessWidget {
  /// Whether to open on the Dayon landing screen (first launch).
  final bool showLanding;
  const SuroyIloiloApp({super.key, this.showLanding = false});

  @override
  Widget build(BuildContext context) {
    // ContentScope wraps MaterialApp so app content is reachable everywhere,
    // including modal routes and bottom sheets that live above `home`.
    return ContentScope(
      child: MaterialApp(
        title: 'SuroyIloilo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(),
        home: showLanding ? const LandingScreen() : const AppShell(),
      ),
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
  final int initialIndex;
  const AppShell({super.key, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index = widget.initialIndex;

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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
        child: Row(
          children: [
            const Expanded(child: BrandMark()),
            // Suroy Passport — stamps, badges and jeep savings.
            IconButton(
              tooltip: 'Suroy Passport',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PassportScreen()),
              ),
              icon: const Icon(Icons.workspace_premium,
                  color: AppColors.rust, size: 26),
            ),
          ],
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
