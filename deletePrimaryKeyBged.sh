#eliminar todas las primary key de las bases de datos autor:Alejandro Sandoval Rodriguez 
#!/bin/bash
for x in {01..32}
do
  DBNAME="bged$x"
 echo "$DBNAME"
psql  -U postgres  -d "$DBNAME" -c "copy (select 'alter table '||table_schema||'.'||table_name||' DROP CONSTRAINT '||constraint_name||';' from information_schema.table_constraints where table_schema='bged' and constraint_schema='bged' and constraint_type='PRIMARY KEY' ) To '/var/lib/pgsql/reestructuracionbged/dropprimarykey$x.sql'"
done

for x in {01..32}
do
  DBNAME="bged$x"
  psql -d "$DBNAME" -f /var/lib/pgsql/reestructuracionbged/dropprimarykey$x.sql
done
