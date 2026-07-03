-- Adds coordinates to places for the in-app map (and future passport
-- check-ins). Run once in the Supabase SQL editor if you already ran
-- schema.sql/seed.sql before this migration existed.
--
-- Coordinates are approximate pins for the pilot — verify in the field.

alter table places add column if not exists lat double precision default 0;
alter table places add column if not exists lng double precision default 0;

update places set lat = 10.6957, lng = 122.5480 where id = 'molo-mansion';
update places set lat = 10.7203, lng = 122.5577 where id = 'jaro-cathedral';
update places set lat = 10.7089, lng = 122.5494 where id = 'esplanade';
update places set lat = 10.6942, lng = 122.5106 where id = 'camina';
update places set lat = 10.7000, lng = 122.5652 where id = 'museo-iloilo';
update places set lat = 10.6958, lng = 122.5679 where id = 'calle-real';
update places set lat = 11.5960, lng = 123.3420 where id = 'gigantes';
update places set lat = 10.5900, lng = 122.1420 where id = 'garin-farm';
