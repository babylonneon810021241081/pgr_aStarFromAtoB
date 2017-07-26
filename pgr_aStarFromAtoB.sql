CREATE OR REPLACE FUNCTION pgr_aStarFromAtoB(
                IN tbl varchar,
                IN st_x double precision,
                IN st_y double precision,
                IN end_x double precision,
                IN end_y double precision,
                OUT seq integer,
                OUT gid integer,
                OUT name text,
                OUT heading double precision,
                OUT cost double precision,
                OUT geom geometry,
                OUT x1 double precision,
		OUT y1 double precision,
		OUT x2 double precision,
		OUT y2 double precision
        )
        RETURNS SETOF record AS
$BODY$
DECLARE
        sql     text;
        rec     record;
        source	integer;
        target	integer;
        --point	integer;
        
BEGIN
	-- Find nearest node
	EXECUTE 'SELECT id::integer FROM ways_vertices_pgr 
			ORDER BY the_geom <-> ST_GeometryFromText(''POINT(' 
			|| st_x || ' ' || st_y || ')'',4326) LIMIT 1' INTO rec;
	source := rec.id;
	
	EXECUTE 'SELECT id::integer FROM ways_vertices_pgr 
			ORDER BY the_geom <-> ST_GeometryFromText(''POINT(' 
			|| end_x || ' ' || end_y || ')'',4326) LIMIT 1' INTO rec;
	target := rec.id;
	
	-- Shortest path query (TODO: limit extent by BBOX) 
        seq := 0;
        
        sql := 'SELECT gid, the_geom, name, cost, source, target, x1, y1, x2, y2, 
				ST_Reverse(the_geom) AS flip_geom FROM ' ||
                        'pgr_astar(''SELECT gid as id, source::integer, target::integer, '
                                        || 'length::double precision AS cost, '
                                        || 'x1::double precision, y1::double precision,'
                                        || 'x2::double precision, y2::double precision,'
                                        || 'reverse_cost::double precision FROM '
                                        || quote_ident(tbl) || ''', '
                                        || source || ', ' || target 
                                        || ' , true, true), '
                                || quote_ident(tbl) || ' WHERE id2 = gid ORDER BY seq';

	-- Remember start point
        --point := source;
	
        FOR rec IN EXECUTE sql
        LOOP
		
		-- Return record
                seq     := seq + 1;
                gid     := rec.gid;
                name    := rec.name;
                cost    := rec.cost;
                geom    := rec.the_geom;
                x1	:= rec.x1;
		y1	:= rec.y1;
		x2	:= rec.x2;
		y2	:= rec.y2;
                RETURN NEXT;
                
        END LOOP;
        RETURN;
	
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE STRICT;

--In order to use this function
--SELECT geom FROM pgr_aStarFromAtoB('ways', 28.231233, 41.324324, 29.432432, 42.423542)
--SELECT cost FROM pgr_aStarFromAtoB('ways', 28.231233, 41.324324, 29.432432, 42.423542)
--etc etc 
--In GeoServer, we make an SQL View like the following
--SELECT geom FROM pgr_aStarFromAtoB('ways', %x1%, %y1%, %x2%, %y2%) ORDER BY seq


---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------


OR


CREATE OR REPLACE FUNCTION pgr_aStarFromAtoB(
                IN tbl varchar,
                IN st_x double precision,
                IN st_y double precision,
                IN end_x double precision,
                IN end_y double precision,
                OUT seq integer,
                OUT gid integer,
                OUT name text,
                OUT heading double precision,
                OUT cost double precision,
                OUT geom geometry,
                OUT x1 double precision,
		OUT y1 double precision,
		OUT x2 double precision,
		OUT y2 double precision
        )
        RETURNS SETOF record AS
$BODY$
DECLARE
        sql     text;
        rec     record;
        source	integer;
        target	integer;
        --point	integer;
        
BEGIN
	-- Find nearest node
	EXECUTE 'SELECT id::integer FROM ways_vertices_pgr 
			ORDER BY the_geom <-> ST_GeometryFromText(''POINT(' 
			|| st_x || ' ' || st_y || ')'',4326) LIMIT 1' INTO rec;
	source := rec.id;
	
	EXECUTE 'SELECT id::integer FROM ways_vertices_pgr 
			ORDER BY the_geom <-> ST_GeometryFromText(''POINT(' 
			|| end_x || ' ' || end_y || ')'',4326) LIMIT 1' INTO rec;
	target := rec.id;
	
	-- Shortest path query (TODO: limit extent by BBOX) 
        seq := 0;
        
        sql := 'SELECT gid, the_geom, name, pgr.cost as cost, source, target, x1, y1, x2, y2, 
				ST_Reverse(the_geom) AS flip_geom FROM ' ||
                        'pgr_astar(''SELECT gid as id, source::integer, target::integer, '
                                        || 'length::double precision AS cost, '
                                        || 'x1::double precision, y1::double precision,'
                                        || 'x2::double precision, y2::double precision,'
                                        || 'reverse_cost::double precision FROM '
                                        || quote_ident(tbl) || ''', '
                                        || source || ', ' || target 
                                        || ' , true, true) as pgr, '
                                || quote_ident(tbl) || ' WHERE id2 = gid ORDER BY seq';

	-- Remember start point
        --point := source;
	
        FOR rec IN EXECUTE sql
        LOOP
		
		-- Return record
                seq     := seq + 1;
                gid     := rec.gid;
                name    := rec.name;
                cost    := rec.cost;
                geom    := rec.the_geom;
                x1	:= rec.x1;
		y1	:= rec.y1;
		x2	:= rec.x2;
		y2	:= rec.y2;
                RETURN NEXT;
                
        END LOOP;
        RETURN;
	
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE STRICT;

--In order to use this function
--SELECT geom FROM pgr_aStarFromAtoB('ways', 28.231233, 41.324324, 29.432432, 42.423542)
--SELECT cost FROM pgr_aStarFromAtoB('ways', 28.231233, 41.324324, 29.432432, 42.423542)
--etc etc 
--In GeoServer, we make an SQL View like the following
--SELECT geom FROM pgr_aStarFromAtoB('ways', %x1%, %y1%, %x2%, %y2%) ORDER BY seq
