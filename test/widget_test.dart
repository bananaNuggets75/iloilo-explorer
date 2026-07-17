// Smoke tests for SuroyIloilo.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:iloilo_travel_buddy/main.dart';
import 'package:iloilo_travel_buddy/screens/itinerary_tab.dart';

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

  testWidgets('Landing screen routes into the trip planner',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SuroyIloiloApp(showLanding: true));
    await tester.pump();

    expect(find.textContaining('RIDE LIKE'), findsOneWidget);
    expect(find.text('DAYON!'), findsOneWidget);

    await tester.tap(find.text('Plan my day'));
    await tester.pumpAndSettle();

    expect(find.text('Build your own'), findsOneWidget);
  });

  testWidgets('Trip planner builds a custom day plan',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SuroyIloiloApp());
    await tester.pump();

    await tester.tap(find.text('Plan').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Build your own'));
    await tester.pumpAndSettle();

    final planScrollable = find
        .descendant(
            of: find.byType(ItineraryTab), matching: find.byType(Scrollable))
        .first;

    await tester.tap(find.text('Molo Mansion'));
    await tester.pump();

    await tester.scrollUntilVisible(find.text('Build my plan (1)'), 100,
        scrollable: planScrollable);
    await tester.tap(find.text('Build my plan (1)'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Share plan'), 100,
        scrollable: planScrollable);
    expect(find.text('8:00 AM'), findsWidgets);
    expect(find.text('Molo Mansion'), findsWidgets);
    expect(find.textContaining('in fares'), findsOneWidget);
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
