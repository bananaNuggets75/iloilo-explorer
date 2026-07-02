# Iloilo Travel Buddy

A local travel companion for **Iloilo City** — discover places, local food,
jeepney routes, fares, and traveler tips in one app. Built with Flutter.

The differentiator vs. Google Maps / Wanderlog: a **commute + fare layer** that
tells you *which jeepney to ride and how much it costs*, plus locally-curated
food and traveler tips.

## What's inside (Phase 1 — offline MVP)

- Search places by name, area, or food
- Filter by category (Heritage, Food, Nature, Café, Museum…)
- Place details with description, rating, and best time to visit
- Local food to try near each spot
- **How to get there** — step-by-step commute with jeepney, walk, fare & time
- Traveler tips
- Works fully offline (data seeded in `lib/data/seed_places.dart`)

## Project structure

```
lib/
  main.dart                     App entry + theme
  models/place.dart             Domain models (Place, CommuteGuide, RouteStep…)
  data/seed_places.dart         Hand-seeded Iloilo data (edit me!)
  screens/
    home_screen.dart            Search + filter + list
    place_detail_screen.dart    Commute/fare breakdown, food, tips
  widgets/
    place_card.dart             List card
```

## Run it

This repo contains the Dart sources (`lib/`) and `pubspec.yaml`. The native
platform folders (`android/`, `ios/`) are not checked in, so generate them
once on your machine:

```bash
flutter create .        # adds android/, ios/, etc. without touching lib/
flutter pub get
flutter run
```

Requires the Flutter SDK (3.3+). If you're new: https://docs.flutter.dev/get-started/install

## Testing on a simulator

### iOS Simulator (macOS only)

1. Install Xcode from the App Store, then its command-line tools:
   `xcode-select --install`.
2. Open a simulator: `open -a Simulator`.
3. Confirm Flutter sees it: `flutter devices`.
4. Run the app: `flutter run` (or press F5 / "Run" in VS Code).

### Android Emulator

1. Install Android Studio, then create a virtual device via
   **Device Manager > Create Device**.
2. List available emulators: `flutter emulators`.
3. Launch one: `flutter emulators --launch <emulator_id>`.
4. Run the app: `flutter run`.

### Quick sanity check

Run `flutter doctor` first — it lists anything missing (Xcode, Android SDK,
licenses) with fix instructions.

## Add your own spots

Everything is driven by `lib/data/seed_places.dart`. Copy an existing `Place`
entry and edit the fields — the UI updates automatically.

## Roadmap ideas

- [ ] Day-by-day itinerary builder
- [ ] Map view (google_maps_flutter)
- [ ] Move data to Firestore / Supabase (same `Place` models)
- [ ] User-submitted tips & photos
- [ ] AI trip planner ("Plan a 3-day Iloilo trip under ₱5,000")
- [ ] Sponsored local listings & coupons (monetization)

> Note: Fares/times in the seed data are rough estimates for demo purposes.
> Verify real jeepney fares before publishing.
