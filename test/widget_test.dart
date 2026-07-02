// Smoke tests for SuroyIloilo.

import 'package:flutter_test/flutter_test.dart';

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
}
