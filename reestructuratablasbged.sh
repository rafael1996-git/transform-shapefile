#!/bin/bash
for x in {01..32}
do
  DBNAME="bged$x"
 echo "$DBNAME"
# psql -U postgres -d "$DBNAME" -c "create extension dblink"
# psql  -U postgres  -d "$DBNAME" -c "Select * from  dblink('dbname="$DBNAME" host=172.19.71.161 user=postgres password=postgres','SELECT table_name,table_schema FROM information_schema.tables ') as (table_name varchar,table_schema varchar) where table_schema='bged'"

psql -U postgres -d "$DBNAME" -c "copy (select distinct 'drop table IF EXISTS '||table_schema||'.'||table_name||';' from information_schema.columns where table_schema='bged' and table_name='colonia_puntual_linea') to '/var/lib/pgsql/reestructuracionbged/droptablecoloniapuntuallinea$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select distinct 'drop table IF EXISTS '||table_schema||'.'||table_name||';' from information_schema.columns where table_schema='bged' and table_name='colonia_puntual_area') to '/var/lib/pgsql/reestructuracionbged/droptablecoloniapuntualarea$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select distinct 'alter table '||table_schema||'.'||table_name||' rename to colonia_puntual;' from information_schema.columns where table_schema='bged'
and table_name='colonia_puntual_punto') to '/var/lib/pgsql/reestructuracionbged/renametablacoloniapuntualpunto$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select distinct 'alter table '||table_schema||'.'||table_name||' rename to colonia_a;' from information_schema.columns where table_schema='bged'
and table_name='colonia_area') to '/var/lib/pgsql/reestructuracionbged/renametablacoloniaa$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select distinct 'alter table '||table_schema||'.'||table_name||' rename to colonia_l;' from information_schema.columns where table_schema='bged'
and table_name='colonia_linea') to '/var/lib/pgsql/reestructuracionbged/renametablacolonial$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select distinct 'alter table '||table_schema||'.'||table_name||' rename to colonia_p;' from information_schema.columns where table_schema='bged' and table_name='colonia_punto') to '/var/lib/pgsql/reestructuracionbged/renametablacoloniap$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select distinct 'alter table '||table_schema||'.'||table_name||' rename to hidrografia_a;' from information_schema.columns where table_schema='bged'
and table_name='hidrografia_area') to '/var/lib/pgsql/reestructuracionbged/renametablahidrografiaa$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select distinct 'alter table '||table_schema||'.'||table_name||' rename to hidrografia_l;' from information_schema.columns where table_schema='bged'
and table_name='hidrografia_linea') to '/var/lib/pgsql/reestructuracionbged/renametablahidrografial$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select distinct 'alter table '||table_schema||'.'||table_name||' rename to hidrografia_p;' from information_schema.columns where table_schema='bged'
and table_name='hidrografia_punto') to '/var/lib/pgsql/reestructuracionbged/renametablahidrografiap$x.sql';"


psql -U postgres -d "$DBNAME" -c "copy (select distinct 'alter table '||table_schema||'.'||table_name||' rename to linea_metro_p;' from information_schema.columns where table_schema='bged'
and table_name='linea_metro_punto') to '/var/lib/pgsql/reestructuracionbged/renametablalineametrop$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select distinct 'alter table '||table_schema||'.'||table_name||' rename to linea_metro_a;' from information_schema.columns where table_schema='bged'
and table_name='linea_metro_area') to '/var/lib/pgsql/reestructuracionbged/renametablalineametroa$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select distinct 'alter table '||table_schema||'.'||table_name||' rename to linea_metro_l;' from information_schema.columns where table_schema='bged'
and table_name='linea_metro_linea') to '/var/lib/pgsql/reestructuracionbged/renametablalineametrol$x.sql';"


psql -U postgres -d "$DBNAME" -c "copy (select distinct 'alter table '||table_schema||'.'||table_name||' rename to ferrocarril_l;' from information_schema.columns where table_schema='bged'
and table_name='ferrocarril_linea') to '/var/lib/pgsql/reestructuracionbged/renametablaferrocarrill$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select distinct 'alter table '||table_schema||'.'||table_name||' rename to ferrocarril_a;' from information_schema.columns where table_schema='bged'
and table_name='ferrocarril_area') to '/var/lib/pgsql/reestructuracionbged/renametablaferrocarrila$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select distinct 'alter table '||table_schema||'.'||table_name||' rename to ferrocarril_p;' from information_schema.columns where table_schema='bged'
and table_name='ferrocarril_punto') to '/var/lib/pgsql/reestructuracionbged/renametablaferrocarrilp$x.sql';"


psql -U postgres -d "$DBNAME" -c "copy (select distinct 'alter table '||table_schema||'.'||table_name||' rename to rasgo_complementario_p;' from information_schema.columns where table_schema='bged' and table_name='rasgo_complementario_punto') to '/var/lib/pgsql/reestructuracionbged/renametablarasgocomplementariop$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select distinct 'alter table '||table_schema||'.'||table_name||' rename to rasgo_complementario_a;' from information_schema.columns where table_schema='bged' and table_name='rasgo_complementario_area') to '/var/lib/pgsql/reestructuracionbged/renametablarasgocomplementarioa$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select distinct 'alter table '||table_schema||'.'||table_name||' rename to rasgo_complementario_l;' from information_schema.columns where table_schema='bged' and table_name='rasgo_complementario_linea') to '/var/lib/pgsql/reestructuracionbged/renametablarasgocomplementariol$x.sql';"


psql -U postgres -d "$DBNAME" -c "copy (select distinct 'alter table '||table_schema||'.'||table_name||' rename to curva_nivel_a;' from information_schema.columns where table_schema='bged'
and table_name='curva_nivel_area') to '/var/lib/pgsql/reestructuracionbged/renametablacurvalineala$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select distinct 'alter table '||table_schema||'.'||table_name||' rename to curva_nivel_p;' from information_schema.columns where table_schema='bged'
and table_name='curva_nivel_punto') to '/var/lib/pgsql/reestructuracionbged/renametablacurvalinealp$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select distinct 'alter table '||table_schema||'.'||table_name||' rename to curva_nivel_l;' from information_schema.columns where table_schema='bged'
and table_name='curva_nivel_linea') to '/var/lib/pgsql/reestructuracionbged/renametablacurvalineall$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' drop column '||column_name||';' from information_schema.columns where table_schema='bged'
and column_name='gmrotation' order by column_name) To '/var/lib/pgsql/reestructuracionbged/droptablegmrotation$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' drop column '||column_name||';' from information_schema.columns where table_schema='bged'
and column_name='gid' order by column_name) To '/var/lib/pgsql/reestructuracionbged/droptablegid$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' drop column '||column_name||';' from information_schema.columns where table_schema='bged'
and column_name='geometry1_' order by column_name) To '/var/lib/pgsql/reestructuracionbged/droptablegeometry1_$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' drop column '||column_name||';' from information_schema.columns where table_schema='bged'
and column_name='geometry2_' order by column_name) To '/var/lib/pgsql/reestructuracionbged/droptablegeometry2_$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' drop column '||column_name||';' from information_schema.columns where table_schema='bged'
and column_name='geometry_s' order by column_name) To '/var/lib/pgsql/reestructuracionbged/droptablegeometry_s$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' alter column '||column_name||' set data type Integer;' from information_schema.columns where table_schema='bged' and column_name='control' order by column_name) to '/var/lib/pgsql/reestructuracionbged/tipodatocontrol$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' alter column '||column_name||' set data type Integer;' from information_schema.columns
where table_schema='bged' and column_name='id' order by column_name) to '/var/lib/pgsql/reestructuracionbged/tipodatoid$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' alter column '||column_name||' set data type Integer;' from information_schema.columns
where table_schema='bged' and column_name='tipo' order by column_name) to '/var/lib/pgsql/reestructuracionbged/tipodatotipo$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' alter column '||column_name||' set data type Integer;' from information_schema.columns
where table_schema='bged' and column_name='entidad' order by column_name) to '/var/lib/pgsql/reestructuracionbged/tipodatoentidad$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' alter column '||column_name||' set data type Integer;' from information_schema.columns
where table_schema='bged' and column_name='seccion' order by column_name) to '/var/lib/pgsql/reestructuracionbged/tipodatoseccion$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' alter column '||column_name||' set data type Integer;' from information_schema.columns
where table_schema='bged' and column_name='localidad' order by column_name) to '/var/lib/pgsql/reestructuracionbged/tipodatolocalidad$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' alter column '||column_name||' set data type Integer;' from information_schema.columns
where table_schema='bged' and column_name='manzana' order by column_name) to '/var/lib/pgsql/reestructuracionbged/tipodatomanzana$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' alter column '||column_name||' set data type Integer;' from information_schema.columns
where table_schema='bged' and column_name='municipio' order by column_name) to '/var/lib/pgsql/reestructuracionbged/tipodatomunicipio$x.sql';"


psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' alter column '||column_name||' set data type bigint;' from information_schema.columns
where table_schema='bged' and column_name='cp' order by column_name) to '/var/lib/pgsql/reestructuracionbged/tipodatocp$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' alter column '||column_name||' set data type bigint;' from information_schema.columns
where table_schema='bged' and column_name='cod_postal' order by column_name) to '/var/lib/pgsql/reestructuracionbged/tipodatocdopostal$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' alter column '||column_name||' set data type bigint;' from information_schema.columns
where table_schema='bged' and column_name='cod_postal' order by column_name) to '/var/lib/pgsql/reestructuracionbged/tipodatomodulo$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' alter column '||column_name||' set data type bigint;' from information_schema.columns
where table_schema='bged' and column_name='tramo' order by column_name) to '/var/lib/pgsql/reestructuracionbged/tipodatotramo$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' alter column '||column_name||' set data type Integer;' from information_schema.columns
where table_schema='bged' and column_name='pro' order by column_name) to '/var/lib/pgsql/reestructuracionbged/tipodatopro$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' alter column '||column_name||' set data type Integer;' from information_schema.columns
where table_schema='bged' and column_name='vialidad' order by column_name) to '/var/lib/pgsql/reestructuracionbged/tipodatovialidad$x.sql';"


psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' rename column '||column_name||' to velocidad_promedio;' from information_schema.columns
where table_schema='bged' and column_name='velocidad_' order by column_name) to '/var/lib/pgsql/reestructuracionbged/renamevelocidad$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' rename column '||column_name||' to clasificacion;' from information_schema.columns
where table_schema='bged' and column_name='clasificac' order by column_name) to '/var/lib/pgsql/reestructuracionbged/renameclasific$x.sql';"


psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' rename column '||column_name||' to localidad;' from information_schema.columns
where table_schema='bged' and column_name='localidad_' order by column_name) to '/var/lib/pgsql/reestructuracionbged/renamelocalidad_$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' rename column '||column_name||' to localidad_nombre; ' from information_schema.columns
where table_schema='bged' and column_name='localidad___4' order by column_name) to '/var/lib/pgsql/reestructuracionbged/renamelocadidad_4$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' rename column '||column_name||' to altitud_snm; ' from information_schema.columns
where table_schema='bged' and column_name='altitud_sn' order by column_name) to '/var/lib/pgsql/reestructuracionbged/renamealtitud$x.sql';"


psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' rename column '||column_name||' to circunscripcion; ' from information_schema.columns
where table_schema='bged' and column_name='circunscri' order by column_name) to '/var/lib/pgsql/reestructuracionbged/renamecircuscripcion$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' rename column '||column_name||' to nombre_estacion; ' from information_schema.columns
where table_schema='bged' and column_name='nombre_est' order by column_name) to '/var/lib/pgsql/reestructuracionbged/renamenombreestacion$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' rename column '||column_name||' to observaciones; ' from information_schema.columns
where table_schema='bged' and column_name='observacio' order by column_name) to '/var/lib/pgsql/reestructuracionbged/renameobservaciones$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' rename column '||column_name||' to nombre_mancha_urbana; ' from information_schema.columns
where table_schema='bged' and column_name='nombre_man' order by column_name) to '/var/lib/pgsql/reestructuracionbged/renamemanchaurbana$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy(select 'alter table '||table_schema||'.'||table_name||' rename column '||column_name||' to dias_atencion; ' from information_schema.columns
where table_schema='bged' and column_name='dias_atenc' order by column_name) to '/var/lib/pgsql/reestructuracionbged/renamediasatencion$x.sql';"


psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' rename column '||column_name||' to caso_captura; ' from information_schema.columns
where table_schema='bged' and column_name='caso_captu' order by column_name) to '/var/lib/pgsql/reestructuracionbged/renamenombrecaptura$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' rename column '||column_name||' to vocal_nombre; ' from information_schema.columns
where table_schema='bged' and column_name='vocal_nomb' order by column_name) to '/var/lib/pgsql/reestructuracionbged/renamevocalnombre$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' rename column '||column_name||' to calle_y_no_ext; ' from information_schema.columns
where table_schema='bged' and column_name='calle_y_no' order by column_name) to '/var/lib/pgsql/reestructuracionbged/renamecallenumexte$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' rename column '||column_name||' to localidad_nombre; ' from information_schema.columns
where table_schema='bged' and column_name='localidad___6') to '/var/lib/pgsql/reestructuracionbged/renamelocalida6$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' rename column '||column_name||' to localidad_nombre; ' from information_schema.columns
where table_schema='bged' and column_name='localidad___7') to '/var/lib/pgsql/reestructuracionbged/renamelocalida7$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' rename column '||column_name||' to distrito_local; ' from information_schema.columns
where table_schema='bged' and column_name='distrito_l' order by column_name) to '/var/lib/pgsql/reestructuracionbged/renamedistritolocal$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' rename column '||column_name||' to descripcion; ' from information_schema.columns
where table_schema='bged' and column_name='descripcio' order by column_name) to '/var/lib/pgsql/reestructuracionbged/renamedescripcion$x.sql';"

psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' add constraint '||table_name||'_pkey primary key ('||column_name||');' from information_schema.columns where table_schema='bged' and column_name='id' order by column_name) to '/var/lib/pgsql/reestructuracionbged/llavesprimariaid$x.sql';"


#para borrar todas las primary key que existen en las bases de datos
#psql -U postgres -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' DROP CONSTRAINT '||constraint_name||';' from information_schema.table_constraints where table_schema='bged' and constraint_schema='bged' and constraint_type='PRIMARY KEY') To '/var/lib/pgsql/dropprimarykey$x.sql';"

done

for x in {01..32}
do
 DBNAME="bged$x"
echo "$DBNAME realizando alter a la bases de datos"
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/droptablecoloniapuntualarea$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/droptablecoloniapuntuallinea$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renametablacoloniapuntualpunto$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renametablacoloniaa$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renametablacoloniap$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renametablacolonial$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renametablahidrografiaa$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renametablahidrografiap$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renametablahidrografial$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renametablalineametrop$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renametablalineametroa$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renametablalineametrol$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renametablaferrocarrila$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renametablaferrocarrilp$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renametablaferrocarrill$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renametablarasgocomplementariop$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renametablarasgocomplementarioa$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renametablarasgocomplementariol$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renametablacurvalineala$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renametablacurvalinealp$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renametablacurvalineall$x.sql

psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/droptablegmrotation$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/droptablegid$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/droptablegeometry1_$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/droptablegeometry2_$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/droptablegeometry_s$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/tipodatocontrol$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/tipodatoid$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/tipodatotipo$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/tipodatoentidad$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/tipodatoseccion$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/tipodatolocalidad$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/tipodatomanzana$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/tipodatomunicipio$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/tipodatocp$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/tipodatocdopostal$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/tipodatomodulo$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/tipodatotramo$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/tipodatopro$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/tipodatovialidad$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renamevelocidad$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renameclasific$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renamelocalidad_$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renamelocadidad_4$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renamealtitud$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renamecircuscripcion$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renamenombreestacion$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renameobservaciones$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renamemanchaurbana$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renamediasatencion$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renamenombrecaptura$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renamevocalnombre$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renamecallenumexte$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renamelocalida6$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renamelocalida7$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renamedistritolocal$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/renamedescripcion$x.sql
psql -U postgres -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/llavesprimariaid$x.sql

done
