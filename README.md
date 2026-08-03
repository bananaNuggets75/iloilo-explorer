# SuroyIloilo

A local travel companion for **Iloilo City** — places, local food, jeepney
routes with honest fares, a ready-made day plan, events, and tips from
travelers. Built with Flutter.

The differentiator vs. Google Maps / Wanderlog: the **commute and fare
layer** — which jeep to ride, where to transfer, what to say to the driver,
and what you'll pay.

## Sections (bottom navigation)

- **Home** — hero, feature grid, featured spots, stats, day-plan CTA
- **Places** — curated spots with category filters, ratings, best-time and
  local tips, plus a **Get directions** flow
- **Food** — signature Ilonggo dishes, where to get them, price ranges and
  must-try picks
- **Rides** — fare basics plus step-by-step commute routes (jeep sign to
  look for, fare, time, transfer notes)
- **Plan** — a full heritage day itinerary with timings and jeep fares
- **Community** — highlighted events and traveler tips

### Get directions (Maps placeholder)

Tapping **Get directions** on a place opens a sheet with a from → to plan,
the matching ride/fare guide, and an "Open in Google Maps" hand-off using a
keyless maps URL. The in-sheet map is a **placeholder** — live, Grab-style
in-app navigation (current location → destination with the route drawn on
the map) comes once Google Maps API credentials are added.

## Documentation

- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — system, data-flow, API,
  sequence, ER and navigation diagrams
- [docs/SECURITY.md](docs/SECURITY.md) — secrets, Row Level Security, privacy
- [docs/TESTING.md](docs/TESTING.md) — the test pyramid and how to run it
- [PROJECT.md](PROJECT.md) — product brief, roadmap and revenue thinking

## Project structure

```
lib/
  main.dart                    App shell: brand header, bottom nav, tabs
  theme.dart                   Colors, typography, shared UI building blocks
  models.dart                  Place, FoodSpot, CommuteRoute, Event, tips...
  data/seed_data.dart          Offline pilot content (edit me!)
  screens/
    home_tab.dart              Home
    places_tab.dart            Places + category filters
    food_tab.dart              Food
    commute_tab.dart           Rides (fare basics + routes)
    itinerary_tab.dart         Plan (day itinerary timeline)
    community_tab.dart         Community (events + tips)
  widgets/
    directions_sheet.dart      Get-directions sheet + Maps placeholder
```

## Run it

The native platform folders (`android/`, `ios/`, etc.) are not checked in;
generate them once, then run:

```bash
flutter create .     # adds platform folders without touching lib/
flutter pub get
flutter run -d chrome        # quickest way to test
```

For the Android emulator: `flutter emulators --launch <id>` then
`flutter run`. Run `flutter doctor` if a platform is missing.

**Android location permission** (the platform folders are generated, so this
must be re-added after `flutter create .`): in
`android/app/src/main/AndroidManifest.xml`, inside `<manifest>` add

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

On web/Chrome the browser asks for location permission by itself — nothing to
configure.

## Editing content

All pilot content lives in `lib/data/seed_data.dart` — places, food, routes,
the day plan, events and tips. Copy an existing entry and edit; the UI
updates automatically. This will move to Supabase so content can be managed
remotely without shipping an app update.

## Secrets

API keys (Supabase, Google Maps) belong in `.env.local`, which is
git-ignored. Never commit credentials.

## Roadmap

- [ ] Supabase backend: load content remotely with offline fallback
- [ ] Admin: manage places/fares/events dynamically (Supabase table editor
      first, custom dashboard later)
- [ ] Google Maps: live location -> destination routing in-app (Grab-style)
- [ ] Place detail pages with photos
- [ ] User accounts, saved trips and user-submitted tips
- [ ] Sponsored listings / local business dashboard (monetization)

> Note: fares and travel times are community estimates for demo purposes.
> Verify current jeepney fares before publishing.
