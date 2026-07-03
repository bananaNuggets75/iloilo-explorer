// Smoke tests for SuroyIloilo.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:iloilo_travel_buddy/main.dart';

void main() {
  testWidgets('App boots on the Home tab with the brand and hero',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SuroyIloiloApp());
    await tester.pump();

    expect(find.textContaining('Explore Iloilo like a local'), findsOneWidget);
    expect(find.text('Start exploring'), findsOneWidget);
  });

  testWidgets('Tapping the Places tab shows the places header',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SuroyIloiloApp());
    await tester.pump();

    await tester.tap(find.text('Places').first);
    await tester.pumpAndSettle();

    expect(find.text('Places & hidden gems'), findsOneWidget);
    expect(find.text('Molo Mansion'), findsWidgets);
  });

  testWidgets('Header passport button opens the Suroy Passport',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SuroyIloiloApp());
    await tester.pump();

    await tester.tap(find.byTooltip('Suroy Passport'));
    await tester.pumpAndSettle();

    expect(find.text('Suroy Passport'), findsOneWidget);
    expect(find.text('Stamps'), findsWidgets);
    expect(find.textContaining('GPS-verified'), findsOneWidget);
  });
}
