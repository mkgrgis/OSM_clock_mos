-- Ниже экспериментальные вычисления по столбам
REFRESH MATERIALIZED VIEW "Часы Москвы"."1 Столбы data.mos.ru";
SELECT count(*) FROM "Часы Москвы"."1 Столбы data.mos.ru";

CREATE MATERIALIZED VIEW "Часы Москвы"."2 Области столбов ОД 10" AS
SELECT x.φλ,
       x."Код",
       x."№",
       ST_Buffer(st_transform(x.φλ,4326)::geography, 10.0) b
  FROM "Часы Москвы"."1 Столбы data.mos.ru" x;
CREATE INDEX "2 Области столбов ОД 10 b IDX" ON "Часы Москвы"."2 Области столбов ОД 10" (b);  
  
CREATE MATERIALIZED VIEW "Часы Москвы"."2 Области столбов ОД 15" AS
SELECT x.φλ,
       x."Код",
       x."№",
       ST_Buffer(st_transform(x.φλ,4326)::geography, 15.0) b
  FROM "Часы Москвы"."1 Столбы data.mos.ru" x;
CREATE INDEX "2 Области столбов ОД 15 b IDX" ON "Часы Москвы"."2 Области столбов ОД 15" (b);
  
CREATE MATERIALIZED VIEW "Часы Москвы"."2 Области столбов ОД 20" AS
SELECT x.φλ,
       x."Код",
       x."№",
       ST_Buffer(st_transform(x.φλ,4326)::geography, 20.0) b
  FROM "Часы Москвы"."1 Столбы data.mos.ru" x;
CREATE INDEX "2 Области столбов ОД 20 b IDX" ON "Часы Москвы"."2 Области столбов ОД 20" (b);  
  
CREATE MATERIALIZED VIEW "Часы Москвы"."2 Области столбов ОД 8" AS
SELECT x.φλ,
       x."Код",
       x."№",
       ST_Buffer(st_transform(x.φλ,4326)::geography, 8) b
  FROM "Часы Москвы"."1 Столбы data.mos.ru" x;  
CREATE INDEX "2 Области столбов ОД 8 b IDX" ON "Часы Москвы"."2 Области столбов ОД 8" (b);

CREATE MATERIALIZED VIEW "Часы Москвы"."2 Области столбов ОД 5" AS
SELECT x.φλ,
       x."Код",
       x."№",
       ST_Buffer(st_transform(x.φλ,4326)::geography, 5) b
  FROM "Часы Москвы"."1 Столбы data.mos.ru" x;
CREATE INDEX "2 Области столбов ОД 5 b IDX" ON "Часы Москвы"."2 Области столбов ОД 5" (b);  

CREATE MATERIALIZED VIEW "Часы Москвы"."2 Области столбов OSM 15" AS
SELECT x.φλ,
       x."Код",
       x."№",
       ST_Buffer(st_transform(x.φλ,4326)::geography, 15.0) b
  FROM "Часы Москвы"."1 Столбы OSM" x;  
CREATE INDEX "2 Области столбов OSM 15 b IDX" ON "Часы Москвы"."2 Области столбов OSM 15" (b);

CREATE MATERIALIZED VIEW "Часы Москвы"."2 Области столбов OSM 20" as
SELECT x.φλ,
       x."Код",
       x."№",
       ST_Buffer(st_transform(x.φλ,4326)::geography, 20.0) b
  FROM "Часы Москвы"."1 Столбы OSM" x;  
CREATE INDEX "2 Области столбов OSM 20 b IDX" ON "Часы Москвы"."2 Области столбов OSM 20" (b);

CREATE MATERIALIZED VIEW "Часы Москвы"."2 Области столбов OSM 8" AS
SELECT x.φλ,
       x."Код",
       x."№",
       ST_Buffer(st_transform(x.φλ,4326)::geography, 8) b
  FROM "Часы Москвы"."1 Столбы OSM" x;
CREATE INDEX "2 Области столбов OSM 8 b IDX" ON "Часы Москвы"."2 Области столбов OSM 8" (b);  
  
CREATE MATERIALIZED VIEW "Часы Москвы"."2 Области столбов OSM 5" AS
SELECT x.φλ,
       x."Код",
       x."№",
       ST_Buffer(st_transform(x.φλ,4326)::geography, 5) b
  FROM "Часы Москвы"."1 Столбы OSM" x;  
CREATE INDEX "2 Области столбов OSM 5 b IDX" ON "Часы Москвы"."2 Области столбов OSM 5" (b);
  

DROP MATERIALIZED VIEW "Часы Москвы"."3 Столбы с привязкой";
CREATE MATERIALIZED VIEW "Часы Москвы"."3 Столбы с привязкой" as
SELECT сo."Код OSM",
       сo.φλ φλ_OSM,       
       сo."Оператор",
       сo."n💡" "n💡 OSM",
       сo."Ввод в строй",
       см.*,
       ST_Distance(st_transform(сo.φλ,4326)::geography, st_transform(см.φλ,4326)::geography) "Δ м"
  FROM "Часы Москвы"."2 Области столбов ОД" см   
  LEFT JOIN "Часы Москвы"."1 Столбы OSM" сo 
    ON ST_Contains(см.b, сo.φλ);
   
   
select сп.*
  from "Часы Москвы"."3 Столбы с привязкой" сп
-- inner join "Часы Москвы"."1 Столбы data.mos.ru" сdmr
--    on сdmr."Код" = сп."Код"
 where сп."Округ" = 'Южный административный округ'
   and сп.φλ_osm is not null;
