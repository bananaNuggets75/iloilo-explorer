// Smoke tests for Iloilo Travel Buddy.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:iloilo_travel_buddy/main.dart';

void main() {
  testWidgets('Home screen renders header and seeded places',
      (WidgetTester tester) async {
    await tester.pumpWidget(const IloiloTravelBuddyApp());

    expect(find.text('Explore Iloilo'), findsOneWidget);
    expect(find.text('Molo Mansion'), findsWidgets);
  });

  testWidgets('Searching filters the place list', (WidgetTester tester) async {
    await tester.pumpWidget(const IloiloTravelBuddyApp());

    await tester.enterText(find.byType(TextField), 'Batchoy');
    await tester.pumpAndSettle();

    expect(find.textContaining('Batchoy'), findsWidgets);
    // Molo Mansion has no Batchoy in its name, area, or food list.
    expect(find.text('Molo Mansion'), findsNothing);
  });
}
