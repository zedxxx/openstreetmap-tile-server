BEGIN;
UPDATE planet_osm_point SET name = COALESCE(tags->'name:ru', name);
UPDATE planet_osm_line SET name = COALESCE(tags->'name:ru', name);
UPDATE planet_osm_polygon SET name = COALESCE(tags->'name:ru', name);
UPDATE planet_osm_roads SET name = COALESCE(tags->'name:ru', name);
COMMIT;
