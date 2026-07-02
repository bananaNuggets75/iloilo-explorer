import '../models/place.dart';

/// Hand-seeded starter data for Iloilo City.
///
/// This lives in the app for now so it works fully offline and needs no
/// backend. When you're ready to scale, move this to Firestore / Supabase
/// and load it into the same `Place` models — the UI won't have to change.
///
/// NOTE: fares and times are rough estimates for demo purposes. Verify real
/// jeepney fares before publishing (minimum fare in Iloilo is around ₱12–13).
const List<Place> seedPlaces = [
  Place(
    id: 'molo-mansion',
    name: 'Molo Mansion',
    category: PlaceCategory.heritage,
    area: 'Molo',
    description:
        'A restored 1920s mansion beside the coral-stone Molo Church, now home '
        'to shops and a garden. Great for photos and pasalubong.',
    rating: 4.5,
    localFood: ['Pancit Molo', 'Kansi', 'Fresh lumpia'],
    bestTime: 'Late afternoon (softer light, cooler)',
    commutes: [
      CommuteGuide(
        from: 'SM City Iloilo',
        steps: [
          RouteStep(
            instruction: 'Ride a Molo-bound jeepney along the highway',
            mode: 'jeepney',
            fare: 13,
            minutes: 15,
          ),
          RouteStep(
            instruction: 'Walk to Molo Plaza / Molo Mansion',
            mode: 'walk',
            fare: 0,
            minutes: 4,
          ),
        ],
      ),
    ],
    tips: [
      TravelerTip(
        author: 'Aina',
        text: 'Pair it with Molo Church right across — both in one stop.',
        rating: 5,
      ),
      TravelerTip(
        author: 'Marco',
        text: 'The garden café gets busy on weekends, go early.',
        rating: 4,
      ),
    ],
  ),
  Place(
    id: 'jaro-cathedral',
    name: 'Jaro Cathedral',
    category: PlaceCategory.heritage,
    area: 'Jaro',
    description:
        'The National Shrine of Our Lady of the Candles, with a belfry across '
        'the street — a rare setup in the Philippines.',
    rating: 4.6,
    localFood: ['La Paz Batchoy (nearby)', 'Biscocho', 'Barquillos'],
    bestTime: 'Early morning before mass crowds',
    commutes: [
      CommuteGuide(
        from: 'City Proper (Iloilo Terminal Market)',
        steps: [
          RouteStep(
            instruction: 'Ride a Jaro-CPU or Jaro-Liko jeepney',
            mode: 'jeepney',
            fare: 13,
            minutes: 12,
          ),
          RouteStep(
            instruction: 'Walk to the plaza and cathedral',
            mode: 'walk',
            fare: 0,
            minutes: 3,
          ),
        ],
      ),
    ],
    tips: [
      TravelerTip(
        author: 'Denise',
        text: 'Climb up to see the belfry, and grab biscocho nearby.',
        rating: 5,
      ),
    ],
  ),
  Place(
    id: 'la-paz-batchoy',
    name: 'La Paz Public Market (Batchoy)',
    category: PlaceCategory.food,
    area: 'La Paz',
    description:
        'The birthplace of La Paz Batchoy. Deko\'s and Ted\'s are the classic '
        'stalls — noodle soup with pork, liver, and chicharrón.',
    rating: 4.7,
    localFood: ['La Paz Batchoy', 'Puto', 'Fresh calamansi juice'],
    bestTime: 'Late morning for a hot early lunch',
    commutes: [
      CommuteGuide(
        from: 'SM City Iloilo',
        steps: [
          RouteStep(
            instruction: 'Ride a La Paz jeepney',
            mode: 'jeepney',
            fare: 13,
            minutes: 10,
          ),
          RouteStep(
            instruction: 'Walk into the public market food area',
            mode: 'walk',
            fare: 0,
            minutes: 3,
          ),
        ],
      ),
    ],
    tips: [
      TravelerTip(
        author: 'JR',
        text: 'Ask for extra chicharrón on top. Trust me.',
        rating: 5,
      ),
    ],
  ),
  Place(
    id: 'iloilo-esplanade',
    name: 'Iloilo River Esplanade',
    category: PlaceCategory.nature,
    area: 'City Proper',
    description:
        'A scenic riverside boardwalk for jogging, walking, and sunset views. '
        'Several sections connect the city.',
    rating: 4.5,
    localFood: ['Street snacks', 'Ice cream carts'],
    bestTime: 'Sunset (5–6 PM)',
    commutes: [
      CommuteGuide(
        from: 'SM City Iloilo',
        steps: [
          RouteStep(
            instruction: 'Walk along the riverfront — SM sits on Esplanade 1',
            mode: 'walk',
            fare: 0,
            minutes: 2,
          ),
        ],
      ),
    ],
    tips: [
      TravelerTip(
        author: 'Kim',
        text: 'Free and safe. Best spot for a chill evening walk.',
        rating: 5,
      ),
    ],
  ),
  Place(
    id: 'camina-balay',
    name: 'Camiña Balay nga Bato',
    category: PlaceCategory.museum,
    area: 'Arevalo',
    description:
        'A preserved 1860s heritage house offering tsokolate (native hot '
        'chocolate) and a guided look at old Ilonggo life.',
    rating: 4.6,
    localFood: ['Tsokolate', 'Ilonggo kakanin'],
    bestTime: 'Reserve ahead; afternoon tours',
    commutes: [
      CommuteGuide(
        from: 'City Proper',
        steps: [
          RouteStep(
            instruction: 'Ride an Arevalo (Villa) jeepney',
            mode: 'jeepney',
            fare: 13,
            minutes: 18,
          ),
          RouteStep(
            instruction: 'Walk to Osmeña Street',
            mode: 'walk',
            fare: 0,
            minutes: 5,
          ),
        ],
      ),
    ],
    tips: [
      TravelerTip(
        author: 'Patricia',
        text: 'Call before going — it\'s a working heritage home, not a mall.',
        rating: 5,
      ),
    ],
  ),
];
