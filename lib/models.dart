import 'package:flutter/material.dart';

/// Pure domain models for SuroyIloilo. Beyond IconData (so the UI can render
/// category glyphs) these stay logic-free and know how to build themselves
/// from a JSON row, so the same models serve both the bundled seed data and
/// Supabase.

enum PlaceCategory { heritage, museum, landmark, nature, hiddenGem }

extension PlaceCategoryX on PlaceCategory {
  String get label => switch (this) {
        PlaceCategory.heritage => 'Heritage',
        PlaceCategory.museum => 'Museum',
        PlaceCategory.landmark => 'Landmark',
        PlaceCategory.nature => 'Nature',
        PlaceCategory.hiddenGem => 'Hidden Gem',
      };

  IconData get icon => switch (this) {
        PlaceCategory.heritage => Icons.account_balance,
        PlaceCategory.museum => Icons.museum,
        PlaceCategory.landmark => Icons.church,
        PlaceCategory.nature => Icons.landscape,
        PlaceCategory.hiddenGem => Icons.diamond,
      };

  static PlaceCategory fromKey(String? key) => switch (key) {
        'museum' => PlaceCategory.museum,
        'landmark' => PlaceCategory.landmark,
        'nature' => PlaceCategory.nature,
        'hiddenGem' || 'hidden_gem' => PlaceCategory.hiddenGem,
        _ => PlaceCategory.heritage,
      };
}

/// Maps a stored string key to a const IconData. Const keeps icon
/// tree-shaking working (dynamic IconData construction would break it).
IconData iconFromKey(String? key) => switch (key) {
      'ramen' => Icons.ramen_dining,
      'soup' => Icons.soup_kitchen,
      'bakery' => Icons.bakery_dining,
      'seafood' => Icons.set_meal,
      'rice' => Icons.rice_bowl,
      'grill' => Icons.outdoor_grill,
      'walk' => Icons.directions_walk,
      'van' => Icons.airport_shuttle,
      'bus' => Icons.directions_bus,
      'busFilled' || 'bus_filled' => Icons.directions_bus_filled,
      _ => Icons.restaurant,
    };

String _str(dynamic v) => v?.toString() ?? '';
double _dbl(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
int _int(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

class Place {
  final String id;
  final String name;
  final PlaceCategory category;
  final String area;
  final double rating;
  final int reviews;
  final String description;
  final String bestTime;
  final String tip;

  /// Google Maps destination query (place name / address). Used to build a
  /// keyless maps URL for the "Get directions" placeholder.
  final String mapQuery;

  const Place({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.rating,
    required this.reviews,
    required this.description,
    required this.bestTime,
    required this.tip,
    required this.mapQuery,
  });

  factory Place.fromJson(Map<String, dynamic> j) => Place(
        id: _str(j['id']),
        name: _str(j['name']),
        category: PlaceCategoryX.fromKey(_str(j['category'])),
        area: _str(j['area']),
        rating: _dbl(j['rating']),
        reviews: _int(j['reviews']),
        description: _str(j['description']),
        bestTime: _str(j['best_time']),
        tip: _str(j['tip']),
        mapQuery: _str(j['map_query']),
      );
}

class FoodSpot {
  final String name;
  final String vendor;
  final String area;
  final String priceRange;
  final double rating;
  final int reviews;
  final String description;
  final String mustTry;
  final IconData icon;

  const FoodSpot({
    required this.name,
    required this.vendor,
    required this.area,
    required this.priceRange,
    required this.rating,
    required this.reviews,
    required this.description,
    required this.mustTry,
    this.icon = Icons.restaurant,
  });

  factory FoodSpot.fromJson(Map<String, dynamic> j) => FoodSpot(
        name: _str(j['name']),
        vendor: _str(j['vendor']),
        area: _str(j['area']),
        priceRange: _str(j['price_range']),
        rating: _dbl(j['rating']),
        reviews: _int(j['reviews']),
        description: _str(j['description']),
        mustTry: _str(j['must_try']),
        icon: iconFromKey(_str(j['icon'])),
      );
}

class CommuteRoute {
  final String from;
  final String to;
  final String mode; // e.g. "Jeepney · Molo / Villa jeep"
  final IconData modeIcon;
  final String fare; // e.g. "₱13–₱15"
  final String time; // e.g. "15–20 min"
  final List<String> steps;
  final String tip;

  const CommuteRoute({
    required this.from,
    required this.to,
    required this.mode,
    required this.modeIcon,
    required this.fare,
    required this.time,
    required this.steps,
    required this.tip,
  });

  factory CommuteRoute.fromJson(Map<String, dynamic> j) => CommuteRoute(
        from: _str(j['from_label']),
        to: _str(j['to_label']),
        mode: _str(j['mode']),
        modeIcon: iconFromKey(_str(j['mode_icon'])),
        fare: _str(j['fare']),
        time: _str(j['time']),
        steps: (j['steps'] as List?)?.map((e) => e.toString()).toList() ??
            const [],
        tip: _str(j['tip']),
      );
}

class Event {
  final String name;
  final String category;
  final String schedule;
  final String location;
  final String description;
  final String organizer;

  const Event({
    required this.name,
    required this.category,
    required this.schedule,
    required this.location,
    required this.description,
    required this.organizer,
  });

  factory Event.fromJson(Map<String, dynamic> j) => Event(
        name: _str(j['name']),
        category: _str(j['category']),
        schedule: _str(j['schedule']),
        location: _str(j['location']),
        description: _str(j['description']),
        organizer: _str(j['organizer']),
      );
}

class TravelerTip {
  final String author;
  final String from;
  final String topic;
  final String text;
  final int helpful;

  const TravelerTip({
    required this.author,
    required this.from,
    required this.topic,
    required this.text,
    required this.helpful,
  });

  factory TravelerTip.fromJson(Map<String, dynamic> j) => TravelerTip(
        author: _str(j['author']),
        from: _str(j['from_label']),
        topic: _str(j['topic']),
        text: _str(j['text']),
        helpful: _int(j['helpful']),
      );
}

class ItineraryStop {
  final String time;
  final String title;
  final String subtitle;
  final String fare;

  const ItineraryStop({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.fare,
  });

  factory ItineraryStop.fromJson(Map<String, dynamic> j) => ItineraryStop(
        time: _str(j['time_label']),
        title: _str(j['title']),
        subtitle: _str(j['subtitle']),
        fare: _str(j['fare']),
      );
}

/// An anonymous traveler experience shared from the app (no account needed).
class CommunityPost {
  final String id;
  final String author;
  final String from;
  final String topic;
  final String body;
  final String imageUrl;
  final int helpful;
  final DateTime? createdAt;

  const CommunityPost({
    required this.id,
    required this.author,
    required this.from,
    required this.topic,
    required this.body,
    required this.imageUrl,
    required this.helpful,
    this.createdAt,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> j) => CommunityPost(
        id: _str(j['id']),
        author: _str(j['author']),
        from: _str(j['from_label']),
        topic: _str(j['topic']),
        body: _str(j['body']),
        imageUrl: _str(j['image_url']),
        helpful: _int(j['helpful']),
        createdAt: DateTime.tryParse(_str(j['created_at']))?.toLocal(),
      );
}
