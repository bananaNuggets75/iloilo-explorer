import 'package:flutter/material.dart';

/// Pure domain models for SuroyIloilo. No Flutter logic beyond IconData so the
/// UI can render category glyphs; easy to serialize to JSON with a backend.

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
}

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
}
