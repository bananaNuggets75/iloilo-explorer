import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';
import '../models.dart';
import 'seed_data.dart' as seed;

/// An immutable snapshot of all app content. The UI reads everything from one
/// of these so it does not care whether the data came from Supabase or the
/// bundled seed.
class AppContent {
  final List<Place> places;
  final List<FoodSpot> foods;
  final List<CommuteRoute> routes;
  final List<ItineraryStop> itinerary;
  final List<Event> events;
  final List<TravelerTip> tips;

  const AppContent({
    required this.places,
    required this.foods,
    required this.routes,
    required this.itinerary,
    required this.events,
    required this.tips,
  });

  /// The bundled offline content — used immediately at launch and as a
  /// fallback whenever Supabase is unreachable or a table is empty.
  factory AppContent.seed() => const AppContent(
        places: seed.places,
        foods: seed.foods,
        routes: seed.routes,
        itinerary: seed.heritageDayPlan,
        events: seed.events,
        tips: seed.tips,
      );
}

/// Loads content from Supabase, falling back to seed data table-by-table so a
/// missing table or network hiccup never breaks the app.
class ContentRepository {
  /// Initialize Supabase if credentials are configured. Safe to call once at
  /// startup; a no-op (and returns false) when unconfigured.
  static Future<bool> init() async {
    if (!Env.isConfigured) return false;
    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        // The sb_publishable_ key is the modern client key (anon replacement).
        publishableKey: Env.supabaseKey,
      );
      return true;
    } catch (e) {
      debugPrint('Supabase init failed, using seed data: $e');
      return false;
    }
  }

  SupabaseClient get _db => Supabase.instance.client;

  /// Fetch everything. Each section falls back to seed independently.
  Future<AppContent> loadAll() async {
    if (!Env.isConfigured) return AppContent.seed();
    final results = await Future.wait([
      _fetch('places', Place.fromJson, seed.places),
      _fetch('foods', FoodSpot.fromJson, seed.foods),
      _fetch('routes', CommuteRoute.fromJson, seed.routes),
      _fetch('itinerary_stops', ItineraryStop.fromJson, seed.heritageDayPlan),
      _fetch('events', Event.fromJson, seed.events),
      _fetch('tips', TravelerTip.fromJson, seed.tips),
    ]);
    return AppContent(
      places: results[0] as List<Place>,
      foods: results[1] as List<FoodSpot>,
      routes: results[2] as List<CommuteRoute>,
      itinerary: results[3] as List<ItineraryStop>,
      events: results[4] as List<Event>,
      tips: results[5] as List<TravelerTip>,
    );
  }

  Future<List<T>> _fetch<T>(
    String table,
    T Function(Map<String, dynamic>) fromJson,
    List<T> fallback,
  ) async {
    try {
      final rows = await _db.from(table).select().order('sort');
      if (rows.isEmpty) return fallback;
      return rows.map((r) => fromJson(r)).toList(growable: false);
    } catch (e) {
      debugPrint('Fetch "$table" failed, using seed: $e');
      return fallback;
    }
  }
}
