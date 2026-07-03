# SuroyIloilo — Project Brief

**Explore Iloilo like a local — and know exactly what to ride.**

A mobile travel companion for Iloilo City: curated places, local food,
ready-made day plans, community tips — and the layer no other app has:
**which jeepney to ride, where to transfer, and the honest fare.**

Status: Flutter app running · Supabase backend live · 100% free tier ·
Pilot city: Iloilo

---

## The idea — why this beats Google Maps here

Google, Grab and Wanderlog can show *where* Molo Mansion is. None of them can
tell you to *ride any "Molo/Villa" jeep from the plaza, hand ₱13 forward, say
"bayad," and get off at the church*. That commute-and-fare knowledge only
lives in locals' heads — SuroyIloilo turns it into structured data.

**That dataset is the product, the moat, and eventually the thing sponsors
pay to sit next to.**

---

## What's built so far

### The app — SHIPPED
- Six sections on a mobile bottom nav: Home, Places, Food, Rides, Plan, Community
- **Places** — 8 curated spots, category filters, ratings, best-time & local tips
- **Food** — 6 signature Ilonggo picks with price ranges and must-try orders
- **Rides** — fare basics + 6 step-by-step jeepney/bus routes with fares
- **Plan** — a full heritage day itinerary, timed, ~₱84 total in jeep fares
- **Get directions** — ride guide + hand-off to Google Maps (keyless URL);
  in-app map is a placeholder until the GPS phase

### Remote content, i.e. your "admin" — SHIPPED
All content loads from Supabase with the bundled seed as offline fallback —
edit a fare in the Table editor and the app updates on next launch, no
app-store release needed. Schema, seed SQL and setup docs live in `supabase/`.

### Community sharing — BUILT (activate by running `supabase/community.sql`)
Travelers post experiences with photos, no account needed: nickname + topic +
story, images to Supabase Storage. Tappable "found this helpful" hearts (one
per device, counted server-side). Moderation = deleting rows in the Table
editor.

### Engineering hygiene — SHIPPED
- Secrets git-ignored (`.env.local`), template committed, publishable key only
- Row Level Security: clients read-only except controlled inserts/hearts
- `flutter analyze` clean · widget tests passing · web build verified

### Branch train (merge in this order)
```
main ← feature/travel-buddy-mvp ← feature/bottom-nav
     ← feature/supabase-content ← feature/community-posts
```
Default-branch rename to `main` is pending on your side; each branch PRs into
the one before it.

---

## The hook — what makes people come back

Community posts alone make it "a social media of some sort." The unique,
hard-to-copy hook should come from the thing only this app has: **being
physically in Iloilo with jeepney data in your pocket.** That points to one
big idea:

### The Suroy Passport
A digital passport that **stamps itself when you actually go**. GPS check-ins
at places turn visits into collectible stamps; stamps build toward badges;
badges are shareable. Pokémon-Go logic applied to a city — and it needs **no
payment, no auth, and no new services**: GPS + the places table you already
have.

Example badges:
- Heritage Hunter — visit 5 heritage sites
- Batchoy Pilgrim — eat at the La Paz original
- Simbahan Trail — 4 churches
- Island Hopper — reach Gigantes

Every stamp screenshot shared on social media is free marketing with the
app's name on it.

### Supporting loops, ranked by pull

| Loop | Why it hooks | Needs |
|---|---|---|
| **Fare-saved counter** | "You've saved ₱1,240 vs taxis this month" — commuting becomes a score; locals check daily | Nothing new — fares are in the data |
| **Weekly challenge** | "This week: the Molo food crawl" — a reason to open the app every Monday | Events table (have it) |
| **Hearts on your post** | Contribution dopamine — already shipped, compounds with users | Done |
| **Local leaderboard** | Top explorers of the month — powerful later, empty-looking early | Passport first |

---

## Roadmap

1. **GPS + real map — NEXT**
   flutter_map + OpenStreetMap (free, keyless) in the directions sheet: your
   location, destination pin, route line, ETA — jeepney guide underneath.
   Also unlocks passport check-ins.

2. **Suroy Passport — NEXT**
   Check-in stamps, badges, fare-saved counter. The anonymous device id
   (already built for community) carries progress — still no auth.

3. **Ship to Google Play — $25 one-time**
   Icon, splash, listing, privacy policy, release build. The single
   highest-leverage move for real users.

4. **Analytics + corridor routing — LATER**
   Track direction-requests per place (the number sponsors buy). Restructure
   routes as corridors so directions work from anywhere — graph search over
   your own data, **no AI needed**.

5. **Notifications, then auth — LATER**
   Local event reminders first (free, no auth) → anonymous broadcast push →
   accounts only when saved trips & personalization justify them.

6. **Monetize — LATER**
   Featured listings for cafés/hotels (sold with direction-request stats) →
   tour affiliate links (Gigantes packages) → LGU/tourism partnership or
   startup grants. Ads only at real volume; AI concierge as garnish, grounded
   in your route data.

---

## Costs today

| Item | Now | When it starts costing |
|---|---|---|
| Flutter, flutter_map/OSM, geolocator | ₱0 | Never |
| Supabase (2nd project on Pro) | $10/mo | Already — or ₱0 if SuroyIloilo shares the covered project |
| Google Play developer account | $25 | One-time, at Play launch |
| Apple App Store | $99/yr | Only if/when iOS ships |
| Google Maps APIs | ₱0 | Optional swap-in later; ~10k free calls/SKU/mo |

---

## Open decisions (your move)

- [ ] Rename default branch to `main`, merge the branch train
- [ ] Run `supabase/community.sql` to switch on sharing
- [ ] Keep SuroyIloilo as its own $10/mo Supabase project, or fold into the covered one
- [ ] Green-light Phase 1 (GPS + map) and Phase 2 (Passport)

---

*SuroyIloilo · pilot edition for Iloilo City · fares & times are community
estimates for demo purposes.*
