-- SuroyIloilo seed content — mirrors lib/data/seed_data.dart.
-- Run after schema.sql. Safe to re-run: it clears the tables first.
-- After this, edit rows in the Supabase Table editor to manage the app live.

truncate places, foods, routes, itinerary_stops, events, tips restart identity;

insert into places (id, name, category, area, rating, reviews, description, best_time, tip, map_query, lat, lng, sort) values
('molo-mansion','Molo Mansion','heritage','Molo',4.6,1280,'1920s American-era mansion turned lifestyle stop across the coral-stone Molo Church.','Late afternoon (4–6 PM)','Pair with the gothic Molo Church right beside it and grab pancit molo nearby.','Molo Mansion, Iloilo City',10.6957, 122.5480,1),
('jaro-cathedral','Jaro Cathedral & Belfry','landmark','Jaro',4.7,2140,'National shrine of Our Lady of the Candles with a rare standalone belfry across the plaza.','Early morning before mass crowds','The belfry sits across the street — a setup you rarely see in the Philippines.','Jaro Cathedral, Iloilo City',10.7203, 122.5577,2),
('esplanade','Iloilo River Esplanade','nature','Downtown',4.6,3010,'Award-winning riverside walkway, great for sunset strolls, jogging and street snacks.','Sunset (5–6 PM)','SM City sits on Esplanade 1 — start there and walk the boardwalk.','Iloilo River Esplanade',10.7089, 122.5494,3),
('camina','Camiña Balay nga Bato','museum','Arevalo',4.8,640,'Restored 1860s stone-and-wood ancestral home with a tsokolate (hot chocolate) tasting.','Afternoon tours (reserve ahead)','Call before going — it is a working heritage home, not a mall.','Camina Balay nga Bato, Arevalo, Iloilo City',10.6942, 122.5106,4),
('museo-iloilo','Museo Iloilo','museum','City Proper',4.4,520,'The province''s official museum — pre-colonial gold, artifacts and local art beside Calle Real.','Late morning','Combine with a Calle Real heritage walk right next door.','Museo Iloilo',10.7000, 122.5652,5),
('calle-real','Calle Real','landmark','City Proper',4.5,1890,'Restored heritage commercial street with art-deco facades — the old downtown of Iloilo.','Morning or golden hour','Look up — the best-preserved facades are on the upper floors.','Calle Real, Iloilo City',10.6958, 122.5679,6),
('gigantes','Islas de Gigantes','nature','Carles',4.8,1450,'Island-hopping day trip up north — sandbars, lagoons and famously cheap fresh scallops.','Very early start (leave by 4–5 AM)','Best as an overnight; day-tripping from the city is a long haul.','Islas de Gigantes, Carles, Iloilo',11.5960, 123.3420,7),
('garin-farm','Garin Farm Pilgrimage','hiddenGem','San Joaquin',4.3,980,'Agri-tourism farm with a dramatic white stairway to a hilltop pilgrimage site down south.','Morning (climb before the heat)','Wear light clothes — the stairway to the top is a real workout.','Garin Farm, San Joaquin, Iloilo',10.5900, 122.1420,8);

insert into foods (name, vendor, area, price_range, rating, reviews, description, must_try, icon, sort) values
('La Paz Batchoy','Ted''s Old Timer / Netong''s','La Paz Public Market','₱80–₱150',4.7,4200,'The original pork-noodle soup with chicharrón and liver — an Iloilo pilgrimage.','Special batchoy with extra chicharrón','ramen',1),
('Pancit Molo','Panaderia de Molo','Molo','₱90–₱160',4.5,1180,'Dumpling soup that originated in Molo district — comforting and homey.','Pancit molo + a bag of biscocho to go','soup',2),
('Biscocho & Barquillos','Biscocho Haus','Multiple branches','₱60–₱250',4.6,2600,'Buttery twice-baked bread — the classic pasalubong (take-home treat).','Butterscotch and barquillos','bakery',3),
('Fresh Talaba & Diwal','Villa / Arevalo seafood strip','Arevalo','₱200–₱600',4.6,870,'Fresh oysters and the prized "angel wing" clams, grilled or steamed by the bay.','Baked talaba with cheese','seafood',4),
('Kansi','Local kansihan carinderias','La Paz / Jaro','₱150–₱280',4.5,760,'Beef shank and bone-marrow soup soured with batwan — the Ilonggo bulalo-sinigang.','Kansi with extra marrow (utok)','rice',5),
('Chicken Inasal','Bacolod-style grillers','Citywide','₱120–₱220',4.6,3100,'Charcoal-grilled chicken marinated in annatto and calamansi, over garlic rice.','Pecho (breast) with chicken oil rice','grill',6);

insert into routes (from_label, to_label, mode, mode_icon, fare, time, steps, tip, sort) values
('Iloilo Airport (Cabatuan)','City Proper / SM City','Airport Shuttle Van · GT Express / Ungka','van','₱70–₱100','35–50 min','["Exit the terminal and head to the shuttle van bay","Ride a GT Express van toward the city / Ungka","Transfer to a local jeep for your final stop"]','Taxis and Grab are available but cost several times more.',1),
('City Proper (Plaza)','Molo Mansion & Church','Jeepney · Molo / Villa jeep','bus','₱13–₱15','15–20 min','["At the plaza, ride any ''Molo'' or ''Villa'' signed jeep","Tell the driver ''Molo Plaza'' or ''Molo Church''","Alight at the church; mansion is right across"]','Hand your fare forward and say ''bayad'' — pass it through other riders.',2),
('City Proper','Jaro Cathedral & Plaza','Jeepney · Jaro / Aganan jeep','bus','₱13–₱15','12–18 min','["Ride a ''Jaro-CPU'' or ''Jaro-Aganan'' jeep","Alight at Jaro Plaza","Cathedral and belfry face the plaza"]','The belfry is across the street — do not miss it.',3),
('City Proper','La Paz Batchoy (Public Market)','Jeepney · La Paz jeep','bus','₱13','10–15 min','["Ride any ''La Paz'' signed jeep","Alight at La Paz Plaza / public market","Walk into the market food stalls"]','Go before 11 AM or after 1 PM to avoid the batchoy lunch rush.',4),
('SM City Iloilo','Iloilo River Esplanade','Walk / Jeep · Diversion jeep','walk','₱13 or free walk','5–10 min','["From SM the Esplanade entrance is a short walk","Or ride a Diversion Road jeep one stop","Follow the riverside boardwalk"]','The stretch near SM is the liveliest at sunset.',5),
('City (Tagbak Terminal)','Islas de Gigantes (Carles)','Ceres Bus + Boat · Ceres Estancia/Carles','busFilled','₱180–₱220 bus','3.5–4 hrs bus','["Ride from Tagbak/Ceres Terminal to Bancal Port, Carles","At Bancal, join an island-hopping boat/tour package","Return by afternoon bus (last trips ~4–5 PM)"]','Best as an overnight or very early start — leave the city by 4–5 AM.',6);

insert into itinerary_stops (time_label, title, subtitle, fare, sort) values
('8:00 AM','Jaro Cathedral & Belfry','Cool morning, plaza walk','₱15 jeep',1),
('10:00 AM','Museo Iloilo + Calle Real','Heritage district on foot','₱15 jeep',2),
('12:00 NN','La Paz Batchoy lunch','Netong''s / Ted''s','₱13 jeep',3),
('2:00 PM','Molo Mansion & Church','Coral-stone church + photos','₱15 jeep',4),
('4:30 PM','Iloilo River Esplanade','Sunset boardwalk stroll','₱13 jeep',5),
('6:30 PM','Smallville / Iloilo Business Park','Dinner and night market','₱13 jeep',6);

insert into events (name, category, schedule, location, description, organizer, sort) values
('Dinagyang Festival','Festival','4th Sunday of January','City Proper (Freedom Grandstand)','Iloilo''s grandest festival — tribal drumbeats and painted warriors honoring Sto. Niño.','Iloilo Festivals Foundation',1),
('Paraw Regatta','Culture','February (Villa Beach)','Arevalo / Villa Beach','Asia''s oldest traditional sailboat race — colorful paraws racing across the strait.','Iloilo Paraw Regatta Foundation',2),
('Iloilo Food & Night Markets','Food','Weekends, year-round','Esplanade / Iloilo Business Park','Rotating food crawls and night markets along the river and in the business park.','Local LGU & vendors',3);

insert into tips (author, from_label, topic, text, helpful, sort) values
('Maria L.','from Manila','Getting around','Jeepneys don''t have exact stops — just say ''para'' loudly when you want to get off. Fare is usually ₱13 minimum.',214,1),
('Kenji T.','from Cebu','Molo','Do Molo Mansion + Molo Church + pancit molo in one trip, they are all beside each other. Half a day is enough.',178,2),
('Anna R.','from Iloilo (local)','La Paz Batchoy','For batchoy, the stalls inside La Paz market are the real deal — but you''ll wait a bit during lunch. Worth it.',132,3);
