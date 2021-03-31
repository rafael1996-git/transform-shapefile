
-- PostgreSQL version: 10.0
-- Model Author: --- José Luis Machado Mendoza

SET check_function_bodies = false;
-- ddl-end --

-- object: "joseluis.machado" | type: ROLE --
-- DROP ROLE IF EXISTS "joseluis.machado";
CREATE ROLE "joseluis.machado" WITH 
	SUPERUSER
	CREATEDB
	CREATEROLE
	INHERIT
	LOGIN
	REPLICATION
	ENCRYPTED PASSWORD '********';
-- ddl-end --

-- object: geoloc | type: ROLE --
-- DROP ROLE IF EXISTS geoloc;
CREATE ROLE geoloc WITH 
	SUPERUSER
	INHERIT
	LOGIN
	ENCRYPTED PASSWORD '********';
-- ddl-end --

-- object: usergeoloc | type: ROLE --
-- DROP ROLE IF EXISTS usergeoloc;
CREATE ROLE usergeoloc WITH 
	INHERIT
	LOGIN
	ENCRYPTED PASSWORD '********';
-- ddl-end --
COMMENT ON ROLE usergeoloc IS E'Usuario de consulta.';
-- ddl-end --


-- Database creation must be done outside a multicommand file.
-- These commands were put in this file only as a convenience.
-- -- object: bged30 | type: DATABASE --
-- -- DROP DATABASE IF EXISTS bged30;
-- CREATE DATABASE bged30
-- 	ENCODING = 'UTF8'
-- 	LC_COLLATE = 'en_US.UTF-8'
-- 	LC_CTYPE = 'en_US.UTF-8'
-- 	TABLESPACE = pg_default
-- 	OWNER = postgres;
-- -- ddl-end --
-- 

-- object: app | type: SCHEMA --
-- DROP SCHEMA IF EXISTS app CASCADE;
CREATE SCHEMA app;
-- ddl-end --
ALTER SCHEMA app OWNER TO postgres;
-- ddl-end --

-- object: bged | type: SCHEMA --
-- DROP SCHEMA IF EXISTS bged CASCADE;
CREATE SCHEMA bged;
-- ddl-end --
ALTER SCHEMA bged OWNER TO postgres;
-- ddl-end --

-- object: validaciones | type: SCHEMA --
-- DROP SCHEMA IF EXISTS validaciones CASCADE;
CREATE SCHEMA validaciones;
-- ddl-end --
ALTER SCHEMA validaciones OWNER TO postgres;
-- ddl-end --

SET search_path TO pg_catalog,public,app,bged,validaciones;
-- ddl-end --

-- -- object: public.geometry | type: TYPE --
-- -- DROP TYPE IF EXISTS public.geometry CASCADE;
-- CREATE TYPE public.geometry;
-- -- ddl-end --
-- 
-- object: dblink | type: EXTENSION --
-- DROP EXTENSION IF EXISTS dblink CASCADE;
CREATE EXTENSION dblink
WITH SCHEMA public
VERSION '1.2';
-- ddl-end --
COMMENT ON EXTENSION dblink IS E'connect to other PostgreSQL databases from within a database';
-- ddl-end --

-- object: postgis | type: EXTENSION --
-- DROP EXTENSION IF EXISTS postgis CASCADE;
CREATE EXTENSION postgis
WITH SCHEMA public
VERSION '2.4.9';
-- ddl-end --
COMMENT ON EXTENSION postgis IS E'PostGIS geometry, geography, and raster spatial types and functions';
-- ddl-end --

-- object: app.genera_cuadrantes | type: FUNCTION --
-- DROP FUNCTION IF EXISTS app.genera_cuadrantes() CASCADE;
CREATE FUNCTION app.genera_cuadrantes ()
	RETURNS integer
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

DECLARE
    Fila RECORD;
    OrigenX DOUBLE PRECISION;
    OrigenY DOUBLE PRECISION;
    CuadranteX INTEGER;
    CuadranteY INTEGER;
    CuadExtXmin DOUBLE PRECISION;
    CuadExtYmin DOUBLE PRECISION;
    CuadExtXmax DOUBLE PRECISION;
    CuadExtYmax DOUBLE PRECISION;
    CuadranteXmin DOUBLE PRECISION;
    CuadranteXmax DOUBLE PRECISION;
    CuadranteYmin DOUBLE PRECISION;
    CuadranteYmax DOUBLE PRECISION;
	CuadranteNegativo INTEGER = 0;
	OrigenSRID INTEGER;

BEGIN
    DELETE FROM app.cuadrante;
    DELETE FROM app.cuadrante_numerico;
    
    SELECT x, y, srid FROM app.origen INTO OrigenX, OrigenY, OrigenSRID;

    OrigenX = OrigenX + 550.6;
    OrigenY = OrigenY - 400.3;
	
	FOR Fila IN SELECT ST_X((ST_DumpPoints(ST_Transform(geom,OrigenSRID))).geom) AS x, ST_Y((ST_DumpPoints(ST_Transform(geom,OrigenSRID))).geom) AS y FROM bged.manzana LOOP

      CuadExtXmin = ((Fila.x - 1835.3) - OrigenX) / 550.6;
      CuadExtYmin = ((Fila.y + 1300.9) - OrigenY) / (-400.3);
      CuadExtXmax = ((Fila.x + 1835.3) - OrigenX) / 550.6;
      CuadExtYmax = ((Fila.y - 1300.9) - OrigenY) / (-400.3);

      CuadranteX = CuadExtXmin;
      LOOP
       IF CuadranteX >= CuadExtXmax THEN EXIT; END IF;
       CuadranteY = CuadExtYmin;
       LOOP
         IF CuadranteY >= CuadExtYmax THEN EXIT; END IF;
           IF CuadranteX < 0 OR CuadranteY < 0 THEN CuadranteNegativo = CuadranteNegativo + 1; END IF;

           CuadranteXmin = OrigenX + (CuadranteX * 550.6);
           CuadranteXmax = OrigenX + (CuadranteX * 550.6) + 734.1;
           CuadranteYmin = OrigenY - (CuadranteY * 400.3);
           CuadranteYmax = OrigenY - (CuadranteY * 400.3) - 500.3;

           IF CuadranteXmin <= Fila.x AND CuadranteXmax >= Fila.x AND CuadranteYmin >= Fila.y AND CuadranteYmax <= Fila.y THEN
            INSERT INTO app.cuadrante_numerico (cuadrante, numxmin, numymin, numxmax, numymax) 
            VALUES (to_char(CuadranteX,'FM9990999') || to_char(CuadranteY,'FM9990999'), CuadranteXmin - 550.60, CuadranteYmin + 460.30, CuadranteXmax + 550.60, CuadranteYmax - 460.30);
           END IF;
         CuadranteY = CuadranteY + 1;
       END LOOP;
       CuadranteX = CuadranteX + 1;
      END LOOP;
    END LOOP;

    FOR Fila IN SELECT id, ST_X((ST_DumpPoints(ST_Transform(geom,OrigenSRID))).geom) AS x, ST_Y((ST_DumpPoints(ST_Transform(geom,OrigenSRID))).geom) AS y FROM bged.localidad LOOP

      CuadExtXmin = ((Fila.x - 1835.3) - OrigenX) / 550.6;
      CuadExtYmin = ((Fila.y + 1300.9) - OrigenY) / (-400.3);
      CuadExtXmax = ((Fila.x + 1835.3) - OrigenX) / 550.6;
      CuadExtYmax = ((Fila.y - 1300.9) - OrigenY) / (-400.3);

      CuadranteX = CuadExtXmin;
      LOOP
       IF CuadranteX >= CuadExtXmax THEN EXIT; END IF;
       CuadranteY = CuadExtYmin;
       LOOP
         IF CuadranteY >= CuadExtYmax THEN EXIT; END IF;
		 IF CuadranteX < 0 OR CuadranteY < 0 THEN CuadranteNegativo = CuadranteNegativo + 1; END IF;

           CuadranteXmin = OrigenX + (CuadranteX * 550.6);
           CuadranteXmax = OrigenX + (CuadranteX * 550.6) + 734.1;
           CuadranteYmin = OrigenY - (CuadranteY * 400.3);
           CuadranteYmax = OrigenY - (CuadranteY * 400.3) - 500.3;

           IF CuadranteXmin <= Fila.x AND CuadranteXmax >= Fila.x AND CuadranteYmin >= Fila.y AND CuadranteYmax <= Fila.y THEN
            INSERT INTO app.cuadrante_numerico (cuadrante, numxmin, numymin, numxmax, numymax) 
            VALUES (to_char(CuadranteX,'FM9990999') || to_char(CuadranteY,'FM9990999'), CuadranteXmin - 550.60, CuadranteYmin + 460.30, CuadranteXmax + 550.60, CuadranteYmax - 460.30);
           END IF;
         CuadranteY = CuadranteY + 1;
       END LOOP;
       CuadranteX = CuadranteX + 1;
      END LOOP;
    END LOOP;
	
    FOR Fila IN SELECT DISTINCT * FROM app.cuadrante_numerico LOOP
    INSERT INTO app.cuadrante (cuadrante, geom) VALUES (Fila.cuadrante,
         ST_GeomFromText('MULTIPOLYGON(((' || Fila.numxmin || ' ' || Fila.numymin ||',' || Fila.numxmin || ' ' || Fila.numymax || ',' || 
	     Fila.numxmax || ' ' || Fila.numymax || ',' || Fila.numxmax || ' ' || Fila.numymin ||',' || Fila.numxmin || ' ' || Fila.numymin ||')))', OrigenSRID));
    END LOOP;

    RETURN CuadranteNegativo;
END;

$$;
-- ddl-end --
ALTER FUNCTION app.genera_cuadrantes() OWNER TO postgres;
-- ddl-end --

-- object: bged.tablasclaveentidaddistinta | type: FUNCTION --
-- DROP FUNCTION IF EXISTS bged.tablasclaveentidaddistinta() CASCADE;
CREATE FUNCTION bged.tablasclaveentidaddistinta ()
	RETURNS TABLE ( tablas text,  entidad integer)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$

DECLARE
	nombre_tabla RECORD;
	tabla VARCHAR;
	resultado VARCHAR;
BEGIN
	
FOR nombre_tabla IN SELECT table_name 
		FROM information_schema.tables 
		WHERE table_schema = 'bged' 
		AND table_name IN ('bodega_deoe','cabecera_municipal','capital','casilla','colonia_a',
						   'colonia_l','colonia_p','colonia_puntual','distrito','distrito_local',
						   'entidad','limite_localidad','localidad','mancha_urbana','manzana','modulo',
						   'municipio','ofmpal_cryt','seccion','vocal_distrital_del_rfe','vocal_ejecutivo_distrital',
						   'vocal_ejecutivo_estatal','vocal_estatal_del_rfe') 
		ORDER BY table_name
	LOOP
		tabla := nombre_tabla.table_name;
		
		RETURN QUERY EXECUTE 'SELECT '''|| tabla ||''' AS tabla, entidad							
								FROM bged.'||tabla||'
								WHERE entidad != 30;';
								
	END LOOP;

END;

$$;
-- ddl-end --
ALTER FUNCTION bged.tablasclaveentidaddistinta() OWNER TO postgres;
-- ddl-end --

-- object: bged.tablasgeomduplicadas | type: FUNCTION --
-- DROP FUNCTION IF EXISTS bged.tablasgeomduplicadas() CASCADE;
CREATE FUNCTION bged.tablasgeomduplicadas ()
	RETURNS TABLE ( tablas text,  geom public.geometry)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$

DECLARE
	nombre_tabla RECORD;
	tabla VARCHAR;
	resultado VARCHAR;
BEGIN
	
FOR nombre_tabla IN SELECT table_name 
		FROM information_schema.tables 
		WHERE table_schema = 'bged' 
		AND table_name NOT LIKE 'cat_%'
		ORDER BY table_name
	LOOP
		tabla := nombre_tabla.table_name;
		
		RETURN QUERY EXECUTE 'SELECT '''|| tabla ||''' AS tabla, geom							
								FROM bged.'||tabla||'
								GROUP BY tabla,geom
								HAVING COUNT(geom)>1
								ORDER BY tabla';

	END LOOP;

END;

$$;
-- ddl-end --
ALTER FUNCTION bged.tablasgeomduplicadas() OWNER TO postgres;
-- ddl-end --

-- object: bged.tablasgeominvalidas | type: FUNCTION --
-- DROP FUNCTION IF EXISTS bged.tablasgeominvalidas() CASCADE;
CREATE FUNCTION bged.tablasgeominvalidas ()
	RETURNS TABLE ( tablas text,  geom public.geometry)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$

DECLARE
	nombre_tabla RECORD;
	tabla VARCHAR;
	resultado VARCHAR;
BEGIN
	
FOR nombre_tabla IN SELECT table_name 
		FROM information_schema.tables 
		WHERE table_schema = 'bged' 
		AND table_name NOT LIKE 'cat_%'
		ORDER BY table_name
	LOOP
		tabla := nombre_tabla.table_name;
		
		RETURN QUERY EXECUTE 'SELECT '''|| tabla ||''' AS tabla, geom							
								FROM bged.'||tabla||'
								WHERE ST_IsValid(geom) is false;';
								
	END LOOP;

END;

$$;
-- ddl-end --
ALTER FUNCTION bged.tablasgeominvalidas() OWNER TO postgres;
-- ddl-end --

-- object: bged.tablasgeommulti | type: FUNCTION --
-- DROP FUNCTION IF EXISTS bged.tablasgeommulti() CASCADE;
CREATE FUNCTION bged.tablasgeommulti ()
	RETURNS TABLE ( tablas text,  geom public.geometry)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$

DECLARE
	nombre_tabla RECORD;
	tabla VARCHAR;
	resultado VARCHAR;
BEGIN
	
FOR nombre_tabla IN SELECT table_name 
		FROM information_schema.tables 
		WHERE table_schema = 'bged' 
		AND table_name NOT LIKE 'cat_%' AND table_name NOT IN('distrito','distrito_local','entidad','limite_localidad','mancha_urbana','municipio','seccion','colonia_a')
		ORDER BY table_name
	LOOP
		tabla := nombre_tabla.table_name;
		
		RETURN QUERY EXECUTE 'SELECT '''|| tabla ||''' AS tabla, geom							
								FROM bged.'||tabla||'
								WHERE ST_NumGeometries(geom)>1
								ORDER BY tabla';

	END LOOP;

END;

$$;
-- ddl-end --
ALTER FUNCTION bged.tablasgeommulti() OWNER TO postgres;
-- ddl-end --

-- object: bged.tiposgeomtablas | type: FUNCTION --
-- DROP FUNCTION IF EXISTS bged.tiposgeomtablas() CASCADE;
CREATE FUNCTION bged.tiposgeomtablas ()
	RETURNS TABLE ( tablas text,  tipo text)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$

DECLARE
	nombre_tabla RECORD;
	tabla VARCHAR;
	resultado VARCHAR;
BEGIN
	
FOR nombre_tabla IN SELECT table_name 
		FROM information_schema.tables 
		WHERE table_schema = 'bged' 
		AND table_name NOT LIKE 'cat_%'
		ORDER BY table_name
	LOOP
		tabla := nombre_tabla.table_name;
		
		RETURN QUERY EXECUTE 'SELECT '''|| tabla ||''' AS tabla, ST_GeometryType(geom) as tipo
								FROM bged.'||tabla||'
								ORDER BY geom limit 1';

	END LOOP;

END;

$$;
-- ddl-end --
ALTER FUNCTION bged.tiposgeomtablas() OWNER TO postgres;
-- ddl-end --

-- object: validaciones.geometria_no_valida | type: FUNCTION --
-- DROP FUNCTION IF EXISTS validaciones.geometria_no_valida() CASCADE;
CREATE FUNCTION validaciones.geometria_no_valida ()
	RETURNS TABLE ( id_entidad integer,  tabla character varying,  id_registro integer,  detalle character varying)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$


DECLARE
contador int;
n_entidad int;
lista_tablas RECORD;
resultado RECORD;

BEGIN
	SELECT entidad from bged.entidad INTO n_entidad;
	FOR lista_tablas IN SELECT DISTINCT (table_name), column_name FROM information_schema.columns 
		WHERE table_schema = 'bged' AND udt_name = 'geometry'
	LOOP
		EXECUTE FORMAT('SELECT COUNT(*) FROM bged.%s WHERE %s IS NULL', lista_tablas.table_name, lista_tablas.column_name) INTO contador;
		
		IF contador > 0 THEN
			FOR resultado IN EXECUTE FORMAT('SELECT id, ST_IsValidReason(geom) as detalle FROM bged.%s WHERE NOT ST_IsValid(%s)', lista_tablas.table_name, lista_tablas.column_name)
			LOOP
				id_entidad = n_entidad;
				tabla = lista_tablas.table_name;
				id_registro = resultado.id;
				detalle = resultado.detalle;
				RETURN NEXT;
			END LOOP;
		ELSE
			CONTINUE;
		END IF;
		RETURN NEXT;
	END LOOP;
END;


$$;
-- ddl-end --
ALTER FUNCTION validaciones.geometria_no_valida() OWNER TO postgres;
-- ddl-end --
COMMENT ON FUNCTION validaciones.geometria_no_valida() IS E'Versión 0.3.0.0';
-- ddl-end --

-- object: validaciones.vca_manzana_contenida_limitelocalidad | type: FUNCTION --
-- DROP FUNCTION IF EXISTS validaciones.vca_manzana_contenida_limitelocalidad() CASCADE;
CREATE FUNCTION validaciones.vca_manzana_contenida_limitelocalidad ()
	RETURNS TABLE ( id_manzana integer,  manzana integer,  entidad integer,  municipio integer,  localidad_esta integer,  localidad_registrada integer)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$


BEGIN
	RETURN QUERY SELECT
	mz.id,
	mz.manzana,
	liloc.entidad,
	liloc.municipio,
	liloc.localidad,
	mz.localidad
	FROM
	bged.limite_localidad AS liloc, bged.manzana AS mz
	WHERE
	liloc.localidad != mz.localidad
	AND liloc.municipio = mz.municipio
	AND ST_Intersects(mz.geom, liloc.geom)
	AND ST_Area(ST_Difference(mz.geom, liloc.geom)) = 0
	ORDER BY liloc.localidad, mz.localidad;	
END;


$$;
-- ddl-end --
ALTER FUNCTION validaciones.vca_manzana_contenida_limitelocalidad() OWNER TO postgres;
-- ddl-end --

-- object: validaciones.vcb_seccion_contenida_municipio | type: FUNCTION --
-- DROP FUNCTION IF EXISTS validaciones.vcb_seccion_contenida_municipio() CASCADE;
CREATE FUNCTION validaciones.vcb_seccion_contenida_municipio ()
	RETURNS TABLE ( id_seccion integer,  seccion integer,  entidad integer,  municipio_esta integer,  municipio_registrado integer)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$


BEGIN
	RETURN QUERY SELECT
	seccion.id,
	seccion.seccion,
	municipio.entidad,
	municipio.municipio,
	seccion.municipio
	FROM
	bged.municipio AS municipio, bged.seccion AS seccion
	WHERE
	seccion.municipio != municipio.municipio
	AND ST_Intersects(seccion.geom, municipio.geom)
	AND ST_Area(ST_Difference(seccion.geom, municipio.geom)) = 0
	ORDER BY seccion.seccion;	
END;


$$;
-- ddl-end --
ALTER FUNCTION validaciones.vcb_seccion_contenida_municipio() OWNER TO postgres;
-- ddl-end --
COMMENT ON FUNCTION validaciones.vcb_seccion_contenida_municipio() IS E'Versión 0.2.0.0';
-- ddl-end --

-- object: validaciones.vcc_colonia_contenida_municipio | type: FUNCTION --
-- DROP FUNCTION IF EXISTS validaciones.vcc_colonia_contenida_municipio() CASCADE;
CREATE FUNCTION validaciones.vcc_colonia_contenida_municipio ()
	RETURNS TABLE ( id_colonia integer,  nombre character varying,  entidad integer,  municipio_esta integer,  municipio_registrado integer)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$


BEGIN
	RETURN QUERY SELECT
	colonia.id,
	colonia.nombre,
	municipio.entidad,
	municipio.municipio,
	colonia.municipio
	FROM
	bged.municipio AS municipio, bged.colonia_a AS colonia
	WHERE
	municipio.municipio != colonia.municipio
	AND ST_Intersects(colonia.geom, municipio.geom)
	AND ST_Area(ST_Difference(colonia.geom, municipio.geom)) = 0
	ORDER BY municipio.municipio, colonia.municipio;	
END;


$$;
-- ddl-end --
ALTER FUNCTION validaciones.vcc_colonia_contenida_municipio() OWNER TO postgres;
-- ddl-end --

-- object: validaciones.vcd_coloniap_contenida_municipiodistinto | type: FUNCTION --
-- DROP FUNCTION IF EXISTS validaciones.vcd_coloniap_contenida_municipiodistinto() CASCADE;
CREATE FUNCTION validaciones.vcd_coloniap_contenida_municipiodistinto ()
	RETURNS TABLE ( id character varying,  nombre character varying,  municipio character varying,  municipio_debe character varying)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$


DECLARE
	err varchar;
	err_msg varchar;

BEGIN

	-- ******************************************************
	-- Validación de Coherencia Geográfica
		-- D: Colonias punto contenidas en limites de municipio distintos
	-- Capa : colonia_p y municipio
	-- Prueba: 1
	-- Texto: Colonias punto contenidas en limites de municipio distintos
	-- BD-esquema: bged17 - bged
	-- Archivo: vcd_coloniap_contenida_municipiodistinto_p1_sinp.sql
	-- Tiempo: 27s167ms - 2s186ms
	-- ******************************************************

	RETURN QUERY SELECT CAST(c.id AS varchar(20)) AS id,
						CAST(c.nombre AS varchar(20)) AS nombre,
						CAST(c.municipio AS varchar(20)) AS municipio,
						CAST(m.municipio AS varchar(20)) AS municipio_debe
				 FROM bged.colonia_p c, bged.municipio m
				 WHERE ST_Within(c.geom, m.geom)
				 AND c.municipio != m.municipio
				 ORDER BY m.municipio, c.municipio;

	EXCEPTION WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS 
			err = RETURNED_SQLSTATE,
			err_msg = MESSAGE_TEXT;
		
		id := 'Error <<colonia_p> <<municipio>>: ' || err_msg;
		nombre := '0';
		municipio := '0';
		municipio_debe := '0';
		RETURN NEXT;

END;


$$;
-- ddl-end --
ALTER FUNCTION validaciones.vcd_coloniap_contenida_municipiodistinto() OWNER TO postgres;
-- ddl-end --
COMMENT ON FUNCTION validaciones.vcd_coloniap_contenida_municipiodistinto() IS E'BEGL Versión 1.1.0.0';
-- ddl-end --

-- object: validaciones.vce_localidad_contenida_seccion | type: FUNCTION --
-- DROP FUNCTION IF EXISTS validaciones.vce_localidad_contenida_seccion() CASCADE;
CREATE FUNCTION validaciones.vce_localidad_contenida_seccion ()
	RETURNS TABLE ( id integer,  entidad integer,  distrito integer,  municipio integer,  seccion integer,  localidad integer,  nombre character varying,  seccion_debe integer)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$


BEGIN
	-- ******************************************************
	-- Coherencia geográfica
	-- E: Localidades contenidas en límites de sección distintos 
	-- Capa : localidad, municipio
	-- Prueba: 1
	-- Texto: Localidades dentro de una sección diferente
	-- ******************************************************

	RETURN QUERY SELECT
		l.id, l.entidad, l.distrito, l.municipio, l.seccion, l.localidad, l.nombre, s.seccion as seccion_debe
		FROM bged.localidad AS l, bged.seccion AS s
		WHERE ST_Within(l.geom, s.geom)
		AND l.seccion != s.seccion
		ORDER BY s.seccion, l.seccion;
END;


$$;
-- ddl-end --
ALTER FUNCTION validaciones.vce_localidad_contenida_seccion() OWNER TO postgres;
-- ddl-end --
COMMENT ON FUNCTION validaciones.vce_localidad_contenida_seccion() IS E'Versión 0.1.0.0';
-- ddl-end --

-- object: validaciones.vce_localidad_contenida_secciondistinta | type: FUNCTION --
-- DROP FUNCTION IF EXISTS validaciones.vce_localidad_contenida_secciondistinta() CASCADE;
CREATE FUNCTION validaciones.vce_localidad_contenida_secciondistinta ()
	RETURNS TABLE ( id character varying,  localidad character varying,  nombre character varying,  seccion character varying,  municipio character varying,  distrito character varying,  seccion_debe character varying)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$


DECLARE
	err varchar;
	err_msg varchar;

BEGIN

	-- ******************************************************
	-- Validación de Coherencia Geográfica
		-- E: Localidades contenidas en limites de seccion distintos
	-- Capa : localidad y seccion
	-- Prueba: 2
	-- Texto: Localidades contenidas en limites de seccion distintos
	-- BD-esquema: bged17 - bged
	-- Archivo: vce_localidad_contenida_secciondistinta_p2_sinp.sql
	-- Tiempo: 43s52ms - 6s196ms
	-- ******************************************************

	RETURN QUERY SELECT CAST(l.id AS varchar(20)) AS id,
						CAST(l.localidad AS varchar(20)) AS localidad,
						CAST(l.nombre AS varchar(20)) AS nombre,
						CAST(l.seccion AS varchar(20)) AS seccion,
						CAST(l.municipio AS varchar(20)) AS municipio,
						CAST(l.distrito AS varchar(20)) AS distrito,
						CAST(s.seccion AS varchar(20)) AS seccion_debe
						-- l.id, l.entidad, l.distrito, l.municipio, l.seccion, l.localidad, l.nombre, s.seccion as seccion_debe
				 FROM bged.localidad AS l, bged.seccion AS s
				 WHERE ST_Within(l.geom, s.geom)
				 AND l.seccion != s.seccion
				 ORDER BY s.seccion, l.seccion;

	EXCEPTION WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS 
			err = RETURNED_SQLSTATE,
			err_msg = MESSAGE_TEXT;
		
		id := 'Error <<localidad> <<seccion>>: ' || err_msg;
		localidad := '0';
		nombre := '0';
		seccion := '0';
		municipio := '0';
		distrito := '0';
		seccion_debe := '0';
		RETURN NEXT;

END;


$$;
-- ddl-end --
ALTER FUNCTION validaciones.vce_localidad_contenida_secciondistinta() OWNER TO postgres;
-- ddl-end --
COMMENT ON FUNCTION validaciones.vce_localidad_contenida_secciondistinta() IS E'BEGL Versión 0.1.0.0';
-- ddl-end --

-- object: validaciones.vcf_limitelocalidad_contenido_municipiodistinto | type: FUNCTION --
-- DROP FUNCTION IF EXISTS validaciones.vcf_limitelocalidad_contenido_municipiodistinto() CASCADE;
CREATE FUNCTION validaciones.vcf_limitelocalidad_contenido_municipiodistinto ()
	RETURNS TABLE ( limitelocalidad_id character varying,  limitelocalidad_municipio_tiene character varying,  municipio_debe character varying)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$


DECLARE
	err varchar;
	err_msg varchar;

BEGIN
	
	-- ******************************************************
	-- Validación de Coherencia Geográfica
		-- AA: Límites de localidad contenidas en límites de municipio distintos 
	-- Capa : limite_localidad y municipio
	-- Prueba: 1
	-- Texto: Límites de localidad contenidas en límites de municipio distintos
	-- BD-esquema: bged17 - bged
	-- Archivo: vcf_limitelocalidad_contenido_municipiodistinto_p1_sinp.sql
	-- Tiempo: 23s42ms - 2s186ms
	-- ******************************************************
	
	RETURN QUERY SELECT CAST(X.z_id AS varchar(20)) AS limitelocalidad_id, 
					    CAST(X.z_mun AS varchar(20)) AS limitelocalidad_municipio_tiene, 
					    CAST(X.m_mun AS varchar(20)) AS municipio_debe
				FROM
					(
						SELECT z.id as z_id, z.municipio as z_mun, m.id as m_id, m.municipio as m_mun
						FROM bged.limite_localidad z, bged.municipio m
						WHERE ST_Intersects(z.geom, m.geom)
						AND m.municipio != z.municipio
					) X 
					LEFT JOIN
					(
						SELECT z.id as z_id, z.municipio as z_mun, m.id as m_id, m.municipio as m_mun
						FROM bged.limite_localidad z, bged.municipio m
						WHERE ST_Intersects(z.geom, m.geom)
						AND m.municipio = z.municipio
					) Y 
					ON X.z_id = Y.z_id
				WHERE Y.z_id  IS NULL
				ORDER BY X.m_mun, X.z_mun;

	EXCEPTION WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS 
			err = RETURNED_SQLSTATE,
			err_msg = MESSAGE_TEXT;
		
		limitelocalidad_id := 'Error <<limite_localidad> <<municipio>>: ' || err_msg;
		limitelocalidad_municipio_tiene := '0';
		municipio_debe := '0';
		RETURN NEXT;

END;


$$;
-- ddl-end --
ALTER FUNCTION validaciones.vcf_limitelocalidad_contenido_municipiodistinto() OWNER TO postgres;
-- ddl-end --
COMMENT ON FUNCTION validaciones.vcf_limitelocalidad_contenido_municipiodistinto() IS E'BEGL Versión 1.1.0.0';
-- ddl-end --

-- object: validaciones.vcg_manzana_sincobertura_colonia | type: FUNCTION --
-- DROP FUNCTION IF EXISTS validaciones.vcg_manzana_sincobertura_colonia() CASCADE;
CREATE FUNCTION validaciones.vcg_manzana_sincobertura_colonia ()
	RETURNS TABLE ( id character varying,  seccion character varying,  municipio character varying,  distrito character varying)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$


DECLARE
	err varchar;
	err_msg varchar;

BEGIN
	
	-- ******************************************************
	-- Validación de Coherencia Geográfica
		-- G: Manzanas sin cobertura de limite de colonia
	-- Capa : manzana y municipio
	-- Prueba: 1
	-- Texto: Manzanas sin cobertura de limite de colonia
	-- BD-esquema: bged17 - bged
	-- Archivo: vcg_manzana_sincobertura_colonia_p1_sinp.sql
	-- Tiempo: 7m47s - 2s711ms
	-- ******************************************************
	
	RETURN QUERY SELECT CAST(m.id AS varchar(20)) As id, 
						CAST(m.seccion AS varchar(20)) As seccion, 
						CAST(m.municipio AS varchar(20)) As municipio, 
						CAST(m.distrito AS varchar(20)) As distrito 
				FROM bged.manzana m
				WHERE m.id NOT IN (
				    SELECT mz.id 
					FROM bged.manzana mz, bged.colonia_a c
				    WHERE ST_Within(mz.geom, c.geom)
				)
				ORDER BY m.seccion, m.id;

	EXCEPTION WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS 
			err = RETURNED_SQLSTATE,
			err_msg = MESSAGE_TEXT;
		
		id := 'Error <<manzana>> <<colonia_a>>: ' || err_msg;
		seccion := '0';
		municipio := '0';
		distrito := '0';
		RETURN NEXT;

END;


$$;
-- ddl-end --
ALTER FUNCTION validaciones.vcg_manzana_sincobertura_colonia() OWNER TO postgres;
-- ddl-end --
COMMENT ON FUNCTION validaciones.vcg_manzana_sincobertura_colonia() IS E'BEGL Versión 1.1.0.0';
-- ddl-end --

-- object: validaciones.vch_manzana_sincobertura_limitelocalidad | type: FUNCTION --
-- DROP FUNCTION IF EXISTS validaciones.vch_manzana_sincobertura_limitelocalidad() CASCADE;
CREATE FUNCTION validaciones.vch_manzana_sincobertura_limitelocalidad ()
	RETURNS TABLE ( id character varying,  seccion character varying,  municipio character varying,  distrito character varying)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$


DECLARE
	err varchar;
	err_msg varchar;

BEGIN
	
	-- ******************************************************
	-- Validación de Coherencia Geográfica
		-- H: Manzanas sin cobertura de limite de localidad
	-- Capa : manzana y limite_localidad
	-- Prueba: 1
	-- Texto: Manzanas sin cobertura de limite de localidad
	-- BD-esquema: bged17 - bged
	-- Archivo: vch_manzana_sincobertura_limitelocalidad_p1_sinp.sql
	-- Tiempo: 7m47s - 11s141ms
	-- ******************************************************
	
	RETURN QUERY SELECT CAST(m.id AS varchar(20)) As id, 
						CAST(m.seccion AS varchar(20)) As seccion, 
						CAST(m.municipio AS varchar(20)) As municipio, 
						CAST(m.distrito AS varchar(20)) As distrito 
				FROM bged.manzana m
				WHERE m.id NOT IN (
				    SELECT mz.id 
					FROM bged.manzana mz, bged.limite_localidad l
				    WHERE ST_Within(mz.geom, l.geom)
				)
				ORDER BY m.id;

	EXCEPTION WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS 
			err = RETURNED_SQLSTATE,
			err_msg = MESSAGE_TEXT;
		
		id := 'Error <<manzana>> <<limite_localidad>>: ' || err_msg;
		seccion := '0';
		municipio := '0';
		distrito := '0';
		RETURN NEXT;

END;


$$;
-- ddl-end --
ALTER FUNCTION validaciones.vch_manzana_sincobertura_limitelocalidad() OWNER TO postgres;
-- ddl-end --
COMMENT ON FUNCTION validaciones.vch_manzana_sincobertura_limitelocalidad() IS E'BEGL Versión 1.1.0.0';
-- ddl-end --

-- object: validaciones.vci_manzana_sincobertura_seccion | type: FUNCTION --
-- DROP FUNCTION IF EXISTS validaciones.vci_manzana_sincobertura_seccion() CASCADE;
CREATE FUNCTION validaciones.vci_manzana_sincobertura_seccion ()
	RETURNS TABLE ( id character varying,  seccion character varying,  municipio character varying,  distrito character varying)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$


DECLARE
	err varchar;
	err_msg varchar;

BEGIN
	
	-- ******************************************************
	-- Validación de Coherencia Geográfica
		-- I: Manzanas sin cobertura de limite de seccion
	-- Capa : manzana y limite_localidad
	-- Prueba: 1
	-- Texto: Manzanas sin cobertura de limite de seccion
	-- BD-esquema: bged17 - bged
	-- Archivo: vci_manzana_sincobertura_seccion_p1_sinp.sql
	-- Tiempo: 7m47s - 5s867ms
	-- ******************************************************
	
	RETURN QUERY SELECT CAST(m.id AS varchar(20)) As id, 
						CAST(m.seccion AS varchar(20)) As seccion, 
						CAST(m.municipio AS varchar(20)) As municipio, 
						CAST(m.distrito AS varchar(20)) As distrito -- 127 registros
				FROM bged.manzana m
				WHERE m.id NOT IN (
				    SELECT mz.id 
					FROM bged.manzana mz, bged.seccion s
				    WHERE ST_Within(mz.geom, s.geom)
				)
				ORDER BY m.id;

	EXCEPTION WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS 
			err = RETURNED_SQLSTATE,
			err_msg = MESSAGE_TEXT;
		
		id := 'Error <<manzana>> <<seccion>>: ' || err_msg;
		seccion := '0';
		municipio := '0';
		distrito := '0';
		RETURN NEXT;

END;


$$;
-- ddl-end --
ALTER FUNCTION validaciones.vci_manzana_sincobertura_seccion() OWNER TO postgres;
-- ddl-end --
COMMENT ON FUNCTION validaciones.vci_manzana_sincobertura_seccion() IS E'BEGL Versión 1.1.0.0';
-- ddl-end --

-- object: validaciones.vcj_manzanacontenida_secciondistinta | type: FUNCTION --
-- DROP FUNCTION IF EXISTS validaciones.vcj_manzanacontenida_secciondistinta() CASCADE;
CREATE FUNCTION validaciones.vcj_manzanacontenida_secciondistinta ()
	RETURNS TABLE ( manzana_id character varying,  manzana_seccion_tiene character varying,  seccion_debe character varying)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$


DECLARE
	err varchar;
	err_msg varchar;

BEGIN
	
	-- ******************************************************
	-- Validación de Coherencia Geográfica
		-- J: Manzanas envueltas en un polígono de sección distinta
	-- Capa : manzana y seccion
	-- Prueba: 1
	-- Texto: Manzanas envueltas en un polígono de sección distinta
	-- BD-esquema: bged17 - bged
	-- Archivo: vcj_manzanacontenida_secciondistinta_p1_sinp.sql
	-- Tiempo: 23s42ms - 2s186ms
	-- ******************************************************
	
	RETURN QUERY SELECT CAST(X.a_id AS varchar(20)) AS manzana_id, 
					    CAST(X.a_sec AS varchar(20)) AS manzana_seccion_tiene, 
					    CAST(X.b_sec AS varchar(20)) AS seccion_debe
				FROM
					(
						SELECT a.id as a_id, a.seccion as a_sec, b.id as b_id, b.seccion as b_sec
						FROM bged.manzana a, bged.seccion b
						WHERE ST_Intersects(a.geom, b.geom)
						AND a.seccion != b.seccion
					) X 
					LEFT JOIN
					(
						SELECT a.id as a_id, a.seccion as a_sec, b.id as b_id, b.seccion as b_sec
						FROM bged.manzana a, bged.seccion b
						WHERE ST_Intersects(a.geom, b.geom)
						AND a.seccion = b.seccion
					) Y 
					ON X.a_id = Y.a_id
				WHERE Y.a_id  IS NULL
				ORDER BY X.b_sec, X.a_sec;

	EXCEPTION WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS 
			err = RETURNED_SQLSTATE,
			err_msg = MESSAGE_TEXT;
		
		manzana_id := 'Error <<manzana> <<seccion>>: ' || err_msg;
		manzana_seccion_tiene := '0';
		seccion_debe := '0';
		RETURN NEXT;

END;


$$;
-- ddl-end --
ALTER FUNCTION validaciones.vcj_manzanacontenida_secciondistinta() OWNER TO postgres;
-- ddl-end --
COMMENT ON FUNCTION validaciones.vcj_manzanacontenida_secciondistinta() IS E'BEGL Versión 1.1.0.0';
-- ddl-end --

-- object: validaciones.vcl_campo_control_duplicado | type: FUNCTION --
-- DROP FUNCTION IF EXISTS validaciones.vcl_campo_control_duplicado() CASCADE;
CREATE FUNCTION validaciones.vcl_campo_control_duplicado ()
	RETURNS TABLE ( tabla character varying,  control character varying,  repeticiones integer)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$


DECLARE
	r_tabla RECORD;
	r_control RECORD;
	nombre_tabla VARCHAR;
	err VARCHAR;
	err_msg VARCHAR;

BEGIN

	-- ******************************************************
	-- Coherencia geográfica
	-- E: Valores de campo control duplicado
	-- Capa: todas = 71 tablas
	-- Prueba: 2
	-- Texto: Campo control duplicado
	-- BD - Esquema: bged17 - bged
	-- Archivo: vcl_campo_control_duplicado - p2 - sinp.sql
	-- ******************************************************
	
	FOR r_tabla IN SELECT table_name 
		FROM information_schema.tables 
		WHERE table_schema = 'bged' 
		AND table_name NOT LIKE 'cat_%'
		ORDER BY table_name
	LOOP
		nombre_tabla := r_tabla.table_name;
		
		IF EXISTS ( SELECT * 
				    FROM information_schema.columns 
				    WHERE table_schema LIKE 'bged' 
				    AND table_name LIKE nombre_tabla 
				    AND column_name LIKE 'control' ) THEN
		
			FOR r_control IN EXECUTE 'SELECT CAST(D.control AS varchar(20)) as control, D.repeticiones FROM
				(
				SELECT DISTINCT(t.control) AS control, COUNT(t.control) AS repeticiones 
				FROM bged.' || nombre_tabla ||' AS t
				GROUP BY t.control
				HAVING COUNT(t.control) > 1
				ORDER BY t.control
				) D'
			LOOP
				tabla := nombre_tabla;
				control := r_control.control;
				repeticiones:= r_control.repeticiones;
				RETURN NEXT;
				
			END LOOP;
		
		ELSE
			tabla := 'La tabla <<' || nombre_tabla || '>> no contiene el campo <<control>>';
			control := '0';
			repeticiones:= 0;
			RETURN NEXT;
			
		END IF;	

	END LOOP;
	
	EXCEPTION WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS 
			err = RETURNED_SQLSTATE,
			err_msg = MESSAGE_TEXT;

		tabla := 'Error en la tabla <<' || nombre_tabla || '>>: ' || err_msg;
		control := '0';
		repeticiones:= 0;
		RETURN NEXT;

END;


$$;
-- ddl-end --
ALTER FUNCTION validaciones.vcl_campo_control_duplicado() OWNER TO postgres;
-- ddl-end --
COMMENT ON FUNCTION validaciones.vcl_campo_control_duplicado() IS E'Versión 0.1.0.0';
-- ddl-end --

-- object: validaciones.vcza_manzana_contenida_municipiodistinto | type: FUNCTION --
-- DROP FUNCTION IF EXISTS validaciones.vcza_manzana_contenida_municipiodistinto() CASCADE;
CREATE FUNCTION validaciones.vcza_manzana_contenida_municipiodistinto ()
	RETURNS TABLE ( manzana_id character varying,  manzana_municipio_tiene character varying,  municipio_debe character varying)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$


DECLARE
	err varchar;
	err_msg varchar;

BEGIN
	
	-- ******************************************************
	-- Validación de Coherencia Geográfica
		-- AA: Manzanas con clave de municipio distinto al municipio que los contiene 
	-- Capa : manzana y municipio
	-- Prueba: 1
	-- Texto: Manzanas con clave de municipio distinto al municipio que los contiene
	-- BD-esquema: bged17 - bged
	-- Archivo: vcza_manzana_contenida_municipiodistinto_p1_sinp.sql
	-- Tiempo: 23s42ms - 2s186ms
	-- ******************************************************
	
	RETURN QUERY SELECT CAST(X.z_id AS varchar(20)) AS manzana_id, 
					    CAST(X.z_mun AS varchar(20)) AS manzana_municipio_tiene, 
					    CAST(X.m_mun AS varchar(20)) AS municipio_debe
				FROM
					(
						SELECT z.id as z_id, z.municipio as z_mun, m.id as m_id, m.municipio as m_mun
						FROM bged.manzana z, bged.municipio m
						WHERE ST_Intersects(z.geom, m.geom)
						AND m.municipio != z.municipio
					) X 
					LEFT JOIN
					(
						SELECT z.id as z_id, z.municipio as z_mun, m.id as m_id, m.municipio as m_mun
						FROM bged.manzana z, bged.municipio m
						WHERE ST_Intersects(z.geom, m.geom)
						AND m.municipio = z.municipio
					) Y 
					ON X.z_id = Y.z_id
				WHERE Y.z_id  IS NULL
				ORDER BY X.m_mun, X.z_mun;

	EXCEPTION WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS 
			err = RETURNED_SQLSTATE,
			err_msg = MESSAGE_TEXT;
		
		manzana_id := 'Error <<manzana>> <<municipio>>: ' || err_msg;
		manzana_municipio_tiene := '0';
		municipio_debe := '0';
		RETURN NEXT;

END;


$$;
-- ddl-end --
ALTER FUNCTION validaciones.vcza_manzana_contenida_municipiodistinto() OWNER TO postgres;
-- ddl-end --
COMMENT ON FUNCTION validaciones.vcza_manzana_contenida_municipiodistinto() IS E'BEGL Versión 1.1.0.0';
-- ddl-end --

-- object: validaciones.vga_geometria_nula | type: FUNCTION --
-- DROP FUNCTION IF EXISTS validaciones.vga_geometria_nula() CASCADE;
CREATE FUNCTION validaciones.vga_geometria_nula ()
	RETURNS TABLE ( id_entidad integer,  tabla character varying,  id_registro integer)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$

DECLARE
contador int;
n_entidad int;
lista_tablas RECORD;
resultado RECORD;

BEGIN
	SELECT entidad from bged.entidad INTO n_entidad;
	FOR lista_tablas IN SELECT DISTINCT (table_name), column_name FROM information_schema.columns 
		WHERE table_schema = 'bged' AND udt_name = 'geometry'
	LOOP
		EXECUTE FORMAT('SELECT COUNT(*) FROM bged.%s WHERE %s IS NULL', lista_tablas.table_name, lista_tablas.column_name) INTO contador;
		
		IF contador > 0 THEN
			FOR resultado IN EXECUTE 'SELECT DISTINCT(id) FROM bged.' || lista_tablas.table_name || ' WHERE ' || lista_tablas.column_name || ' IS NULL'
			LOOP
				id_entidad = n_entidad;
				tabla = lista_tablas.table_name;
				id_registro = resultado.id;
				RETURN NEXT;
			END LOOP;
		ELSE
			CONTINUE;
		END IF;
		RETURN NEXT;
	END LOOP;
END;

$$;
-- ddl-end --
ALTER FUNCTION validaciones.vga_geometria_nula() OWNER TO postgres;
-- ddl-end --
COMMENT ON FUNCTION validaciones.vga_geometria_nula() IS E'Versión 0.3.0.0';
-- ddl-end --

-- object: validaciones.vgcd_verticerepetido_verticelazo | type: FUNCTION --
-- DROP FUNCTION IF EXISTS validaciones.vgcd_verticerepetido_verticelazo() CASCADE;
CREATE FUNCTION validaciones.vgcd_verticerepetido_verticelazo ()
	RETURNS TABLE ( tabla character varying,  id character varying,  prioridad character varying)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$


DECLARE
	r_tabla record;
	r_registro record;
	tabla_ varchar;
	tipo_geom varchar;
	err varchar;
	err_msg varchar;

BEGIN
	
	-- ******************************************************
	-- Validación geométrica
		-- C: La geometría tiene vértices repetidos
		-- D: La geometría tiene vertices lazo
	-- Capa : Todas - tipo punto, línea y polígono
	-- Prueba: 2
	-- Texto: Geometrias con vertices repetidos y vértices lazo
	-- BD-esquema: bged17 - bged
	-- Archivo: vgcd_verticerepetido_verticelazo_p2_sinp.sql
	-- Tiempo: 20s358ms
	-- ******************************************************

	FOR r_tabla IN SELECT table_name 
		FROM information_schema.tables 
		WHERE table_schema = 'bged' 
		AND table_name NOT LIKE 'cat_%'
		ORDER BY table_name
	LOOP
		tabla_ := r_tabla.table_name;
		EXECUTE FORMAT('SELECT ST_GeometryType(geom) FROM bged.%s LIMIT 1', tabla_) INTO tipo_geom;

		IF (tipo_geom = 'ST_MultiPolygon' or tipo_geom = 'ST_Polygon') THEN
		
			FOR r_registro IN EXECUTE 'SELECT CAST(t.id AS varchar(20)) as id
				FROM bged.' || tabla_ || ' AS t
				WHERE NOT ST_Isvalid(t.geom)'

			LOOP
				tabla := tabla_;
				id := r_registro.id;
				prioridad := '1';

				RETURN NEXT;

			END LOOP;

		ELSE 

			FOR r_registro IN EXECUTE 'SELECT CAST(t.id AS varchar(20)) as id
				FROM bged.' || tabla_ || ' AS t
				WHERE ST_IsSimple(geom) = false'

			LOOP
				tabla := tabla_;
				id := r_registro.id;
				prioridad := '2';

				RETURN NEXT;

			END LOOP; 

		END IF;

	END LOOP;

	EXCEPTION WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS 
			err = RETURNED_SQLSTATE,
			err_msg = MESSAGE_TEXT;
		
		tabla := 'Error <<tabla_>>: ' || err_msg;
		id := '0';
		prioridad := '0';
		RETURN NEXT;

END;


$$;
-- ddl-end --
ALTER FUNCTION validaciones.vgcd_verticerepetido_verticelazo() OWNER TO postgres;
-- ddl-end --
COMMENT ON FUNCTION validaciones.vgcd_verticerepetido_verticelazo() IS E'BEGL Versión 1.2.0.0';
-- ddl-end --

-- object: validaciones.vgf_geometria_duplicada | type: FUNCTION --
-- DROP FUNCTION IF EXISTS validaciones.vgf_geometria_duplicada() CASCADE;
CREATE FUNCTION validaciones.vgf_geometria_duplicada ()
	RETURNS TABLE ( tabla character varying,  ids_geometrias_duplicadas character varying)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$


DECLARE
	err VARCHAR;
	err_msg VARCHAR;
	r_registro RECORD;
	r_tabla RECORD;
	nombre_tabla VARCHAR;
	 
BEGIN
	-- ******************************************************
	-- Validación Geométrica
	-- F: Geometría duplicada
	-- Capa : Todas - 71 capas
	-- Prueba: 3
	-- Texto:  Geometría duplicada
	-- BD - Esquema: bged17 - bged
	-- Archivo: vgf_geometria_duplicada - p3 - sinp.sql 
	-- ******************************************************
	
	FOR r_tabla IN SELECT table_name 
		FROM information_schema.tables 
		WHERE table_schema LIKE 'bged' 
		AND table_name NOT LIKE 'cat_%'
		ORDER BY table_name
	LOOP
		nombre_tabla := r_tabla.table_name;
	
		IF EXISTS (SELECT * 
				   FROM information_schema.columns 
				   WHERE table_schema LIKE 'bged' 
				   AND table_name LIKE nombre_tabla 
				   AND column_name LIKE 'geom') THEN

			FOR r_registro IN EXECUTE 
				'SELECT G.geometria, array_agg(G.id) AS ids_geometrias_duplicadas
				FROM 
				(
					SELECT CAST(t.id AS varchar(20)) AS id, SUBSTRING(ST_AsText(t.geom),1,100) AS geometria 
					FROM bged.' || nombre_tabla || ' AS t
					WHERE geom IN 
						(
							SELECT g.geom 
							FROM bged.' || nombre_tabla || ' AS g
							GROUP BY g.geom
							HAVING COUNT(*)>1
						)
					ORDER BY t.geom, t.id
				) AS G
				GROUP BY geometria'    

			LOOP
				tabla := nombre_tabla;
				ids_geometrias_duplicadas := r_registro.ids_geometrias_duplicadas;
				-- geometria := r_registro.geometria;
				RETURN NEXT;
			END LOOP;
		ELSE
			tabla := 'La tabla <<' || nombre_tabla || '>> no contiene el campo <<geom>>';
			ids_geometrias_duplicadas := r_registro.ids_geometrias_duplicadas;
			-- geometria := r_registro.geometria;
			RETURN NEXT;
		END IF;
	END LOOP;
	
	EXCEPTION WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS 
			err = RETURNED_SQLSTATE,
			err_msg = MESSAGE_TEXT;
		
		tabla := 'Error en la tabla <<' || nombre_tabla || '>>: ' || err_msg;
		ids_geometrias_duplicadas := r_registro.ids_geometrias_duplicadas;
		-- geometria := r_registro.geometria;
		RETURN NEXT;

END;


$$;
-- ddl-end --
ALTER FUNCTION validaciones.vgf_geometria_duplicada() OWNER TO postgres;
-- ddl-end --
COMMENT ON FUNCTION validaciones.vgf_geometria_duplicada() IS E'Versión 0.1.0.0';
-- ddl-end --

-- object: validaciones.vtac_espacios_en_entre_poligonos | type: FUNCTION --
-- DROP FUNCTION IF EXISTS validaciones.vtac_espacios_en_entre_poligonos() CASCADE;
CREATE FUNCTION validaciones.vtac_espacios_en_entre_poligonos ()
	RETURNS TABLE ( tabla character varying,  id character varying,  espacio character varying,  espacio_coords character varying)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$


DECLARE
	err varchar;
	err_msg varchar;
	r_registro RECORD;
	tabla_a integer;
	campo_a integer;
	m varchar[];
	arr varchar[] := array[
	   						['colonia_a'],
	   						['distrito'],
	   						['distrito_local'],
	   						['limite_localidad'],
							['municipio'],
							['seccion']
   						  ];
	
	 
BEGIN

	-- ******************************************************
	-- Validación Topológica
		-- A: Los vértices de dos polígonos no coinciden completamente en los bordes
		-- C: Espacios vacíos dentro de polígono simple o entre polígonos adyacentes
	-- Capa : colonia, distrito, distrito_local, limite_localidad, municipio, seccion
	-- Prueba: 1
	-- Texto: espacios en/entre polígonos
	-- BD - Esquema: bged17 - bged
	-- Archivo: vtac_espacios_en_entre_poligonos_p1_sinp.sql
	-- Tiempo: 3 secs 930 msec. 21 rows affected en seccion
	-- ******************************************************
	
	FOREACH m SLICE 1 IN ARRAY arr
	LOOP
	
		tabla_a := 0;
		campo_a := 0;
		
		IF EXISTS ( SELECT * FROM information_schema.tables 
				    WHERE table_schema = 'bged' AND table_name = m[1] ) THEN
			tabla_a := 1;
		END IF;

		IF EXISTS ( SELECT * FROM information_schema.columns 
				    WHERE table_schema = 'bged' AND table_name = m[1] AND column_name = 'geom' ) THEN
			campo_a := 1;
		END IF;
		
		
		IF ( tabla_a <> 1 ) THEN
			tabla :=  'Error: La tabla <<' || m[1] || '>> no existe';
			id := '0';
			espacio := '0';
			espacio_coords := '0';
			RETURN NEXT;
		
		ELSE
		
			IF ( campo_a = 1 ) THEN
				FOR r_registro IN EXECUTE 
					'SELECT CAST(e.id AS varchar(20)) AS id, CAST(e.espacio AS varchar(20)) AS espacio, CAST(e.espacio_coords AS varchar(250)) AS espacio_coords
					FROM
					(
						WITH h AS
						(
							SELECT i as id, ST_BuildArea(ST_InteriorRingN(c.geom,i)) as geom
							FROM 
							(
								SELECT ST_UNION(geom)geom 
								FROM bged.' || m[1] ||'
							) c
							CROSS JOIN generate_series(1,(SELECT ST_NumInteriorRings(geom) FROMc)) as i 
						)
						SELECT t.id, h.id as espacio, ST_AsText(h.geom) as espacio_coords
						FROM bged.' || m[1] ||' t, h
						WHERE ST_Touches(t.geom, ST_Buffer(h.geom, .1)) 
						UNION
						SELECT t.id, h.id as espacio, ST_AsText(h.geom) as espacio_coords
						FROM bged.' || m[1] ||' t, h
						WHERE ST_Intersects(t.geom, ST_Buffer(h.geom, .1)) 
						ORDER BY espacio, id	
					) e'

				LOOP
					tabla := m[1];
					id := r_registro.id;
					espacio := r_registro.espacio;
					espacio_coords := r_registro.espacio_coords;
					RETURN NEXT;
				END LOOP;
			ELSE
				tabla := 'Error: La tabla <<' || m[1] || '>>  no contiene el campo geom';
				id := '0';
				espacio := '0';
				espacio_coords := '0';
				RETURN NEXT;
			END IF;
		END IF; 
			
	END LOOP;
	
	EXCEPTION WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS 
			err = RETURNED_SQLSTATE,
			err_msg = MESSAGE_TEXT;
		
		tabla := 'Error <<' || m[1] || '>>: ' || err_msg;
		id := '0';
		espacio := '0';
		espacio_coords := '0';
		RETURN NEXT;

END;


$$;
-- ddl-end --
ALTER FUNCTION validaciones.vtac_espacios_en_entre_poligonos() OWNER TO postgres;
-- ddl-end --
COMMENT ON FUNCTION validaciones.vtac_espacios_en_entre_poligonos() IS E'BEGL Versión 1.1.0.0';
-- ddl-end --

-- object: validaciones.vtb_sobreposicion | type: FUNCTION --
-- DROP FUNCTION IF EXISTS validaciones.vtb_sobreposicion() CASCADE;
CREATE FUNCTION validaciones.vtb_sobreposicion ()
	RETURNS TABLE ( tabla1 character varying,  tabla2 character varying,  id1 character varying,  id2 character varying)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$


DECLARE
	err varchar;
	err_msg varchar;
	r_registro record;
	tabla_a integer;
	tabla_b integer;
	campo_a integer;
	campo_b integer;
	m varchar[];
	arr varchar[] := array[
	   						['manzana','manzana','id'],
	   						['seccion','manzana','seccion'],
	   						['colonia_a','colonia_a','id'],
	   						['municipio','colonia_a','municipio'],
							['entidad','colonia_a','entidad'],
							['limite_localidad','limite_localidad','id'],
							['municipio','limite_localidad','municipio'],
							['seccion','seccion','id'],
							['municipio','seccion','municipio'],
	   						['distrito','seccion','distrito'],
							-- ['distrito_local','seccion','distrito_local'],
							['entidad','seccion','entidad'],
							['municipio','municipio','id'],
							-- ['distrito','municipio','distrito'],
							-- ['distrito_local','municipio','distrito_local'],
							['entidad','municipio','entidad'],
							['distrito','distrito','id'],
							['entidad','distrito','entidad'],
							['distrito_local','distrito_local','id'],
							['entidad','distrito_local','entidad']
   						  ];
	
	 
BEGIN

	-- ******************************************************
	-- Validación Topológica
		-- B: Sobreposición de polígonos
	-- Capa : Algunas
	-- Prueba: 4
	-- Texto: Sobreposición de polígonos
	-- BD - Esquema: bged17 - bged
	-- Archivo: vtb_sobreposicion_p4_sinp.sql
	-- Tiempo: 3 min 3 seg
	-- ******************************************************
	
	FOREACH m SLICE 1 IN ARRAY arr
	LOOP
	
		tabla_a := 0;
		tabla_b := 0;
		campo_a := 0;
		campo_b := 0;
		
		IF EXISTS ( SELECT * FROM information_schema.tables 
				    WHERE table_schema = 'bged' AND table_name = m[1] ) THEN
			tabla_a := 1;
		END IF;
		IF EXISTS ( SELECT * FROM information_schema.tables 
				    WHERE table_schema = 'bged' AND table_name = m[2] ) THEN
			tabla_b := 1;
		END IF;	
		IF EXISTS ( SELECT * FROM information_schema.columns 
				    WHERE table_schema = 'bged' AND table_name = m[1] AND column_name = m[3] ) THEN
			campo_a := 1;
		END IF;
		IF EXISTS ( SELECT * FROM information_schema.columns 
				    WHERE table_schema = 'bged' AND table_name = m[2] AND column_name = m[3] ) THEN
			campo_b := 1;
		END IF;
		
		
		IF (tabla_a <> 1 OR tabla_b <> 1) THEN
			tabla1 := 'Error: Alguna de las tablas <<' || m[1] || '>> o <<' || m[2] || '>> no existe';
			tabla2 := '0';
			id1 := '0';
			id2 := '0';
			RETURN NEXT;
		
		ELSE
		
			IF (campo_a = 1 AND campo_b = 1) THEN
				FOR r_registro IN EXECUTE 
					'SELECT CAST(d.id1 AS varchar(20)) AS id1, CAST(d.id2 AS varchar(20)) AS id2
					FROM 
						(
						SELECT DISTINCT GREATEST(a.id, b.id) AS id1, LEAST(a.id, b.id) AS id2
						FROM bged.' || m[1] ||' a
						INNER JOIN bged.' || m[2] ||' b ON 
						   (a.geom && b.geom AND ST_Relate(a.geom, b.geom, ''2********''))
						WHERE a.' || m[3] ||' != b.' || m[3] || '
						ORDER BY GREATEST(a.id, b.id), LEAST(a.id, b.id)
						) d'

				LOOP
					tabla1 := m[1];
					tabla2 := m[2];
					id1 = r_registro.id1;
					id2 = r_registro.id2;
					RETURN NEXT;
				END LOOP;
			ELSE
				tabla1 := 'Error: Alguna de las tablas <<' || m[1] || '>> o <<' || m[2] || '>> no contiene el campo ' || m[3];
				tabla2 := '0';
				id1 := '0';
				id2 := '0';
				RETURN NEXT;
			END IF;
		END IF; 
			
	END LOOP;
	
	EXCEPTION WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS 
			err = RETURNED_SQLSTATE,
			err_msg = MESSAGE_TEXT;
		
		tabla1 := 'Error <<' || m[1] || '>> <<' || m[2] || '>>: ' || err_msg;
		tabla2 := '0';
		id1 := '0';
		id2 := '0';
		RETURN NEXT;

END;


$$;
-- ddl-end --
ALTER FUNCTION validaciones.vtb_sobreposicion() OWNER TO postgres;
-- ddl-end --
COMMENT ON FUNCTION validaciones.vtb_sobreposicion() IS E'BEGL Versión 1.4.0.0';
-- ddl-end --

-- object: validaciones.vtd_capaa_nocontenidacompletamente_capab | type: FUNCTION --
-- DROP FUNCTION IF EXISTS validaciones.vtd_capaa_nocontenidacompletamente_capab() CASCADE;
CREATE FUNCTION validaciones.vtd_capaa_nocontenidacompletamente_capab ()
	RETURNS TABLE ( tabla1 character varying,  id_nocontenido_completamente character varying,  tabla2 character varying)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$


DECLARE
	err varchar;
	err_msg varchar;
	r_registro RECORD;
	tabla_a integer;
	tabla_b integer;
	campo_a integer;
	campo_b integer;
	m varchar[];
	arr varchar[] := array[
	   						['seccion','distrito'],
	   						['seccion','distrito_local'],
	   						['seccion','municipio'],
	   						['seccion','entidad'],
							-- ['manzana','seccion'],
							-- ['manzana','colonia_a'],
							['distrito','entidad'],
							['distrito_local','entidad'],
							['municipio','entidad']
   						  ];
	
	 
BEGIN

	-- ******************************************************
	-- Validación Topológica
		-- D: Existen límites de polígonos de la primera capa que no estan completamente contenidos por la segunda capa
	-- Capa : Algunas
	-- Prueba: 2
	-- Texto: Polígonos de primera capa no contenidos completamente dentro de segunda capa
	-- BD - Esquema: bged17 - bged
	-- Archivo: vtd_capaa_nocontenidacompletamente_capab_p1_sinp.sql
	-- Tiempo: 2 secs 966 msec. 249 rows affected.
	-- ******************************************************
	
	FOREACH m SLICE 1 IN ARRAY arr
	LOOP
	
		tabla_a := 0;
		tabla_b := 0;
		campo_a := 0;
		campo_b := 0;
		
		IF EXISTS ( SELECT * FROM information_schema.tables 
				    WHERE table_schema = 'bged' AND table_name = m[1] ) THEN
			tabla_a := 1;
		END IF;
		IF EXISTS ( SELECT * FROM information_schema.tables 
				    WHERE table_schema = 'bged' AND table_name = m[2] ) THEN
			tabla_b := 1;
		END IF;	
		IF EXISTS ( SELECT * FROM information_schema.columns 
				    WHERE table_schema = 'bged' AND table_name = m[1] AND column_name = 'geom' ) THEN
			campo_a := 1;
		END IF;
		IF EXISTS ( SELECT * FROM information_schema.columns 
				    WHERE table_schema = 'bged' AND table_name = m[2] AND column_name = 'geom' ) THEN
			campo_b := 1;
		END IF;
		
		
		IF (tabla_a <> 1 OR tabla_b <> 1) THEN
			tabla1 := 'Error: Alguna de las tablas <<' || m[1] || '>> o <<' || m[2] || '>> no existe';
			id_nocontenido_completamente := '0';
			tabla2 := '0';
			RETURN NEXT;
		
		ELSE
		
			IF (campo_a = 1 AND campo_b = 1) THEN
				FOR r_registro IN EXECUTE 
					'WITH tablein AS
					(
					SELECT a.id 
					FROM bged.' || m[1] ||' a, bged.' || m[2] ||' b
					WHERE ST_Within(a.geom, b.geom)
					)
					SELECT CAST(t.id AS varchar(20)) AS id_nocontenido_completamente
					FROM bged.' || m[1] ||' t 
						LEFT JOIN tablein ON t.id = tablein.id 
					WHERE tablein.id IS NULL
					ORDER By t.id'

				LOOP
					tabla1 := m[1];
					id_nocontenido_completamente := r_registro.id_nocontenido_completamente;
					tabla2 := m[2];
					RETURN NEXT;
				END LOOP;
			ELSE
				tabla1 := 'Error: Alguna de las tablas <<' || m[1] || '>> o <<' || m[2] || '>> no contiene el campo geom';
				id_nocontenido_completamente := '0';
				tabla2 := '0';
				RETURN NEXT;
			END IF;
		END IF; 
			
	END LOOP;
	
	EXCEPTION WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS 
			err = RETURNED_SQLSTATE,
			err_msg = MESSAGE_TEXT;
		
		tabla1 := 'Error <<' || m[1] || '>> <<' || m[2] || '>>: ' || err_msg;
		id_nocontenido_completamente := '0';
		tabla2 := '0';
		RETURN NEXT;

END;


$$;
-- ddl-end --
ALTER FUNCTION validaciones.vtd_capaa_nocontenidacompletamente_capab() OWNER TO postgres;
-- ddl-end --
COMMENT ON FUNCTION validaciones.vtd_capaa_nocontenidacompletamente_capab() IS E'BEGL Versión 1.2.0.0';
-- ddl-end --

-- object: validaciones.vte_elementos_nocontenidosen_manzana | type: FUNCTION --
-- DROP FUNCTION IF EXISTS validaciones.vte_elementos_nocontenidosen_manzana() CASCADE;
CREATE FUNCTION validaciones.vte_elementos_nocontenidosen_manzana ()
	RETURNS TABLE ( tabla character varying,  id character varying,  nombre character varying)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 1000
	AS $$


DECLARE
	err varchar;
	err_msg varchar;
	r_registro RECORD;
	tabla_a integer;
	tabla_b integer;
	campo_a integer;
	campo_b integer;
	m varchar[];
	arr varchar[] := array[
	   						['cementerio','manzana'],
	   						['central_autobus','manzana'],
	   						['centro_comercial','manzana'],
	   						['centro_cultural','manzana'],
							['centro_recreativo','manzana'],
							['edificio','manzana'],
							['escuela','manzana'],
							['hospital','manzana'],
							['iglesia','manzana'],
	   						['mercado','manzana'],
							['oficina_gubernamental','manzana'],
							['oficina_municipal','manzana'],
							['plaza_monumento','manzana']
   						  ];
	
	 
BEGIN

	-- ******************************************************
	-- Validación Topológica
		-- E: Existen elementos de la primera capa que no estan contenidos en la segunda capa
	-- Capa : Algunas
	-- Prueba: 1
	-- Texto: Elementos de la tabla no contenidos en manzana
	-- BD - Esquema: bged17 - bged
	-- Archivo: vte_elementos_nocontenidosen_manzana_p1_sinp.sql
	-- Tiempo: 2 secs 966 msec. 249 rows affected.
	-- ******************************************************
	
	FOREACH m SLICE 1 IN ARRAY arr
	LOOP
	
		tabla_a := 0;
		tabla_b := 0;
		campo_a := 0;
		campo_b := 0;
		
		IF EXISTS ( SELECT * FROM information_schema.tables 
				    WHERE table_schema = 'bged' AND table_name = m[1] ) THEN
			tabla_a := 1;
		END IF;
		IF EXISTS ( SELECT * FROM information_schema.tables 
				    WHERE table_schema = 'bged' AND table_name = m[2] ) THEN
			tabla_b := 1;
		END IF;	
		IF EXISTS ( SELECT * FROM information_schema.columns 
				    WHERE table_schema = 'bged' AND table_name = m[1] AND column_name = 'geom' ) THEN
			campo_a := 1;
		END IF;
		IF EXISTS ( SELECT * FROM information_schema.columns 
				    WHERE table_schema = 'bged' AND table_name = m[2] AND column_name = 'geom' ) THEN
			campo_b := 1;
		END IF;
		
		
		IF (tabla_a <> 1 OR tabla_b <> 1) THEN
			tabla := 'Error: Alguna de las tablas <<' || m[1] || '>> o <<' || m[2] || '>> no existe';
			id := '0';
			nombre := '0';
			RETURN NEXT;
		
		ELSE
		
			IF (campo_a = 1 AND campo_b = 1) THEN
				FOR r_registro IN EXECUTE 
					'SELECT CAST(a.id AS varchar(20)) AS id , a.nombre, m.id
					FROM bged.' || m[1] ||' a 
						LEFT JOIN bged.' || m[2] ||' m ON
						ST_Intersects(a.geom, m.geom)
					WHERE m.id IS NULL
					ORDER BY a.id'

				LOOP
					tabla := m[1];
					id := r_registro.id;
					nombre := r_registro.nombre;
					RETURN NEXT;
				END LOOP;
			ELSE
				tabla := 'Error: Alguna de las tablas <<' || m[1] || '>> o <<' || m[2] || '>> no contiene el campo geom';
				id := '0';
				nombre := '0';
				RETURN NEXT;
			END IF;
		END IF; 
			
	END LOOP;
	
	EXCEPTION WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS 
			err = RETURNED_SQLSTATE,
			err_msg = MESSAGE_TEXT;
		
		tabla := 'Error <<' || m[1] || '>> <<' || m[2] || '>>: ' || err_msg;
		id := '0';
		nombre := '0';
		RETURN NEXT;

END;


$$;
-- ddl-end --
ALTER FUNCTION validaciones.vte_elementos_nocontenidosen_manzana() OWNER TO postgres;
-- ddl-end --
COMMENT ON FUNCTION validaciones.vte_elementos_nocontenidosen_manzana() IS E'BEGL Versión 1.1.0.0';
-- ddl-end --

-- object: app.capa | type: TABLE --
-- DROP TABLE IF EXISTS app.capa CASCADE;
CREATE TABLE app.capa (
	id integer NOT NULL,
	nombre character varying(40) NOT NULL,
	tabla character varying(30) NOT NULL,
	tipo_capa integer NOT NULL,
	tamano_elemento integer NOT NULL,
	color_r integer NOT NULL,
	color_g integer NOT NULL,
	color_b integer NOT NULL,
	salto integer NOT NULL,
	informacion_adicional character varying(100) NOT NULL DEFAULT 0,
	condicion character varying(40) NOT NULL DEFAULT 0,
	activa boolean NOT NULL DEFAULT false,
	CONSTRAINT pk_capa_id PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE app.capa OWNER TO postgres;
-- ddl-end --

-- object: app.config | type: TABLE --
-- DROP TABLE IF EXISTS app.config CASCADE;
CREATE TABLE app.config (
	entidad character varying,
	anio character varying,
	semana character varying,
	estado_remesa integer NOT NULL DEFAULT 0,
	ruta character varying
);
-- ddl-end --
ALTER TABLE app.config OWNER TO postgres;
-- ddl-end --

-- object: app.id_control_remesa | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS app.id_control_remesa CASCADE;
CREATE SEQUENCE app.id_control_remesa
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE app.id_control_remesa OWNER TO postgres;
-- ddl-end --

-- object: app.control | type: TABLE --
-- DROP TABLE IF EXISTS app.control CASCADE;
CREATE TABLE app.control (
	id integer NOT NULL DEFAULT nextval('app.id_control_remesa'::regclass),
	cve_entidad integer,
	id_manzana integer,
	id_localidad integer,
	control integer,
	CONSTRAINT control_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE app.control OWNER TO postgres;
-- ddl-end --

-- object: app.cuadrante | type: TABLE --
-- DROP TABLE IF EXISTS app.cuadrante CASCADE;
CREATE TABLE app.cuadrante (
	cuadrante character(8),
	geom public.geometry
);
-- ddl-end --
ALTER TABLE app.cuadrante OWNER TO postgres;
-- ddl-end --

-- object: app.cuadrante_numerico | type: TABLE --
-- DROP TABLE IF EXISTS app.cuadrante_numerico CASCADE;
CREATE TABLE app.cuadrante_numerico (
	cuadrante character(8),
	numxmin double precision,
	numymin double precision,
	numxmax double precision,
	numymax double precision
);
-- ddl-end --
ALTER TABLE app.cuadrante_numerico OWNER TO postgres;
-- ddl-end --

-- object: app.id_proc_remesa | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS app.id_proc_remesa CASCADE;
CREATE SEQUENCE app.id_proc_remesa
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE app.id_proc_remesa OWNER TO postgres;
-- ddl-end --
COMMENT ON SEQUENCE app.id_proc_remesa IS E'Secuencia del identificador del procesamiento de remesas';
-- ddl-end --

-- object: app.interseccion_graficos | type: TABLE --
-- DROP TABLE IF EXISTS app.interseccion_graficos CASCADE;
CREATE TABLE app.interseccion_graficos (
	id integer,
	geom public.geometry,
	anillos integer,
	tipogeometria character varying(40)
);
-- ddl-end --
ALTER TABLE app.interseccion_graficos OWNER TO postgres;
-- ddl-end --

-- object: app.interseccion_numeros_exteriores | type: TABLE --
-- DROP TABLE IF EXISTS app.interseccion_numeros_exteriores CASCADE;
CREATE TABLE app.interseccion_numeros_exteriores (
	id integer NOT NULL,
	geom public.geometry,
	numeros_exteriores character varying(8000)
);
-- ddl-end --
ALTER TABLE app.interseccion_numeros_exteriores OWNER TO postgres;
-- ddl-end --

-- object: app.origen | type: TABLE --
-- DROP TABLE IF EXISTS app.origen CASCADE;
CREATE TABLE app.origen (
	x double precision,
	y double precision,
	srid integer
);
-- ddl-end --
ALTER TABLE app.origen OWNER TO postgres;
-- ddl-end --

-- object: app.proceso_remesa | type: TABLE --
-- DROP TABLE IF EXISTS app.proceso_remesa CASCADE;
CREATE TABLE app.proceso_remesa (
	id integer NOT NULL DEFAULT nextval('app.id_proc_remesa'::regclass),
	entidad smallint NOT NULL,
	remesa integer NOT NULL,
	gen_ascii bit(1) NOT NULL,
	gen_dwf bit(1) NOT NULL,
	gen_geoloc bit(1) NOT NULL,
	fecha_hora timestamp(4) NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT proceso_remesa_pk PRIMARY KEY (id)

);
-- ddl-end --
COMMENT ON TABLE app.proceso_remesa IS E'status del procesamiento de las remesas de actualización cartográfica';
-- ddl-end --
COMMENT ON COLUMN app.proceso_remesa.id IS 'identificador del procesamiento de la remesa';
-- ddl-end --
COMMENT ON COLUMN app.proceso_remesa.entidad IS 'Clave de la entidad de la remesa en proceso';
-- ddl-end --
COMMENT ON COLUMN app.proceso_remesa.remesa IS 'clave de la remesa en proceso, Año + Semana , (AAAA23)';
-- ddl-end --
COMMENT ON COLUMN app.proceso_remesa.gen_ascii IS 'Status del proceso de generación de los archivos ASCII de la remesa.   (0: pendiente, 1: concluido)';
-- ddl-end --
COMMENT ON COLUMN app.proceso_remesa.gen_dwf IS 'status de la generación de archivos .dwf  (0: pendiente, 1: concluido)';
-- ddl-end --
COMMENT ON COLUMN app.proceso_remesa.gen_geoloc IS 'Status del proceso de generación de la base de Geolocalización.   (0: pendiente, 1: concluido)';
-- ddl-end --
COMMENT ON COLUMN app.proceso_remesa.fecha_hora IS 'Fecha y hora de la ultima modificación';
-- ddl-end --
ALTER TABLE app.proceso_remesa OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_aeropuerto_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS bged.cat_aeropuerto_id_seq CASCADE;
CREATE SEQUENCE bged.cat_aeropuerto_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE bged.cat_aeropuerto_id_seq OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_aeropuerto | type: TABLE --
-- DROP TABLE IF EXISTS bged.cat_aeropuerto CASCADE;
CREATE TABLE bged.cat_aeropuerto (
	id integer NOT NULL DEFAULT nextval('bged.cat_aeropuerto_id_seq'::regclass),
	tipo integer NOT NULL,
	nombre character varying(15) NOT NULL,
	control integer,
	CONSTRAINT cat_aeropuerto_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE bged.cat_aeropuerto OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_cabecera_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS bged.cat_cabecera_id_seq CASCADE;
CREATE SEQUENCE bged.cat_cabecera_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE bged.cat_cabecera_id_seq OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_cabecera | type: TABLE --
-- DROP TABLE IF EXISTS bged.cat_cabecera CASCADE;
CREATE TABLE bged.cat_cabecera (
	id integer NOT NULL DEFAULT nextval('bged.cat_cabecera_id_seq'::regclass),
	cabecera integer NOT NULL,
	nombre character varying(20) NOT NULL,
	control integer,
	CONSTRAINT cat_cabecera_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE bged.cat_cabecera OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_categoria_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS bged.cat_categoria_id_seq CASCADE;
CREATE SEQUENCE bged.cat_categoria_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE bged.cat_categoria_id_seq OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_categoria | type: TABLE --
-- DROP TABLE IF EXISTS bged.cat_categoria CASCADE;
CREATE TABLE bged.cat_categoria (
	id integer NOT NULL DEFAULT nextval('bged.cat_categoria_id_seq'::regclass),
	categoria integer NOT NULL,
	nombre character varying(10) NOT NULL,
	control integer,
	CONSTRAINT cat_categoria_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE bged.cat_categoria OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_circunscripcion_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS bged.cat_circunscripcion_id_seq CASCADE;
CREATE SEQUENCE bged.cat_circunscripcion_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE bged.cat_circunscripcion_id_seq OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_circunscripcion | type: TABLE --
-- DROP TABLE IF EXISTS bged.cat_circunscripcion CASCADE;
CREATE TABLE bged.cat_circunscripcion (
	id integer NOT NULL DEFAULT nextval('bged.cat_circunscripcion_id_seq'::regclass),
	circunscripcion integer NOT NULL,
	sede character varying(16),
	estados_integrantes character varying(110),
	control integer,
	CONSTRAINT cat_circunscripcion_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE bged.cat_circunscripcion OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_clasificacion_colonia_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS bged.cat_clasificacion_colonia_id_seq CASCADE;
CREATE SEQUENCE bged.cat_clasificacion_colonia_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE bged.cat_clasificacion_colonia_id_seq OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_clasificacion_colonia | type: TABLE --
-- DROP TABLE IF EXISTS bged.cat_clasificacion_colonia CASCADE;
CREATE TABLE bged.cat_clasificacion_colonia (
	id integer NOT NULL DEFAULT nextval('bged.cat_clasificacion_colonia_id_seq'::regclass),
	clasificacion integer NOT NULL,
	categoria character varying(30) NOT NULL,
	abreviatura character varying(10) NOT NULL,
	control integer,
	CONSTRAINT cat_clasificacion_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE bged.cat_clasificacion_colonia OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_condicion_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS bged.cat_condicion_id_seq CASCADE;
CREATE SEQUENCE bged.cat_condicion_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE bged.cat_condicion_id_seq OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_condicion | type: TABLE --
-- DROP TABLE IF EXISTS bged.cat_condicion CASCADE;
CREATE TABLE bged.cat_condicion (
	id integer NOT NULL DEFAULT nextval('bged.cat_condicion_id_seq'::regclass),
	condicion integer NOT NULL,
	nombre character varying(10) NOT NULL,
	control integer,
	CONSTRAINT cat_condicion_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE bged.cat_condicion OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_crc_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS bged.cat_crc_id_seq CASCADE;
CREATE SEQUENCE bged.cat_crc_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE bged.cat_crc_id_seq OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_crc | type: TABLE --
-- DROP TABLE IF EXISTS bged.cat_crc CASCADE;
CREATE TABLE bged.cat_crc (
	id integer NOT NULL DEFAULT nextval('bged.cat_crc_id_seq'::regclass),
	crc integer NOT NULL,
	nombre character varying(20) NOT NULL,
	impresion integer,
	estados_integrantes character varying(43) NOT NULL,
	control integer,
	CONSTRAINT cat_crc_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE bged.cat_crc OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_escuela_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS bged.cat_escuela_id_seq CASCADE;
CREATE SEQUENCE bged.cat_escuela_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE bged.cat_escuela_id_seq OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_escuela | type: TABLE --
-- DROP TABLE IF EXISTS bged.cat_escuela CASCADE;
CREATE TABLE bged.cat_escuela (
	id integer NOT NULL DEFAULT nextval('bged.cat_escuela_id_seq'::regclass),
	tipo integer NOT NULL,
	nombre character varying(15) NOT NULL,
	control integer,
	CONSTRAINT cat_escuela_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE bged.cat_escuela OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_hidrografia_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS bged.cat_hidrografia_id_seq CASCADE;
CREATE SEQUENCE bged.cat_hidrografia_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE bged.cat_hidrografia_id_seq OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_hidrografia | type: TABLE --
-- DROP TABLE IF EXISTS bged.cat_hidrografia CASCADE;
CREATE TABLE bged.cat_hidrografia (
	id integer NOT NULL DEFAULT nextval('bged.cat_hidrografia_id_seq'::regclass),
	tipo integer NOT NULL,
	categoria character varying(35) NOT NULL,
	control integer,
	CONSTRAINT cat_hidrografia_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE bged.cat_hidrografia OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_ofmpal_cryt_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS bged.cat_ofmpal_cryt_id_seq CASCADE;
CREATE SEQUENCE bged.cat_ofmpal_cryt_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE bged.cat_ofmpal_cryt_id_seq OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_ofmpal_cryt | type: TABLE --
-- DROP TABLE IF EXISTS bged.cat_ofmpal_cryt CASCADE;
CREATE TABLE bged.cat_ofmpal_cryt (
	id integer NOT NULL DEFAULT nextval('bged.cat_ofmpal_cryt_id_seq'::regclass),
	tipo integer NOT NULL,
	nombre character varying(25) NOT NULL,
	control integer,
	CONSTRAINT cat_ofmpal_cryt_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE bged.cat_ofmpal_cryt OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_puente_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS bged.cat_puente_id_seq CASCADE;
CREATE SEQUENCE bged.cat_puente_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE bged.cat_puente_id_seq OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_puente | type: TABLE --
-- DROP TABLE IF EXISTS bged.cat_puente CASCADE;
CREATE TABLE bged.cat_puente (
	id integer NOT NULL DEFAULT nextval('bged.cat_puente_id_seq'::regclass),
	tipo integer NOT NULL,
	nombre character varying(16) NOT NULL,
	control integer,
	CONSTRAINT cat_puente_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE bged.cat_puente OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_red_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS bged.cat_red_id_seq CASCADE;
CREATE SEQUENCE bged.cat_red_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE bged.cat_red_id_seq OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_red | type: TABLE --
-- DROP TABLE IF EXISTS bged.cat_red CASCADE;
CREATE TABLE bged.cat_red (
	id integer NOT NULL DEFAULT nextval('bged.cat_red_id_seq'::regclass),
	rasgo integer NOT NULL,
	nombre character varying(30) NOT NULL,
	control integer,
	CONSTRAINT cat_red_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE bged.cat_red OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_sentido_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS bged.cat_sentido_id_seq CASCADE;
CREATE SEQUENCE bged.cat_sentido_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE bged.cat_sentido_id_seq OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_sentido | type: TABLE --
-- DROP TABLE IF EXISTS bged.cat_sentido CASCADE;
CREATE TABLE bged.cat_sentido (
	id integer NOT NULL DEFAULT nextval('bged.cat_sentido_id_seq'::regclass),
	sentido integer NOT NULL,
	nombre character varying(40) NOT NULL,
	control integer,
	CONSTRAINT cat_sentido_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE bged.cat_sentido OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_status_hidrografia_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS bged.cat_status_hidrografia_id_seq CASCADE;
CREATE SEQUENCE bged.cat_status_hidrografia_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE bged.cat_status_hidrografia_id_seq OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_status_hidrografia | type: TABLE --
-- DROP TABLE IF EXISTS bged.cat_status_hidrografia CASCADE;
CREATE TABLE bged.cat_status_hidrografia (
	id integer NOT NULL DEFAULT nextval('bged.cat_status_hidrografia_id_seq'::regclass),
	status integer NOT NULL,
	nombre character varying(10) NOT NULL,
	control integer,
	CONSTRAINT cat_status_hidrografia_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE bged.cat_status_hidrografia OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_status_mz_loc_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS bged.cat_status_mz_loc_id_seq CASCADE;
CREATE SEQUENCE bged.cat_status_mz_loc_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE bged.cat_status_mz_loc_id_seq OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_status_mz_loc | type: TABLE --
-- DROP TABLE IF EXISTS bged.cat_status_mz_loc CASCADE;
CREATE TABLE bged.cat_status_mz_loc (
	id integer NOT NULL DEFAULT nextval('bged.cat_status_mz_loc_id_seq'::regclass),
	status integer NOT NULL,
	nombre character varying(15) NOT NULL,
	control integer,
	CONSTRAINT cat_status_mz_loc_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE bged.cat_status_mz_loc OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_tipo_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS bged.cat_tipo_id_seq CASCADE;
CREATE SEQUENCE bged.cat_tipo_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE bged.cat_tipo_id_seq OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_tipo | type: TABLE --
-- DROP TABLE IF EXISTS bged.cat_tipo CASCADE;
CREATE TABLE bged.cat_tipo (
	id integer NOT NULL DEFAULT nextval('bged.cat_tipo_id_seq'::regclass),
	tipo integer NOT NULL,
	nombre character varying(18) NOT NULL,
	control integer,
	CONSTRAINT cat_tipo_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE bged.cat_tipo OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_tipo_localidad_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS bged.cat_tipo_localidad_id_seq CASCADE;
CREATE SEQUENCE bged.cat_tipo_localidad_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE bged.cat_tipo_localidad_id_seq OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_tipo_localidad | type: TABLE --
-- DROP TABLE IF EXISTS bged.cat_tipo_localidad CASCADE;
CREATE TABLE bged.cat_tipo_localidad (
	id integer NOT NULL DEFAULT nextval('bged.cat_tipo_localidad_id_seq'::regclass),
	tipo integer NOT NULL,
	descripcion character varying NOT NULL,
	CONSTRAINT cat_tipo_localidad_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE bged.cat_tipo_localidad OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_tipo_modulo_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS bged.cat_tipo_modulo_id_seq CASCADE;
CREATE SEQUENCE bged.cat_tipo_modulo_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE bged.cat_tipo_modulo_id_seq OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_tipo_modulo | type: TABLE --
-- DROP TABLE IF EXISTS bged.cat_tipo_modulo CASCADE;
CREATE TABLE bged.cat_tipo_modulo (
	id integer NOT NULL DEFAULT nextval('bged.cat_tipo_modulo_id_seq'::regclass),
	tipo integer NOT NULL,
	nombre character varying(15) NOT NULL,
	control integer,
	CONSTRAINT cat_tipo_modulo_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE bged.cat_tipo_modulo OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_vialidad_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS bged.cat_vialidad_id_seq CASCADE;
CREATE SEQUENCE bged.cat_vialidad_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE bged.cat_vialidad_id_seq OWNER TO postgres;
-- ddl-end --

-- object: bged.cat_vialidad | type: TABLE --
-- DROP TABLE IF EXISTS bged.cat_vialidad CASCADE;
CREATE TABLE bged.cat_vialidad (
	id integer NOT NULL DEFAULT nextval('bged.cat_vialidad_id_seq'::regclass),
	tipo integer NOT NULL,
	nombre character varying(15) NOT NULL,
	abreviatura character varying(10) NOT NULL,
	control integer,
	CONSTRAINT cat_vialidad_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE bged.cat_vialidad OWNER TO postgres;
-- ddl-end --

-- object: validaciones.manzana_sin_colonia_101_idpk_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS validaciones.manzana_sin_colonia_101_idpk_seq CASCADE;
CREATE SEQUENCE validaciones.manzana_sin_colonia_101_idpk_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE validaciones.manzana_sin_colonia_101_idpk_seq OWNER TO postgres;
-- ddl-end --

-- object: validaciones.manzana_sin_localidad_p1_103_idpk_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS validaciones.manzana_sin_localidad_p1_103_idpk_seq CASCADE;
CREATE SEQUENCE validaciones.manzana_sin_localidad_p1_103_idpk_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE validaciones.manzana_sin_localidad_p1_103_idpk_seq OWNER TO postgres;
-- ddl-end --

-- object: validaciones.manzana_sin_localidad_p1_103 | type: TABLE --
-- DROP TABLE IF EXISTS validaciones.manzana_sin_localidad_p1_103 CASCADE;
CREATE TABLE validaciones.manzana_sin_localidad_p1_103 (
	mzaid integer,
	geom public.geometry,
	idpk integer NOT NULL DEFAULT nextval('validaciones.manzana_sin_localidad_p1_103_idpk_seq'::regclass),
	CONSTRAINT manzana_sin_localidad_p1_103_pkey PRIMARY KEY (idpk)

);
-- ddl-end --
ALTER TABLE validaciones.manzana_sin_localidad_p1_103 OWNER TO postgres;
-- ddl-end --

-- object: validaciones.manzana_sin_localidad_p2_103_idpk_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS validaciones.manzana_sin_localidad_p2_103_idpk_seq CASCADE;
CREATE SEQUENCE validaciones.manzana_sin_localidad_p2_103_idpk_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE validaciones.manzana_sin_localidad_p2_103_idpk_seq OWNER TO postgres;
-- ddl-end --

-- object: validaciones.manzana_sin_localidad_p2_103 | type: TABLE --
-- DROP TABLE IF EXISTS validaciones.manzana_sin_localidad_p2_103 CASCADE;
CREATE TABLE validaciones.manzana_sin_localidad_p2_103 (
	mzaid integer,
	geom public.geometry,
	idpk integer NOT NULL DEFAULT nextval('validaciones.manzana_sin_localidad_p2_103_idpk_seq'::regclass),
	CONSTRAINT manzana_sin_localidad_p2_103_pkey PRIMARY KEY (idpk)

);
-- ddl-end --
ALTER TABLE validaciones.manzana_sin_localidad_p2_103 OWNER TO postgres;
-- ddl-end --

-- object: validaciones.manzana_sin_localidad_p3_103_idpk_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS validaciones.manzana_sin_localidad_p3_103_idpk_seq CASCADE;
CREATE SEQUENCE validaciones.manzana_sin_localidad_p3_103_idpk_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE validaciones.manzana_sin_localidad_p3_103_idpk_seq OWNER TO postgres;
-- ddl-end --

-- object: validaciones.manzana_sin_seccion_p1_102_idpk_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS validaciones.manzana_sin_seccion_p1_102_idpk_seq CASCADE;
CREATE SEQUENCE validaciones.manzana_sin_seccion_p1_102_idpk_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE validaciones.manzana_sin_seccion_p1_102_idpk_seq OWNER TO postgres;
-- ddl-end --

-- object: validaciones.manzana_sin_seccion_p1_102 | type: TABLE --
-- DROP TABLE IF EXISTS validaciones.manzana_sin_seccion_p1_102 CASCADE;
CREATE TABLE validaciones.manzana_sin_seccion_p1_102 (
	mzaid integer,
	geom public.geometry,
	idpk integer NOT NULL DEFAULT nextval('validaciones.manzana_sin_seccion_p1_102_idpk_seq'::regclass),
	CONSTRAINT manzana_sin_seccion_p1_102_pkey PRIMARY KEY (idpk)

);
-- ddl-end --
ALTER TABLE validaciones.manzana_sin_seccion_p1_102 OWNER TO postgres;
-- ddl-end --

-- object: validaciones.manzana_sin_seccion_p2_102_idpk_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS validaciones.manzana_sin_seccion_p2_102_idpk_seq CASCADE;
CREATE SEQUENCE validaciones.manzana_sin_seccion_p2_102_idpk_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE validaciones.manzana_sin_seccion_p2_102_idpk_seq OWNER TO postgres;
-- ddl-end --

-- object: validaciones.manzana_sin_seccion_p2_102 | type: TABLE --
-- DROP TABLE IF EXISTS validaciones.manzana_sin_seccion_p2_102 CASCADE;
CREATE TABLE validaciones.manzana_sin_seccion_p2_102 (
	mzaid integer,
	geom public.geometry,
	idpk integer NOT NULL DEFAULT nextval('validaciones.manzana_sin_seccion_p2_102_idpk_seq'::regclass),
	CONSTRAINT manzana_sin_seccion_p2_102_pkey PRIMARY KEY (idpk)

);
-- ddl-end --
ALTER TABLE validaciones.manzana_sin_seccion_p2_102 OWNER TO postgres;
-- ddl-end --

-- object: validaciones.manzana_sin_seccion_p3_102_idpk_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS validaciones.manzana_sin_seccion_p3_102_idpk_seq CASCADE;
CREATE SEQUENCE validaciones.manzana_sin_seccion_p3_102_idpk_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE validaciones.manzana_sin_seccion_p3_102_idpk_seq OWNER TO postgres;
-- ddl-end --

-- object: validaciones.manzana_sin_seccion_p3_102 | type: TABLE --
-- DROP TABLE IF EXISTS validaciones.manzana_sin_seccion_p3_102 CASCADE;
CREATE TABLE validaciones.manzana_sin_seccion_p3_102 (
	mzaid integer,
	geom public.geometry,
	idpk integer NOT NULL DEFAULT nextval('validaciones.manzana_sin_seccion_p3_102_idpk_seq'::regclass),
	CONSTRAINT manzana_sin_seccion_p3_102_pkey PRIMARY KEY (idpk)

);
-- ddl-end --
ALTER TABLE validaciones.manzana_sin_seccion_p3_102 OWNER TO postgres;
-- ddl-end --

-- object: i_cuadrante_cuadrante | type: INDEX --
-- DROP INDEX IF EXISTS app.i_cuadrante_cuadrante CASCADE;
CREATE INDEX i_cuadrante_cuadrante ON app.cuadrante
	USING hash
	(
	  cuadrante
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: i_cuadrante_numerico_cuadrante | type: INDEX --
-- DROP INDEX IF EXISTS app.i_cuadrante_numerico_cuadrante CASCADE;
CREATE INDEX i_cuadrante_numerico_cuadrante ON app.cuadrante_numerico
	USING hash
	(
	  cuadrante
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: i_interseccion_numeros_exteriores_numeros_exteriores | type: INDEX --
-- DROP INDEX IF EXISTS app.i_interseccion_numeros_exteriores_numeros_exteriores CASCADE;
CREATE INDEX i_interseccion_numeros_exteriores_numeros_exteriores ON app.interseccion_numeros_exteriores
	USING hash
	(
	  numeros_exteriores
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: sidx_cuadrante_geom | type: INDEX --
-- DROP INDEX IF EXISTS app.sidx_cuadrante_geom CASCADE;
CREATE INDEX sidx_cuadrante_geom ON app.cuadrante
	USING gist
	(
	  geom
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: sidx_interseccion_numeros_exteriores_geom | type: INDEX --
-- DROP INDEX IF EXISTS app.sidx_interseccion_numeros_exteriores_geom CASCADE;
CREATE INDEX sidx_interseccion_numeros_exteriores_geom ON app.interseccion_numeros_exteriores
	USING gist
	(
	  geom
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: manzana_sin_localidad_p1_103_ie | type: INDEX --
-- DROP INDEX IF EXISTS validaciones.manzana_sin_localidad_p1_103_ie CASCADE;
CREATE INDEX manzana_sin_localidad_p1_103_ie ON validaciones.manzana_sin_localidad_p1_103
	USING gist
	(
	  geom
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: manzana_sin_localidad_p1_103_ih_idpk | type: INDEX --
-- DROP INDEX IF EXISTS validaciones.manzana_sin_localidad_p1_103_ih_idpk CASCADE;
CREATE INDEX manzana_sin_localidad_p1_103_ih_idpk ON validaciones.manzana_sin_localidad_p1_103
	USING hash
	(
	  idpk
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: manzana_sin_localidad_p1_103_ih_mzaid | type: INDEX --
-- DROP INDEX IF EXISTS validaciones.manzana_sin_localidad_p1_103_ih_mzaid CASCADE;
CREATE INDEX manzana_sin_localidad_p1_103_ih_mzaid ON validaciones.manzana_sin_localidad_p1_103
	USING hash
	(
	  mzaid
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: manzana_sin_localidad_p2_103_ie | type: INDEX --
-- DROP INDEX IF EXISTS validaciones.manzana_sin_localidad_p2_103_ie CASCADE;
CREATE INDEX manzana_sin_localidad_p2_103_ie ON validaciones.manzana_sin_localidad_p2_103
	USING gist
	(
	  geom
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: manzana_sin_localidad_p2_103_ih_idpk | type: INDEX --
-- DROP INDEX IF EXISTS validaciones.manzana_sin_localidad_p2_103_ih_idpk CASCADE;
CREATE INDEX manzana_sin_localidad_p2_103_ih_idpk ON validaciones.manzana_sin_localidad_p2_103
	USING hash
	(
	  idpk
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: manzana_sin_localidad_p2_103_ih_mzaid | type: INDEX --
-- DROP INDEX IF EXISTS validaciones.manzana_sin_localidad_p2_103_ih_mzaid CASCADE;
CREATE INDEX manzana_sin_localidad_p2_103_ih_mzaid ON validaciones.manzana_sin_localidad_p2_103
	USING hash
	(
	  mzaid
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: manzana_sin_seccion_p1_102_ie | type: INDEX --
-- DROP INDEX IF EXISTS validaciones.manzana_sin_seccion_p1_102_ie CASCADE;
CREATE INDEX manzana_sin_seccion_p1_102_ie ON validaciones.manzana_sin_seccion_p1_102
	USING gist
	(
	  geom
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: manzana_sin_seccion_p1_102_ih_idpk | type: INDEX --
-- DROP INDEX IF EXISTS validaciones.manzana_sin_seccion_p1_102_ih_idpk CASCADE;
CREATE INDEX manzana_sin_seccion_p1_102_ih_idpk ON validaciones.manzana_sin_seccion_p1_102
	USING hash
	(
	  idpk
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: manzana_sin_seccion_p1_102_ih_mzaid | type: INDEX --
-- DROP INDEX IF EXISTS validaciones.manzana_sin_seccion_p1_102_ih_mzaid CASCADE;
CREATE INDEX manzana_sin_seccion_p1_102_ih_mzaid ON validaciones.manzana_sin_seccion_p1_102
	USING hash
	(
	  mzaid
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: manzana_sin_seccion_p2_102_ie | type: INDEX --
-- DROP INDEX IF EXISTS validaciones.manzana_sin_seccion_p2_102_ie CASCADE;
CREATE INDEX manzana_sin_seccion_p2_102_ie ON validaciones.manzana_sin_seccion_p2_102
	USING gist
	(
	  geom
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: manzana_sin_seccion_p2_102_ih_idpk | type: INDEX --
-- DROP INDEX IF EXISTS validaciones.manzana_sin_seccion_p2_102_ih_idpk CASCADE;
CREATE INDEX manzana_sin_seccion_p2_102_ih_idpk ON validaciones.manzana_sin_seccion_p2_102
	USING hash
	(
	  idpk
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: manzana_sin_seccion_p2_102_ih_mzaid | type: INDEX --
-- DROP INDEX IF EXISTS validaciones.manzana_sin_seccion_p2_102_ih_mzaid CASCADE;
CREATE INDEX manzana_sin_seccion_p2_102_ih_mzaid ON validaciones.manzana_sin_seccion_p2_102
	USING hash
	(
	  mzaid
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: manzana_sin_seccion_p3_102_ie | type: INDEX --
-- DROP INDEX IF EXISTS validaciones.manzana_sin_seccion_p3_102_ie CASCADE;
CREATE INDEX manzana_sin_seccion_p3_102_ie ON validaciones.manzana_sin_seccion_p3_102
	USING gist
	(
	  geom
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: manzana_sin_seccion_p3_102_ih_idpk | type: INDEX --
-- DROP INDEX IF EXISTS validaciones.manzana_sin_seccion_p3_102_ih_idpk CASCADE;
CREATE INDEX manzana_sin_seccion_p3_102_ih_idpk ON validaciones.manzana_sin_seccion_p3_102
	USING hash
	(
	  idpk
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: manzana_sin_seccion_p3_102_ih_mzaid | type: INDEX --
-- DROP INDEX IF EXISTS validaciones.manzana_sin_seccion_p3_102_ih_mzaid CASCADE;
CREATE INDEX manzana_sin_seccion_p3_102_ih_mzaid ON validaciones.manzana_sin_seccion_p3_102
	USING hash
	(
	  mzaid
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: validaciones.manzanas_fuera_seccion | type: FUNCTION --
-- DROP FUNCTION IF EXISTS validaciones.manzanas_fuera_seccion() CASCADE;
CREATE FUNCTION validaciones.manzanas_fuera_seccion ()
	RETURNS TABLE ( id_mza bigint,  x_err double precision,  y_err double precision)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 30000
	AS $$

DECLARE
	errnumber text;
	resul_val record;
	filter_val record;
	err_context text;
	filter_mpio int;
BEGIN
	IF EXISTS (SELECT * FROM information_schema.tables WHERE table_schema = 'bged' AND table_name = 'manzana') THEN
		IF EXISTS (SELECT * FROM information_schema.tables WHERE table_schema = 'bged' AND table_name = 'seccion') THEN		
			EXECUTE 'TRUNCATE TABLE validaciones.manzana_sin_seccion_p1_102';
			EXECUTE 'TRUNCATE TABLE validaciones.manzana_sin_seccion_p2_102';
			EXECUTE 'TRUNCATE TABLE validaciones.manzana_sin_seccion_p3_102';
			
			FOR filter_val IN EXECUTE 'SELECT municipio from bged.municipio'
			LOOP
				filter_mpio := filter_val.municipio;		
				EXECUTE 'INSERT INTO validaciones.manzana_sin_seccion_p1_102(mzaid, geom) SELECT A.id as mzaid, ST_Multi(ST_Buffer(ST_Intersection(B.geom, A.geom),0.0)) as geom FROM bged.seccion as B INNER JOIN bged.manzana as A ON ST_Intersects(B.geom, A.geom) WHERE Not ST_IsEmpty(ST_Buffer(ST_Intersection(B.geom, A.geom),0.0)) and A.seccion <> B.seccion and A.municipio='|| filter_mpio ||' and B.municipio='|| filter_mpio;
				EXECUTE 'INSERT INTO validaciones.manzana_sin_seccion_p2_102(mzaid, geom) SELECT A.id as mzaid, ST_Difference(A.geom, ST_Multi(ST_Buffer(ST_Intersection(B.geom, A.geom),0.0))) as geom FROM bged.seccion as B INNER JOIN bged.manzana as A ON ST_Intersects(B.geom, A.geom) WHERE Not ST_IsEmpty(ST_Buffer(ST_Intersection(B.geom, A.geom),0.0)) and A.seccion = B.seccion and ST_Area(A.geom)-ST_Area(ST_Multi(ST_Buffer(ST_Intersection(B.geom, A.geom),0.0))) > 0 and A.municipio='|| filter_mpio ||' and B.municipio='|| filter_mpio;
				EXECUTE 'INSERT INTO validaciones.manzana_sin_seccion_p3_102(mzaid, geom) SELECT DISTINCT A.id as mzaid, A.geom FROM bged.seccion as B INNER JOIN bged.manzana as A ON (NOT ST_Intersects(B.geom, A.geom)) WHERE A.seccion = B.seccion and A.municipio='|| filter_mpio ||' and B.municipio='|| filter_mpio;
				RETURN NEXT;
			END LOOP;	
			
			FOR resul_val IN EXECUTE 'SELECT o.id, ST_X(o.geom) as x, ST_Y(o.geom) as y FROM (	SELECT n.mzaid as id,(ST_DumpPoints(n.geom)).* as geom FROM (	SELECT DISTINCT A.mzaid as mzaid, A.geom as geom FROM validaciones.manzana_sin_seccion_p1_102 as A UNION SELECT DISTINCT A.mzaid as mzaid, A.geom as geom FROM validaciones.manzana_sin_seccion_p2_102 as A UNION SELECT DISTINCT A.mzaid as mzaid, A.geom as geom FROM validaciones.manzana_sin_seccion_p3_102 as A ) n ) o'
			LOOP
				id_mza := resul_val.id;
				x_err := resul_val.x;
				y_err := resul_val.y;
				RETURN NEXT;
			END LOOP;
		ELSE
				id_mza := 0;
				x_err := 0;
				y_err := 0;
			RETURN NEXT;
		END IF;		
	ELSE
			id_mza := 0;
			x_err := 0;
			y_err := 0;
		RETURN NEXT;
  	END IF;
	
	EXCEPTION WHEN OTHERS THEN
  		GET STACKED DIAGNOSTICS errnumber = RETURNED_SQLSTATE;
		GET STACKED DIAGNOSTICS err_context = PG_EXCEPTION_CONTEXT;
		IF errnumber = '42703' THEN
			id_mza := 0;
			x_err := 0;
			y_err := 0;
			RETURN NEXT;
		END IF;
END;

$$;
-- ddl-end --
ALTER FUNCTION validaciones.manzanas_fuera_seccion() OWNER TO postgres;
-- ddl-end --
COMMENT ON FUNCTION validaciones.manzanas_fuera_seccion() IS E'JLMM Function Version 0.0.1.4';
-- ddl-end --

-- object: validaciones.manzana_sin_localidad_p3_103 | type: TABLE --
-- DROP TABLE IF EXISTS validaciones.manzana_sin_localidad_p3_103 CASCADE;
CREATE TABLE validaciones.manzana_sin_localidad_p3_103 (
	mzaid integer,
	geom public.geometry,
	idpk integer NOT NULL DEFAULT nextval('validaciones.manzana_sin_localidad_p3_103_idpk_seq'::regclass),
	CONSTRAINT manzana_sin_localidad_p3_103_pkey PRIMARY KEY (idpk)

);
-- ddl-end --
ALTER TABLE validaciones.manzana_sin_localidad_p3_103 OWNER TO postgres;
-- ddl-end --

-- object: validaciones.manzanas_fuera_localidad | type: FUNCTION --
-- DROP FUNCTION IF EXISTS validaciones.manzanas_fuera_localidad() CASCADE;
CREATE FUNCTION validaciones.manzanas_fuera_localidad ()
	RETURNS TABLE ( id_mza bigint,  x_err double precision,  y_err double precision)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 30000
	AS $$

DECLARE
	errnumber text;
	resul_val record;
	err_context text;
	filter_val record;
	filter_mpio int;
BEGIN
	IF EXISTS (SELECT * FROM information_schema.tables WHERE table_schema = 'bged' AND table_name = 'manzana') THEN
		IF EXISTS (SELECT * FROM information_schema.tables WHERE table_schema = 'bged' AND table_name = 'limite_localidad') THEN		
			EXECUTE 'TRUNCATE TABLE validaciones.manzana_sin_localidad_p1_103';
			EXECUTE 'TRUNCATE TABLE validaciones.manzana_sin_localidad_p2_103';
			EXECUTE 'TRUNCATE TABLE validaciones.manzana_sin_localidad_p3_103';
			FOR filter_val IN EXECUTE 'SELECT municipio from bged.municipio'
			LOOP
				filter_mpio := filter_val.municipio;			
				EXECUTE 'INSERT INTO validaciones.manzana_sin_localidad_p1_103(mzaid, geom) SELECT A.id as mzaid, ST_Multi(ST_Buffer(ST_Intersection(B.geom, A.geom),0.0)) as geom FROM bged.limite_localidad as B INNER JOIN bged.manzana as A ON ST_Intersects(B.geom, A.geom) WHERE Not ST_IsEmpty(ST_Buffer(ST_Intersection(B.geom, A.geom),0.0)) and A.localidad <> B.localidad and A.municipio='|| filter_mpio ||' and B.municipio='|| filter_mpio;
				EXECUTE 'INSERT INTO validaciones.manzana_sin_localidad_p2_103(mzaid, geom) SELECT A.id as mzaid,ST_Difference(A.geom, ST_Multi(ST_Buffer(ST_Intersection(B.geom, A.geom),0.0))) as geom FROM bged.limite_localidad as B INNER JOIN bged.manzana as A ON ST_Intersects(B.geom, A.geom) WHERE Not ST_IsEmpty(ST_Buffer(ST_Intersection(B.geom, A.geom),0.0)) and A.localidad = B.localidad and ST_Area(A.geom)-ST_Area(ST_Multi(ST_Buffer(ST_Intersection(B.geom, A.geom),0.0))) > 0 and A.municipio='|| filter_mpio ||' and B.municipio='|| filter_mpio;
				EXECUTE 'INSERT INTO validaciones.manzana_sin_localidad_p3_103(mzaid, geom) SELECT DISTINCT A.id as mzaid,A.geom FROM bged.limite_localidad as B INNER JOIN bged.manzana as A ON (NOT ST_Intersects(B.geom, A.geom)) WHERE A.localidad = B.localidad and A.municipio='|| filter_mpio ||' and B.municipio='|| filter_mpio;
				RETURN NEXT;
			END LOOP;			
								
			FOR resul_val IN EXECUTE 'SELECT o.id, ST_X(o.geom) as x, ST_Y(o.geom) as y FROM (	SELECT n.mzaid as id,(ST_DumpPoints(n.geom)).* as geom FROM (	SELECT A.mzaid as mzaid, A.geom as geom FROM validaciones.manzana_sin_seccion_p1_102 as A UNION SELECT A.mzaid as mzaid, A.geom as geom FROM validaciones.manzana_sin_seccion_p2_102 as A UNION SELECT A.mzaid as mzaid, A.geom as geom FROM validaciones.manzana_sin_seccion_p3_102 as A ) n ) o'
			LOOP
				id_mza := resul_val.id;
				x_err := resul_val.x;
				y_err := resul_val.y;
				RETURN NEXT;
			END LOOP;
		ELSE
				id_mza := 0;
				x_err := 0;
				y_err := 0;
			RETURN NEXT;
		END IF;		
	ELSE
			id_mza := 0;
			x_err := 0;
			y_err := 0;
		RETURN NEXT;
  	END IF;
	
	EXCEPTION WHEN OTHERS THEN
  		GET STACKED DIAGNOSTICS errnumber = RETURNED_SQLSTATE;
		GET STACKED DIAGNOSTICS err_context = PG_EXCEPTION_CONTEXT;
		IF errnumber = '42703' THEN
			id_mza := 0;
			x_err := 0;
			y_err := 0;
			RETURN NEXT;
		END IF;
END;

$$;
-- ddl-end --
ALTER FUNCTION validaciones.manzanas_fuera_localidad() OWNER TO postgres;
-- ddl-end --
COMMENT ON FUNCTION validaciones.manzanas_fuera_localidad() IS E'JLMM Function Version 0.0.1.4';
-- ddl-end --

-- object: validaciones.manzana_sin_colonia_101 | type: TABLE --
-- DROP TABLE IF EXISTS validaciones.manzana_sin_colonia_101 CASCADE;
CREATE TABLE validaciones.manzana_sin_colonia_101 (
	id integer,
	geom public.geometry,
	idpk integer NOT NULL DEFAULT nextval('validaciones.manzana_sin_colonia_101_idpk_seq'::regclass),
	CONSTRAINT manzana_sin_colonia_101_pkey PRIMARY KEY (idpk)

);
-- ddl-end --
ALTER TABLE validaciones.manzana_sin_colonia_101 OWNER TO postgres;
-- ddl-end --

-- object: validaciones.manzanas_fuera_colonia | type: FUNCTION --
-- DROP FUNCTION IF EXISTS validaciones.manzanas_fuera_colonia() CASCADE;
CREATE FUNCTION validaciones.manzanas_fuera_colonia ()
	RETURNS TABLE ( id_mza bigint,  x_err double precision,  y_err double precision)
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	ROWS 30000
	AS $$

DECLARE
	errnumber text;
	resul_val record;
	err_context text;
	filter_val record;
	filter_mpio int;
BEGIN
	IF EXISTS (SELECT * FROM information_schema.tables WHERE table_schema = 'bged' AND table_name = 'manzana') THEN
		IF EXISTS (SELECT * FROM information_schema.tables WHERE table_schema = 'bged' AND table_name = 'colonia_a') THEN		
			EXECUTE 'TRUNCATE TABLE validaciones.manzana_sin_colonia_101';
			FOR filter_val IN EXECUTE 'SELECT municipio from bged.municipio'
			LOOP
				filter_mpio := filter_val.municipio;			
				EXECUTE 'INSERT INTO validaciones.manzana_sin_colonia_101(id, geom) SELECT C.id,C.geom FROM bged.manzana as C WHERE id NOT IN ( SELECT distinct A.id FROM bged.colonia_a as B, bged.manzana as A WHERE st_intersects(B.geom, A.geom) and A.municipio = '|| filter_mpio ||' and B.municipio = '|| filter_mpio ||' ) AND C.municipio = '|| filter_mpio ||' order by id';
				RETURN NEXT;
			END LOOP;						
			FOR resul_val IN EXECUTE 'SELECT o.id, ST_X(o.geom) as x, ST_Y(o.geom) as y FROM ( SELECT n.mzaid as id,(ST_DumpPoints(n.geom)).* as geom FROM ( SELECT DISTINCT A.id as mzaid, A.geom as geom FROM validaciones.manzana_sin_colonia_101 as A ) n ) o'
			LOOP
				id_mza := resul_val.id;
				x_err := resul_val.x;
				y_err := resul_val.y;
				RETURN NEXT;
			END LOOP;
		ELSE
				id_mza := 0;
				x_err := 0;
				y_err := 0;
			RETURN NEXT;
		END IF;		
	ELSE
			id_mza := 0;
			x_err := 0;
			y_err := 0;
		RETURN NEXT;
  	END IF;
	
	EXCEPTION WHEN OTHERS THEN
  		GET STACKED DIAGNOSTICS errnumber = RETURNED_SQLSTATE;
		GET STACKED DIAGNOSTICS err_context = PG_EXCEPTION_CONTEXT;
		IF errnumber = '42703' THEN
			id_mza := 0;
			x_err := 0;
			y_err := 0;
			RETURN NEXT;
		END IF;
END;

$$;
-- ddl-end --
ALTER FUNCTION validaciones.manzanas_fuera_colonia() OWNER TO postgres;
-- ddl-end --
COMMENT ON FUNCTION validaciones.manzanas_fuera_colonia() IS E'JLMM Function Version 0.0.1.4';
-- ddl-end --

-- -- object: public.geometry | type: TYPE --
-- -- DROP TYPE IF EXISTS public.geometry CASCADE;
-- CREATE TYPE public.geometry;
-- -- ddl-end --
-- 
-- object: grant_17974d1136 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER
   ON TABLE app.control
   TO postgres;
-- ddl-end --

-- object: grant_8e13b46fdc | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER
   ON TABLE app.control
   TO "joseluis.machado";
-- ddl-end --

-- object: grant_e3b9e1a22f | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER
   ON TABLE app.proceso_remesa
   TO postgres;
-- ddl-end --

-- object: grant_d527611b8f | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER
   ON TABLE app.proceso_remesa
   TO "joseluis.machado";
-- ddl-end --


