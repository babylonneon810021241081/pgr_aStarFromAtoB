CREATE OR REPLACE FUNCTION pgr_aStarFromAtoB_gids(
                IN tbl varchar,
                IN st_gid integer,
                IN end_gid integer,
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
	source := st_gid;
	
	target := end_gid;
	
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
--SELECT geom FROM pgr_aStarFromAtoB_gids('ways', 200, 23)
--SELECT cost FROM pgr_aStarFromAtoB_gids('ways', 55, 343)
--etc etc
