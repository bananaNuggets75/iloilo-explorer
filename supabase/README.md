# Supabase setup

The app is **offline-first**: it ships with bundled seed data and works with no
backend. Supabase "lights up" automatically once credentials and tables exist —
then content can be managed live without shipping an app update.

## 1. Credentials

Copy `.env.example` to `.env.local` (git-ignored) and fill in:

```
NEXT_PUBLIC_SUPABASE_URL=https://<project>.supabase.co
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=sb_publishable_xxx
```

Find both under **Project Settings > API** (URL, and the publishable key).
Do **not** use the service_role / secret key in the app.

## 2. Create the tables

Supabase dashboard > **SQL Editor** > New query > paste `schema.sql` > Run.
This creates the tables and enables public read-only access (Row Level
Security), so the publishable key can read content but not modify it.

## 3. Load the starter content

Run `seed.sql` the same way. It mirrors the app's bundled data so live content
matches what you already see. (Safe to re-run — it truncates first.)

## 4. Manage content (your admin)

Use the Supabase **Table editor** as your admin panel: edit `places`, `foods`,
`routes`, `events`, `itinerary_stops`, `tips` like a spreadsheet. The app picks
up changes on next launch. Column keys match `lib/models.dart`; `sort` controls
order. Icon/category columns use short string keys mapped in the app
(`iconFromKey`, `PlaceCategoryX.fromKey`).

## How the app uses it

`lib/data/content_repository.dart` fetches each table and falls back to seed
data table-by-table on any error, so a missing table or offline device never
breaks the UI. `ContentScope` shows seed data instantly, then rebuilds when
Supabase responds.
