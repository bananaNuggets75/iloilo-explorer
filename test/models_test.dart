// Unit tests: JSON parsing and string→glyph/category mapping.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iloilo_travel_buddy/models.dart';
import 'package:iloilo_travel_buddy/theme.dart' show signboardOf;

void main() {
  group('Place.fromJson', () {
    test('maps all fields including coordinates', () {
      final p = Place.fromJson({
        'id': 'molo',
        'name': 'Molo Mansion',
        'category': 'heritage',
        'area': 'Molo',
        'rating': 4.6,
        'reviews': 1280,
        'description': 'desc',
        'best_time': 'afternoon',
        'tip': 'pair with church',
        'map_query': 'Molo Mansion',
        'lat': 10.6957,
        'lng': 122.548,
      });
      expect(p.id, 'molo');
      expect(p.category, PlaceCategory.heritage);
      expect(p.rating, 4.6);
      expect(p.reviews, 1280);
      expect(p.hasCoordinates, isTrue);
    });

    test('tolerates missing/zero coords and string numbers', () {
      final p = Place.fromJson({'name': 'X', 'rating': '4.2', 'reviews': '10'});
      expect(p.rating, 4.2);
      expect(p.reviews, 10);
      expect(p.hasCoordinates, isFalse);
      expect(p.category, PlaceCategory.heritage); // default
    });
  });

  test('CommuteRoute.fromJson parses the steps array', () {
    final r = CommuteRoute.fromJson({
      'from_label': 'City Proper',
      'to_label': 'Molo',
      'mode': 'Jeepney · Molo jeep',
      'mode_icon': 'bus',
      'fare': '₱13',
      'time': '15 min',
      'steps': ['ride the jeep', 'alight at church'],
      'tip': 'say bayad',
    });
    expect(r.from, 'City Proper');
    expect(r.steps, hasLength(2));
    expect(r.modeIcon, Icons.directions_bus);
  });

  test('CommunityPost.fromJson parses timestamp and helpful count', () {
    final post = CommunityPost.fromJson({
      'id': 'abc',
      'author': 'Ana',
      'from_label': 'from Iloilo',
      'topic': 'Food',
      'body': 'try batchoy',
      'image_url': '',
      'helpful': 5,
      'created_at': '2026-01-02T03:04:05Z',
    });
    expect(post.author, 'Ana');
    expect(post.helpful, 5);
    expect(post.createdAt, isNotNull);
  });

  group('string mappers', () {
    test('PlaceCategoryX.fromKey', () {
      expect(PlaceCategoryX.fromKey('museum'), PlaceCategory.museum);
      expect(PlaceCategoryX.fromKey('hidden_gem'), PlaceCategory.hiddenGem);
      expect(PlaceCategoryX.fromKey('unknown'), PlaceCategory.heritage);
    });

    test('iconFromKey returns const icons', () {
      expect(iconFromKey('ramen'), Icons.ramen_dining);
      expect(iconFromKey('bus'), Icons.directions_bus);
      expect(iconFromKey('nope'), Icons.restaurant); // fallback
    });

    test('signboardOf extracts the jeep sign from a mode label', () {
      expect(signboardOf('Jeepney · Molo / Villa jeep'), 'Molo / Villa jeep');
      expect(signboardOf('Walk'), 'Walk'); // no separator
    });
  });
}
