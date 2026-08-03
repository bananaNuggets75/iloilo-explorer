// End-to-end test: drives the real app through its core journeys on a live
// widget tree. Run with:
//   flutter test integration_test/app_test.dart
// (on a device/emulator: `flutter test integration_test`).

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:iloilo_travel_buddy/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('landing → explore → navigate every tab → passport',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SuroyIloiloApp(showLanding: true));
    await tester.pumpAndSettle();

    // Landing screen, then enter the app.
    expect(find.textContaining('RIDE LIKE'), findsOneWidget);
    await tester.tap(find.text('Explore Iloilo'));
    await tester.pumpAndSettle();

    // Home is showing (map-first "Where in Iloilo?" search).
    expect(find.textContaining('Where in Iloilo'), findsOneWidget);

    // Walk the bottom navigation across every destination.
    for (final tab in ['Places', 'Food', 'Rides', 'Plan', 'Community']) {
      await tester.tap(find.text(tab).first);
      await tester.pumpAndSettle();
    }

    // Places content is reachable.
    await tester.tap(find.text('Places').first);
    await tester.pumpAndSettle();
    expect(find.text('Molo Mansion'), findsWidgets);

    // Passport opens from the header.
    await tester.tap(find.byTooltip('Suroy Passport'));
    await tester.pumpAndSettle();
    expect(find.text('Suroy Passport'), findsOneWidget);
  });

  testWidgets('first launch shows the landing once, then goes straight in',
      (WidgetTester tester) async {
    // A returning user (flag already set) should skip the landing.
    SharedPreferences.setMockInitialValues({'suroy_seen_landing': true});
    await tester.pumpWidget(const SuroyIloiloApp());
    await tester.pumpAndSettle();
    expect(find.textContaining('RIDE LIKE'), findsNothing);
    expect(find.textContaining('Where in Iloilo'), findsOneWidget);
  });
}
