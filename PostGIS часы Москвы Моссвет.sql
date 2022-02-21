-- ЧАСЫ И СТОЛБЫ МОСКВЫ
-- Таблицы
-- О ЗАГРУЗКЕ в таблицы см. https://wiki.openstreetmap.org/wiki/RU:Москва/Импорт_уличных_часов_Моссвет#.D0.9F.D0.BE.D0.B4.D0.B3.D0.BE.D1.82.D0.BE.D0.B2.D0.BA.D0.B0_.D1.82.D0.B0.D0.B1.D0.BB.D0.B8.D1.86

CREATE TABLE "Часы Москвы"."data.mos.ru Часы" (
	"GeoJSON" jsON NOT NULL
);
COMMENT ON TABLE "Часы Москвы"."data.mos.ru Часы" IS 'https://data.mos.ru/opendata/1499';


CREATE TABLE "Часы Москвы"."OSM OverPass столбы" (
    "JSON" jsON NOT NULL
);
COMMENT ON TABLE "Часы Москвы"."OSM OverPass столбы" IS '[out:json];
node
  [highway=street_lamp]
  ({{bbox}});  
out;';

CREATE TABLE "Часы Москвы"."OSM OverPass часы" (
    "JSON" jsON NOT NULL
);
COMMENT ON TABLE "Часы Москвы"."OSM OverPass часы" IS '[out:json];
node
  [amenity=clock]
  ({{bbox}});  
out;';

CREATE TABLE "Часы Москвы"."∄" (
    "ref:data.mos.ru" int4 NOT NULL
);
COMMENT ON TABLE "Часы Москвы"."∄" IS 'Не существуют, ошибки в данных';


CREATE TABLE "Часы Москвы"."data.mos.ru столбы" (
	"JSON" jsON NOT NULL
);
COMMENT ON TABLE "Часы Москвы"."data.mos.ru столбы" IS 'https://data.mos.ru/opendata/61762';

-- ПРЕДСТАВЛЕНИЯ
-- возможная полная очистска перед пересозданием
-- DROP VIEW "Часы Москвы"."1 Часы OSM" CASCADE;
-- DROP VIEW "Часы Москвы"."1 Часы Моссвет" CASCADE;
-- DROP MATERIALIZED VIEW "Часы Москвы"."1 Столбы OSM" CASCADE;


-- Из набора открытых данных
CREATE OR REPLACE VIEW "Часы Москвы"."1 Часы Моссвет"
AS WITH data AS (
SELECT "GeoJSON" fc
  FROM "Часы Москвы"."data.mos.ru Часы"
), f AS (
 SELECT json_array_elements(data.fc -> 'features') ft
   FROM data
)
SELECT row_number() OVER () "№",
       st_geomFROMgeojson(f.ft ->> 'geometry') "φλ",    
       (((f.ft -> 'properties') -> 'Attributes') ->> 'global_id')::int4 "Код",    
       (((f.ft -> 'properties') -> 'Attributes') ->> 'PhotoClockType') "ФотоТип",
       ((f.ft -> 'properties') -> 'Attributes') ->> 'Location'::text "Адрес",
       ((f.ft -> 'properties') -> 'Attributes') ->> 'Type'::text "Тип",
       (((f.ft -> 'properties') -> 'Attributes') ->> 'Power')::double precisiON "кВт",
       ((f.ft -> 'properties') -> 'Attributes') ->> 'AdmArea'::text "Округ",
       ((f.ft -> 'properties') ->> 'RowId')::int4 "Код записи",
       ((f.ft -> 'properties') ->> 'DatasetId')::int4 "Код таблицы",
       ((f.ft -> 'properties') ->> 'VersionNumber')::int4 "Версия табл."
  FROM f;
   
CREATE OR REPLACE VIEW "Часы Москвы"."1 Часы OSM" AS
WITH data AS (
SELECT "OSM OverPass часы"."JSON" fc
 FROM "Часы Москвы"."OSM OverPass часы"
), f AS (
SELECT json_array_elements(data.fc -> 'elements') ft
 FROM data
)
SELECT row_number() OVER () "№",
       (f.ft ->> 'id')::int8 "Код OSM",
       st_setsrid(st_point((f.ft ->> 'lon')::double precision, (f.ft ->> 'lat')::double precision), 4326) "φλ",    
       f.ft -> 'tags'::text a,
       (f.ft -> 'tags') ->> 'name'::text "Название",
       (f.ft -> 'tags') ->> 'display'::text "Вывод",
       (f.ft -> 'tags') ->> 'date'::text "Показ даты",
       (f.ft -> 'tags') ->> 'visibility'::text "Обзор",
       (f.ft -> 'tags') ->> 'support'::text "Крепление"
  FROM f;

CREATE MATERIALIZED VIEW "Часы Москвы"."1 Столбы OSM"
AS WITH data AS (
SELECT "JSON" AS fc
  FROM "Часы Москвы"."OSM OverPass столбы"
), f AS (
SELECT json_array_elements(data.fc -> 'elements') ft
  FROM data
)
SELECT row_number() OVER () "№",
       f.ft ->> 'id'::text "Код OSM",
       st_setsrid(st_point((f.ft ->> 'lon')::double precision, (f.ft ->> 'lat')::double precision), 4326) "φλ",    
       f.ft -> 'tags' ->> 'height' "Высота",
       f.ft -> 'tags' ->> 'highway' "Уличное",    
       f.ft -> 'tags' ->> 'lamp_mount' "Крепление",
       f.ft -> 'tags' ->> 'lamp_type' "Тип лампы",
       f.ft -> 'tags' ->> 'light:colour' "Цвет света",
       f.ft -> 'tags' ->> 'light:count' "n💡",
       f.ft -> 'tags' ->> 'mast:colour' "Цвет столба",
       f.ft -> 'tags' ->> 'mast:material' "Материал столба",
       f.ft -> 'tags' ->> 'note' "Заметка",
       f.ft -> 'tags' ->> 'operator' "Оператор",
       f.ft -> 'tags' ->> 'ref' "Код",
       f.ft -> 'tags' ->> 'start_date' "Ввод в строй",       
       (f.ft -> 'tags')::jsonb
       - 'height' - 'highway' - 'lamp_mount' - 'lamp_type' - 'light:colour' - 'light:count'
       - 'mast:colour' - 'mast:material' - 'note' - 'operator' - 'ref' - 'start_date' t    
  FROM f;
--CREATE INDEX "1_Столбы_OSM_φλ_IDX" ON "Часы Москвы"."1 Столбы OSM" (φλ);
CREATE INDEX "1_Столбы_OSM_geo_IDX" ON "Часы Москвы"."1 Столбы OSM" ((st_transform(φλ,4326)::geography));
   
-- "Часы Москвы"."2 Теги на Моссвет" потом используются не все теги
CREATE OR REPLACE VIEW "Часы Москвы"."2 Теги на Моссвет" AS
SELECT "φλ",    
       "Код" "ref:data.mos.ru",
       "Тип" "clock:model",
       "кВт"::text || ' kVA'::text "rating",
       'ООО «Новый город»'::text "operator",
       '+7 499 2673071' "contact:phone",
       'ГУП «Моссвет»' "owner",
       'street'::text "visibility",
       'analog'::text "display",
       CASE WHEN "ч"."Тип" = 'Часы 2С на опоре'::text
            THEN 'pole'::text
            ELSE NULL::text
        END "support",
       'https://data.mos.ru/opendata/1499'::text "source",
       'clock'::text "amenity",
       'https://data.mos.ru/opendata/1499/row/' || "Код" "website",
       -"№" id
  FROM "Часы Москвы"."1 Часы Моссвет" "ч";
   
-- Часы, которые уже есть в OSM  с добавлением распознанных данных Моссвета
CREATE OR REPLACE VIEW "Часы Москвы"."2 Часы с привязкой" AS
SELECT чo."Код OSM",
       чo.φλ φλ_OSM,
       чo.a,
       чм.*,
       ST_Distance(st_transform(чo.φλ,4326)::geography, st_transform(чм.φλ,4326)::geography) "Δ м"
  FROM "Часы Москвы"."1 Часы Моссвет" чм   
 INNER JOIN "Часы Москвы"."1 Часы OSM" чo 
    ON ST_Distance(st_transform(чo.φλ,4326)::geography, st_transform(чм.φλ,4326)::geography) < 17;   
   
-- Часы, опора которых уже есть в OSM с добавлением распознанных данных Моссвета
CREATE OR REPLACE VIEW "Часы Москвы"."2 Часы на опорах" AS
SELECT сo."№",
       сo."Код OSM",
       сo."φλ" "φλ опоры",
       сo.t,
       чм."φλ" "φλ часов",
       чм."Код",
       ST_Distance(st_transform(сo.φλ,4326)::geography, st_transform(чм.φλ,4326)::geography) "Δ м"
  FROM "Часы Москвы"."1 Столбы OSM" сo
  JOIN "Часы Москвы"."1 Часы Моссвет" чм
    ON ST_Distance(st_transform(сo.φλ,4326)::geography, st_transform(чм.φλ,4326)::geography) < 8.0;

-- Представления для экспорта

CREATE OR REPLACE VIEW "Часы Москвы"."3 Экспорт Моссвет" AS
SELECT чм.*,
       ST_Distance(st_transform(чo.φλ,4326)::geography, st_transform(чм.φλ,4326)::geography) "Δ м"
  FROM "Часы Москвы"."2 Теги на Моссвет" чм
  LEFT JOIN "Часы Москвы"."1 Часы OSM" чo
    ON ST_Distance(st_transform(чo.φλ,4326)::geography, st_transform(чм.φλ,4326)::geography) < 17.0
 WHERE "чo"."φλ" IS null
   AND NOT ("чм"."ref:data.mos.ru" IN ( SELECT o."Код" FROM "Часы Москвы"."2 Часы на опорах" o))
   AND NOT ("чм"."ref:data.mos.ru" IN ( SELECT n."ref:data.mos.ru" FROM "Часы Москвы"."∄" n))
  ;

-- GeoJSON экспорт  
CREATE OR REPLACE VIEW "Часы Москвы"."4 geoJSON экспорт" AS
WITH features  AS (
SELECT json_build_object(
       'type', 'Feature',
       'geometry', st_asgeojson(r."φλ")::json,
       'properties', to_jsonb(r.*) - 'φλ' - 'Δ м') feature
  FROM "Часы Москвы"."3 Экспорт Моссвет"r
)
SELECT json_build_object('type', 'FeatureCollection',
                         'features', json_agg(features.feature)
                        ) "GeoJSON"
  FROM features;
               
CREATE OR REPLACE VIEW "Часы Москвы"."4 osmChamge экспорт" AS 
WITH nodes  AS 
(SELECT  id,        
        round(ST_Y(x.φλ)::numeric,7) "lat",
        round(ST_X(x.φλ)::numeric,7) "lon",
        0 "version",  
        xmlconcat(
        xmlelement(name tag, xmlattributes ( 'amenity' as k, amenity as v)),
        --xmlelement(name tag, xmlattributes ( 'ref:data.mos.ru' as k, "ref:data.mos.ru" as v)),
        xmlelement(name tag, xmlattributes ( 'clock:model' as k, "clock:model" as v)),
        xmlelement(name tag, xmlattributes ( 'operator' as k, "operator" as v)),
        xmlelement(name tag, xmlattributes ( 'owner' as k, "owner" as v)),
        xmlelement(name tag, xmlattributes ( 'contact:phone' as k, "contact:phone" as v)),
        xmlelement(name tag, xmlattributes ( 'rating' as k, "rating" as v)),        
        xmlelement(name tag, xmlattributes ( 'visibility' as k, "visibility" as v)),
        xmlelement(name tag, xmlattributes ( 'display' as k, "display" as v)),
        case when "support" is not null
             then xmlelement(name tag, xmlattributes ( 'support' as k, "support" as v))
         end ,
        xmlelement(name tag, xmlattributes ( 'source' as k, "source" as v)),
        xmlelement(name tag, xmlattributes ( 'website' as k, "website" as v))
        ) "tags"
   FROM "Часы Москвы"."3 Экспорт Моссвет" x
),
elem AS ( 
 SELECT xmlelement(name node, xmlattributes (
        nodes.id,        
        nodes."lon",
        nodes."lat",
        nodes."version"),
        nodes.tags        
        ) "XML"
   FROM nodes
),
node_agg AS (
SELECT xmlagg("XML") "OSM nodes"
  FROM elem
),
osc_create AS (
 SELECT xmlelement(name create, "OSM nodes") osc_create
   FROM node_agg
),
osc_modify AS (
 SELECT xmlelement(name modify, null) osc_modify   
),
osc_delete AS (
 SELECT xmlelement(name delete, xmlattributes ('true' as "if-unused")) osc_delete   
)
SELECT xmlelement(name "osmChange",
                  xmlattributes (0.6 as version, 'PostGIS 3.0 Часы Москвы' as generator),                  
                  osc_create.osc_create,
                  osc_modify.osc_modify,
                  osc_delete.osc_delete
                 ) "osc XML"
  FROM osc_create, osc_modify, osc_delete;

-- Справка по размеру выгрузок
SELECT count(*) FROM "Часы Москвы"."1 Столбы OSM";для
SELECT count(*) FROM "Часы Москвы"."1 Часы OSM" чo;
SELECT count(*) FROM "Часы Москвы"."1 Часы Моссвет" чм;

CREATE MATERIALIZED VIEW "Часы Москвы"."1 Столбы data.mos.ru" AS
WITH data AS (
SELECT json_array_elements("JSON") fe
  FROM "Часы Москвы"."data.mos.ru столбы"
)        
SELECT row_number() OVER () "№",
       st_geomFROMgeojson(fe ->> 'geoData') "φλ",       
       (fe ->> 'PillarNumber') "№ столба",
       (fe ->> 'PillarMark') "Марка столба",
       (fe ->> 'PillarType') "Тип столба",
       (fe ->> 'LightsNumber') "n💡",
       (fe ->> 'Status') "Статус",
       (fe ->> 'OnTerritoryOfMoscow') "В Москве",
       (fe ->> 'Owner') "Балансодержатель",
       (fe ->> 'Year')::int2 "Год",       
       (fe ->> 'global_id')::int4 "Код",
       (fe ->> 'ID')::int4 "Код записи",
       --(fe ->> 'DatasetId')::int4 "Код таблицы",
       --(fe ->> 'VersionNumber')::int4 "Версия табл.",
       (fe ->> 'District') "Район",
       (fe ->> 'AdmArea') "Округ"
FROM data;
--CREATE INDEX "1_Столбы_data_mos_ru_φλ_IDX" ON "Часы Москвы"."1 Столбы data.mos.ru" (φλ);
CREATE INDEX "1_Столбы_data_mos_ru_geo_IDX" ON "Часы Москвы"."1 Столбы data.mos.ru" ((st_transform(φλ,4326)::geography));;
CREATE INDEX "1_Столбы_data_mos_ru_№_IDX" ON "Часы Москвы"."1 Столбы data.mos.ru" (№);
CREATE INDEX "1_Столбы_data_mos_ru_Код_IDX" ON "Часы Москвы"."1 Столбы data.mos.ru" ("Код");

-- Продолжение в скрипте рассчёта по столбам