// Headless end-to-end journey — the same flow as integration_test/app_test.dart
// but runnable on the VM (`flutter test`) so it's verified in CI without a
// device. The integration_test version drives a real device/browser.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:iloilo_travel_buddy/main.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('landing → explore → every tab → passport', (tester) async {
    await tester.pumpWidget(const SuroyIloiloApp(showLanding: true));
    await tester.pumpAndSettle();

    expect(find.textContaining('RIDE LIKE'), findsOneWidget);
    await tester.tap(find.text('Explore Iloilo'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Where in Iloilo'), findsOneWidget);

    for (final tab in ['Places', 'Food', 'Rides', 'Plan', 'Community']) {
      await tester.tap(find.text(tab).first);
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Places').first);
    await tester.pumpAndSettle();
    expect(find.text('Molo Mansion'), findsWidgets);

    await tester.tap(find.byTooltip('Suroy Passport'));
    await tester.pumpAndSettle();
    expect(find.text('Suroy Passport'), findsOneWidget);
  });

  testWidgets('a returning user skips the landing', (tester) async {
    SharedPreferences.setMockInitialValues({'suroy_seen_landing': true});
    await tester.pumpWidget(const SuroyIloiloApp());
    await tester.pumpAndSettle();
    expect(find.textContaining('RIDE LIKE'), findsNothing);
    expect(find.textContaining('Where in Iloilo'), findsOneWidget);
  });
}
