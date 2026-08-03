# SuroyIloilo — Architecture

This document explains how the app is built and why. Diagrams are written in
Mermaid, which GitHub renders inline.

## 1. Principles

1. **Offline-first.** The app always renders instantly from bundled seed data,
   then upgrades to live Supabase content when the network allows. A missing
   table, a bad connection, or an unconfigured backend can never break the UI.
2. **Backend-optional.** With no credentials the app is fully functional on
   seed data. Supabase "lights up" when `.env.local` is present.
3. **No accounts.** All personal state (passport stamps, trip plan, nickname,
   hearts) is anonymous and stored on-device. An anonymous device id enables
   moderation without login.
4. **Free & keyless services.** Maps (OpenStreetMap), routing (OSRM) and
   geolocation (browser/OS) need no API keys.

## 2. System architecture

```mermaid
flowchart TD
    subgraph Client["Flutter app — Android · iOS · Web"]
      UI["Screens & widgets<br/>(landing, tabs, sheets)"]
      Scope["ContentScope<br/>(InheritedWidget state)"]
      Repos["Repositories<br/>content · community · passport · routing · trip"]
      Local["Device storage<br/>(shared_preferences)"]
      Seed["Bundled seed data<br/>(offline fallback)"]
    end

    subgraph Cloud["Supabase (optional)"]
      PG[("Postgres<br/>+ Row Level Security")]
      Store["Storage<br/>community-images"]
      RPC["RPC<br/>mark_helpful()"]
    end

    subgraph Ext["Free keyless services"]
      OSM["OpenStreetMap tiles"]
      OSRM["OSRM routing"]
      GPS["Browser / OS geolocation"]
    end

    UI --> Scope --> Repos
    Repos --> Local
    Repos --> Seed
    Repos -->|"content · posts"| PG
    Repos -->|"image upload"| Store
    Repos -->|"heart +1"| RPC
    UI --> OSM
    Repos --> OSRM
    Repos --> GPS

    Repos -. "fallback on any failure" .-> Seed
```

**Rule of thumb:** every dependency degrades gracefully. Remove the backend and
the app runs on seed; deny location and the map shows the destination pin;
drop the network and the route line is skipped but the fare guide remains.

## 3. Module layout

```
lib/
  main.dart              App entry, first-launch routing, bottom-nav shell
  config/env.dart        Loads .env.local (best effort)
  models.dart            Domain models + fromJson + string→glyph mappers
  data/
    content_repository   Fetch content from Supabase, seed fallback per table
    content_scope        InheritedWidget provider (seed now, live on arrival)
    community_repository Anonymous posts, image upload, hearts
    passport_repository  GPS check-ins, badges, fare-saved counter
    routing_service      OSRM road route (pure, testable)
    location_helper      Permission-safe, cached position lookup
    trip_planner         Nearest-neighbor day plan (pure)
    seed_data            Bundled offline content
  screens/               One file per tab + landing + passport
  widgets/               Directions sheet, route map, share sheets, plate
  theme.dart             Design tokens + shared UI atoms (SoftCard, Pill…)
```

## 4. Content load — offline-first sequence

```mermaid
sequenceDiagram
    participant App
    participant Scope as ContentScope
    participant Repo as ContentRepository
    participant SB as Supabase
    participant Seed

    App->>Scope: build()
    Scope->>Seed: AppContent.seed()
    Scope-->>App: render immediately (seed)
    Scope->>Repo: loadAll() [async]
    alt configured & reachable
      Repo->>SB: select() each table
      SB-->>Repo: rows
      Repo-->>Scope: AppContent(live)
      Scope-->>App: rebuild with live data
    else missing table / offline / unconfigured
      Repo-->>Scope: AppContent(seed) per table
      Note over Scope,App: UI unchanged, no error
    end
```

## 5. "Get directions" — API / data flow

```mermaid
sequenceDiagram
    participant U as User
    participant Sheet as DirectionsSheet
    participant Loc as location_helper
    participant RS as RoutingService
    participant OSRM
    participant Data as ContentScope (routes)

    U->>Sheet: tap "Get directions"
    Sheet->>Data: match place → jeepney route (fare, steps)
    Sheet-->>U: show ride/fare guide (from our data)
    Sheet->>Loc: fastPosition()
    alt permission granted
      Loc-->>Sheet: LatLng (cached or fresh)
      Sheet->>RS: fetch(user, destination)
      RS->>OSRM: GET /route/v1/driving/...
      OSRM-->>RS: geojson + distance + duration
      RS-->>Sheet: DrivingRoute
      Sheet-->>U: draw route line + ETA
    else denied / off
      Loc-->>Sheet: failure + hint
      Sheet-->>U: destination pin + Retry / Settings
    end
```

The jeepney guidance comes entirely from **our** data; OSRM only draws the
physical road line. That split is the product's edge — no maps API has Iloilo
jeepney fares.

## 6. Passport check-in — state machine

```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Locating: tap "Check in"
    Locating --> NoLocation: permission denied / off
    Locating --> TooFar: distance > 500 m
    Locating --> Stamped: distance ≤ 500 m
    NoLocation --> Idle: Retry / fix settings
    TooFar --> Idle: move closer, retry
    Stamped --> [*]: saved to device, badges recomputed
```

## 7. Data model (Supabase)

```mermaid
erDiagram
    PLACES {
      text id PK
      text name
      text category
      double lat
      double lng
      int sort
    }
    ROUTES {
      bigint id PK
      text from_label
      text to_label
      text mode_icon
      text fare
      jsonb steps
    }
    FOODS { bigint id PK }
    ITINERARY_STOPS { bigint id PK }
    EVENTS { bigint id PK }
    TIPS { bigint id PK }
    COMMUNITY_POSTS {
      uuid id PK
      text author
      text body
      text image_url
      int helpful
      text device_id
    }

    PLACES ||..o{ ROUTES : "matched by name (pilot)"
```

Content tables are **public-read, admin-write** (edited in the Supabase Table
editor). `community_posts` is **public-read + length-limited insert**; hearts
move only through the `mark_helpful` RPC. See [SECURITY.md](SECURITY.md).

## 8. Navigation flow

```mermaid
flowchart LR
    Launch --> First{First launch?}
    First -- yes --> Landing["Dayon landing"]
    First -- no --> Shell
    Landing -- "Plan my day" --> Plan["Plan tab"]
    Landing -- "Explore Iloilo" --> Home
    Shell["Bottom-nav shell"] --> Home & Places & Food & Rides & Plan & Community
    Places -- "Get directions" --> Sheet["Directions sheet<br/>(map + GPS + fare)"]
    Sheet -- "check in" --> Passport
    Header["Header ★"] --> Passport["Suroy Passport"]
```

## 9. Known pilot simplifications

- **Route matching** is by place-name substring — fine for 8 places, to be
  replaced by corridor geometry + graph search (no AI needed).
- **Coordinates** are approximate pins; verify in the field before launch.
- **Auth** is intentionally absent — see the roadmap in [PROJECT.md](../PROJECT.md).
