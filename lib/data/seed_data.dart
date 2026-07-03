import 'package:flutter/material.dart';
import '../models.dart';

/// Hand-seeded pilot data for Iloilo City. Kept in-app so the prototype runs
/// fully offline. Fares and times are community estimates for demo purposes.

const List<Place> places = [
  Place(
    id: 'molo-mansion',
    name: 'Molo Mansion',
    category: PlaceCategory.heritage,
    area: 'Molo',
    rating: 4.6,
    reviews: 1280,
    description:
        '1920s American-era mansion turned lifestyle stop across the '
        'coral-stone Molo Church.',
    bestTime: 'Late afternoon (4–6 PM)',
    tip: 'Pair with the gothic Molo Church right beside it and grab pancit '
        'molo nearby.',
    mapQuery: 'Molo Mansion, Iloilo City',
    lat: 10.6957,
    lng: 122.548,
  ),
  Place(
    id: 'jaro-cathedral',
    name: 'Jaro Cathedral & Belfry',
    category: PlaceCategory.landmark,
    area: 'Jaro',
    rating: 4.7,
    reviews: 2140,
    description:
        'National shrine of Our Lady of the Candles with a rare standalone '
        'belfry across the plaza.',
    bestTime: 'Early morning before mass crowds',
    tip: 'The belfry sits across the street — a setup you rarely see in the '
        'Philippines.',
    mapQuery: 'Jaro Cathedral, Iloilo City',
    lat: 10.7203,
    lng: 122.5577,
  ),
  Place(
    id: 'esplanade',
    name: 'Iloilo River Esplanade',
    category: PlaceCategory.nature,
    area: 'Downtown',
    rating: 4.6,
    reviews: 3010,
    description:
        'Award-winning riverside walkway, great for sunset strolls, jogging '
        'and street snacks.',
    bestTime: 'Sunset (5–6 PM)',
    tip: 'SM City sits on Esplanade 1 — start there and walk the boardwalk.',
    mapQuery: 'Iloilo River Esplanade',
    lat: 10.7089,
    lng: 122.5494,
  ),
  Place(
    id: 'camina',
    name: 'Camiña Balay nga Bato',
    category: PlaceCategory.museum,
    area: 'Arevalo',
    rating: 4.8,
    reviews: 640,
    description:
        'Restored 1860s stone-and-wood ancestral home with a tsokolate (hot '
        'chocolate) tasting.',
    bestTime: 'Afternoon tours (reserve ahead)',
    tip: 'Call before going — it is a working heritage home, not a mall.',
    mapQuery: 'Camina Balay nga Bato, Arevalo, Iloilo City',
    lat: 10.6942,
    lng: 122.5106,
  ),
  Place(
    id: 'museo-iloilo',
    name: 'Museo Iloilo',
    category: PlaceCategory.museum,
    area: 'City Proper',
    rating: 4.4,
    reviews: 520,
    description:
        'The province\'s official museum — pre-colonial gold, artifacts and '
        'local art beside Calle Real.',
    bestTime: 'Late morning',
    tip: 'Combine with a Calle Real heritage walk right next door.',
    mapQuery: 'Museo Iloilo',
    lat: 10.7,
    lng: 122.5652,
  ),
  Place(
    id: 'calle-real',
    name: 'Calle Real',
    category: PlaceCategory.landmark,
    area: 'City Proper',
    rating: 4.5,
    reviews: 1890,
    description:
        'Restored heritage commercial street with art-deco facades — the old '
        'downtown of Iloilo.',
    bestTime: 'Morning or golden hour',
    tip: 'Look up — the best-preserved facades are on the upper floors.',
    mapQuery: 'Calle Real, Iloilo City',
    lat: 10.6958,
    lng: 122.5679,
  ),
  Place(
    id: 'gigantes',
    name: 'Islas de Gigantes',
    category: PlaceCategory.nature,
    area: 'Carles',
    rating: 4.8,
    reviews: 1450,
    description:
        'Island-hopping day trip up north — sandbars, lagoons and famously '
        'cheap fresh scallops.',
    bestTime: 'Very early start (leave by 4–5 AM)',
    tip: 'Best as an overnight; day-tripping from the city is a long haul.',
    mapQuery: 'Islas de Gigantes, Carles, Iloilo',
    lat: 11.596,
    lng: 123.342,
  ),
  Place(
    id: 'garin-farm',
    name: 'Garin Farm Pilgrimage',
    category: PlaceCategory.hiddenGem,
    area: 'San Joaquin',
    rating: 4.3,
    reviews: 980,
    description:
        'Agri-tourism farm with a dramatic white stairway to a hilltop '
        'pilgrimage site down south.',
    bestTime: 'Morning (climb before the heat)',
    tip: 'Wear light clothes — the stairway to the top is a real workout.',
    mapQuery: 'Garin Farm, San Joaquin, Iloilo',
    lat: 10.59,
    lng: 122.142,
  ),
];

const List<FoodSpot> foods = [
  FoodSpot(
    name: 'La Paz Batchoy',
    vendor: "Ted's Old Timer / Netong's",
    area: 'La Paz Public Market',
    priceRange: '₱80–₱150',
    rating: 4.7,
    reviews: 4200,
    description:
        'The original pork-noodle soup with chicharrón and liver — an Iloilo '
        'pilgrimage.',
    mustTry: 'Special batchoy with extra chicharrón',
    icon: Icons.ramen_dining,
  ),
  FoodSpot(
    name: 'Pancit Molo',
    vendor: 'Panaderia de Molo',
    area: 'Molo',
    priceRange: '₱90–₱160',
    rating: 4.5,
    reviews: 1180,
    description:
        'Dumpling soup that originated in Molo district — comforting and '
        'homey.',
    mustTry: 'Pancit molo + a bag of biscocho to go',
    icon: Icons.soup_kitchen,
  ),
  FoodSpot(
    name: 'Biscocho & Barquillos',
    vendor: 'Biscocho Haus',
    area: 'Multiple branches',
    priceRange: '₱60–₱250',
    rating: 4.6,
    reviews: 2600,
    description:
        'Buttery twice-baked bread — the classic pasalubong (take-home '
        'treat).',
    mustTry: 'Butterscotch and barquillos',
    icon: Icons.bakery_dining,
  ),
  FoodSpot(
    name: 'Fresh Talaba & Diwal',
    vendor: 'Villa / Arevalo seafood strip',
    area: 'Arevalo',
    priceRange: '₱200–₱600',
    rating: 4.6,
    reviews: 870,
    description:
        'Fresh oysters and the prized "angel wing" clams, grilled or steamed '
        'by the bay.',
    mustTry: 'Baked talaba with cheese',
    icon: Icons.set_meal,
  ),
  FoodSpot(
    name: 'Kansi',
    vendor: 'Local kansihan carinderias',
    area: 'La Paz / Jaro',
    priceRange: '₱150–₱280',
    rating: 4.5,
    reviews: 760,
    description:
        'Beef shank and bone-marrow soup soured with batwan — the Ilonggo '
        'bulalo-sinigang.',
    mustTry: 'Kansi with extra marrow (utok)',
    icon: Icons.rice_bowl,
  ),
  FoodSpot(
    name: 'Chicken Inasal',
    vendor: 'Bacolod-style grillers',
    area: 'Citywide',
    priceRange: '₱120–₱220',
    rating: 4.6,
    reviews: 3100,
    description:
        'Charcoal-grilled chicken marinated in annatto and calamansi, over '
        'garlic rice.',
    mustTry: 'Pecho (breast) with chicken oil rice',
    icon: Icons.outdoor_grill,
  ),
];

const List<CommuteRoute> routes = [
  CommuteRoute(
    from: 'Iloilo Airport (Cabatuan)',
    to: 'City Proper / SM City',
    mode: 'Airport Shuttle Van · GT Express / Ungka',
    modeIcon: Icons.airport_shuttle,
    fare: '₱70–₱100',
    time: '35–50 min',
    steps: [
      'Exit the terminal and head to the shuttle van bay',
      'Ride a GT Express van toward the city / Ungka',
      'Transfer to a local jeep for your final stop',
    ],
    tip: 'Taxis and Grab are available but cost several times more.',
  ),
  CommuteRoute(
    from: 'City Proper (Plaza)',
    to: 'Molo Mansion & Church',
    mode: 'Jeepney · Molo / Villa jeep',
    modeIcon: Icons.directions_bus,
    fare: '₱13–₱15',
    time: '15–20 min',
    steps: [
      "At the plaza, ride any 'Molo' or 'Villa' signed jeep",
      "Tell the driver 'Molo Plaza' or 'Molo Church'",
      'Alight at the church; mansion is right across',
    ],
    tip: "Hand your fare forward and say 'bayad' — pass it through other "
        'riders.',
  ),
  CommuteRoute(
    from: 'City Proper',
    to: 'Jaro Cathedral & Plaza',
    mode: 'Jeepney · Jaro / Aganan jeep',
    modeIcon: Icons.directions_bus,
    fare: '₱13–₱15',
    time: '12–18 min',
    steps: [
      "Ride a 'Jaro-CPU' or 'Jaro-Aganan' jeep",
      'Alight at Jaro Plaza',
      'Cathedral and belfry face the plaza',
    ],
    tip: 'The belfry is across the street — do not miss it.',
  ),
  CommuteRoute(
    from: 'City Proper',
    to: 'La Paz Batchoy (Public Market)',
    mode: 'Jeepney · La Paz jeep',
    modeIcon: Icons.directions_bus,
    fare: '₱13',
    time: '10–15 min',
    steps: [
      "Ride any 'La Paz' signed jeep",
      'Alight at La Paz Plaza / public market',
      'Walk into the market food stalls',
    ],
    tip: 'Go before 11 AM or after 1 PM to avoid the batchoy lunch rush.',
  ),
  CommuteRoute(
    from: 'SM City Iloilo',
    to: 'Iloilo River Esplanade',
    mode: 'Walk / Jeep · Diversion jeep',
    modeIcon: Icons.directions_walk,
    fare: '₱13 or free walk',
    time: '5–10 min',
    steps: [
      'From SM the Esplanade entrance is a short walk',
      'Or ride a Diversion Road jeep one stop',
      'Follow the riverside boardwalk',
    ],
    tip: 'The stretch near SM is the liveliest at sunset.',
  ),
  CommuteRoute(
    from: 'City (Tagbak Terminal)',
    to: 'Islas de Gigantes (Carles)',
    mode: 'Ceres Bus + Boat · Ceres Estancia/Carles',
    modeIcon: Icons.directions_bus_filled,
    fare: '₱180–₱220 bus',
    time: '3.5–4 hrs bus',
    steps: [
      'Ride from Tagbak/Ceres Terminal to Bancal Port, Carles',
      'At Bancal, join an island-hopping boat/tour package',
      'Return by afternoon bus (last trips ~4–5 PM)',
    ],
    tip: 'Best as an overnight or very early start — leave the city by 4–5 AM.',
  ),
];

const List<ItineraryStop> heritageDayPlan = [
  ItineraryStop(
    time: '8:00 AM',
    title: 'Jaro Cathedral & Belfry',
    subtitle: 'Cool morning, plaza walk',
    fare: '₱15 jeep',
  ),
  ItineraryStop(
    time: '10:00 AM',
    title: 'Museo Iloilo + Calle Real',
    subtitle: 'Heritage district on foot',
    fare: '₱15 jeep',
  ),
  ItineraryStop(
    time: '12:00 NN',
    title: 'La Paz Batchoy lunch',
    subtitle: "Netong's / Ted's",
    fare: '₱13 jeep',
  ),
  ItineraryStop(
    time: '2:00 PM',
    title: 'Molo Mansion & Church',
    subtitle: 'Coral-stone church + photos',
    fare: '₱15 jeep',
  ),
  ItineraryStop(
    time: '4:30 PM',
    title: 'Iloilo River Esplanade',
    subtitle: 'Sunset boardwalk stroll',
    fare: '₱13 jeep',
  ),
  ItineraryStop(
    time: '6:30 PM',
    title: 'Smallville / Iloilo Business Park',
    subtitle: 'Dinner and night market',
    fare: '₱13 jeep',
  ),
];

const List<Event> events = [
  Event(
    name: 'Dinagyang Festival',
    category: 'Festival',
    schedule: '4th Sunday of January',
    location: 'City Proper (Freedom Grandstand)',
    description:
        "Iloilo's grandest festival — tribal drumbeats and painted warriors "
        'honoring Sto. Niño.',
    organizer: 'Iloilo Festivals Foundation',
  ),
  Event(
    name: 'Paraw Regatta',
    category: 'Culture',
    schedule: 'February (Villa Beach)',
    location: 'Arevalo / Villa Beach',
    description:
        "Asia's oldest traditional sailboat race — colorful paraws racing "
        'across the strait.',
    organizer: 'Iloilo Paraw Regatta Foundation',
  ),
  Event(
    name: 'Iloilo Food & Night Markets',
    category: 'Food',
    schedule: 'Weekends, year-round',
    location: 'Esplanade / Iloilo Business Park',
    description:
        'Rotating food crawls and night markets along the river and in the '
        'business park.',
    organizer: 'Local LGU & vendors',
  ),
];

const List<TravelerTip> tips = [
  TravelerTip(
    author: 'Maria L.',
    from: 'from Manila',
    topic: 'Getting around',
    text:
        "Jeepneys don't have exact stops — just say 'para' loudly when you "
        'want to get off. Fare is usually ₱13 minimum.',
    helpful: 214,
  ),
  TravelerTip(
    author: 'Kenji T.',
    from: 'from Cebu',
    topic: 'Molo',
    text:
        'Do Molo Mansion + Molo Church + pancit molo in one trip, they are '
        'all beside each other. Half a day is enough.',
    helpful: 178,
  ),
  TravelerTip(
    author: 'Anna R.',
    from: 'from Iloilo (local)',
    topic: 'La Paz Batchoy',
    text:
        'For batchoy, the stalls inside La Paz market are the real deal — but '
        "you'll wait a bit during lunch. Worth it.",
    helpful: 132,
  ),
];
