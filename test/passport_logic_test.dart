// Unit tests: passport fare-saved math, badge rules and check-in messages.

import 'package:flutter_test/flutter_test.dart';
import 'package:iloilo_travel_buddy/data/passport_repository.dart';
import 'package:iloilo_travel_buddy/models.dart';

Place _place(String id, PlaceCategory c) => Place(
      id: id,
      name: id,
      category: c,
      area: 'area',
      rating: 4,
      reviews: 1,
      description: '',
      bestTime: '',
      tip: '',
      mapQuery: '',
      lat: 10.7,
      lng: 122.5,
    );

void main() {
  group('fareSaved', () {
    test('uses the first fare number and clamps to the taxi estimate', () {
      expect(PassportRepository.fareSaved('₱13'), taxiEstimatePesos - 13);
      expect(PassportRepository.fareSaved('₱13–₱15'), taxiEstimatePesos - 13);
    });

    test('defaults to jeep minimum when no number is present', () {
      expect(PassportRepository.fareSaved('free walk'), taxiEstimatePesos - 13);
    });

    test('never goes negative for an expensive fare', () {
      expect(PassportRepository.fareSaved('₱9999 bus'), 0);
    });
  });

  group('badges', () {
    final repo = PassportRepository();
    final places = [
      _place('a', PlaceCategory.heritage),
      _place('b', PlaceCategory.landmark),
      _place('c', PlaceCategory.heritage),
      _place('d', PlaceCategory.museum),
      _place('e', PlaceCategory.museum),
      _place('f', PlaceCategory.nature),
    ];

    test('nothing earned with zero stamps except correct progress', () {
      final badges = repo.badges(places, {});
      expect(badges.every((b) => !b.earned), isTrue);
      final first = badges.firstWhere((b) => b.name == 'First Suroy');
      expect(first.progress, '0/1');
    });

    test('Heritage Hunter needs 3 heritage/landmark stamps', () {
      final stamps = {
        'a': DateTime.now(),
        'b': DateTime.now(),
        'c': DateTime.now(),
      };
      final hunter =
          repo.badges(places, stamps).firstWhere((b) => b.name == 'Heritage Hunter');
      expect(hunter.earned, isTrue);
    });

    test('First Suroy earns on the very first stamp', () {
      final first = repo
          .badges(places, {'a': DateTime.now()})
          .firstWhere((b) => b.name == 'First Suroy');
      expect(first.earned, isTrue);
    });
  });

  group('CheckInResult messages', () {
    test('too far reports kilometers past 1 km', () {
      const r = CheckInResult(CheckInStatus.tooFar, 3200);
      expect(r.message, contains('3.2 km'));
    });

    test('stamped is celebratory', () {
      const r = CheckInResult(CheckInStatus.stamped, 20);
      expect(r.message.toLowerCase(), contains('stamped'));
    });
  });
}
