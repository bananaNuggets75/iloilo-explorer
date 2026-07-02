/// Core domain models for the app.
///
/// Keep these pure Dart (no Flutter imports) so they are easy to test and,
/// later, to serialize to/from JSON when you add a backend or Firebase.

enum PlaceCategory { heritage, food, nature, cafe, museum, shopping, viewpoint }

extension PlaceCategoryLabel on PlaceCategory {
  String get label {
    switch (this) {
      case PlaceCategory.heritage:
        return 'Heritage';
      case PlaceCategory.food:
        return 'Food';
      case PlaceCategory.nature:
        return 'Nature';
      case PlaceCategory.cafe:
        return 'Café';
      case PlaceCategory.museum:
        return 'Museum';
      case PlaceCategory.shopping:
        return 'Shopping';
      case PlaceCategory.viewpoint:
        return 'Viewpoint';
    }
  }
}

/// A single leg of a commute (e.g. "ride the Leganes jeep", "walk 3 min").
class RouteStep {
  final String instruction; // e.g. "Ride Leganes jeepney"
  final String mode; // "jeepney", "walk", "taxi", "modern jeep", "bus"
  final double fare; // in PHP; 0 for walking
  final int minutes; // estimated time for this leg

  const RouteStep({
    required this.instruction,
    required this.mode,
    required this.fare,
    required this.minutes,
  });
}

/// A full commute suggestion from a starting landmark to the place.
class CommuteGuide {
  final String from; // e.g. "SM City Iloilo"
  final List<RouteStep> steps;

  const CommuteGuide({required this.from, required this.steps});

  double get totalFare =>
      steps.fold(0, (sum, step) => sum + step.fare);

  int get totalMinutes =>
      steps.fold(0, (sum, step) => sum + step.minutes);
}

/// A short recommendation left by a traveler.
class TravelerTip {
  final String author;
  final String text;
  final int rating; // 1-5

  const TravelerTip({
    required this.author,
    required this.text,
    required this.rating,
  });
}

class Place {
  final String id;
  final String name;
  final PlaceCategory category;
  final String area; // e.g. "Jaro", "Molo", "City Proper"
  final String description;
  final double rating; // aggregate 0-5
  final List<String> localFood; // delicacies to try nearby
  final String bestTime; // e.g. "Early morning"
  final List<CommuteGuide> commutes;
  final List<TravelerTip> tips;

  const Place({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.description,
    required this.rating,
    this.localFood = const [],
    this.bestTime = '',
    this.commutes = const [],
    this.tips = const [],
  });
}
