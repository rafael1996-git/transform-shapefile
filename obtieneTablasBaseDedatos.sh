#Script para obtener las tablas de cada base de datos autor:Alejandro Sandoval Rodriguez
#!/bin/bash
for x in {01..32}
do
  DBNAME="bged$x"
 echo "$DBNAME"
psql  -U postgres  -d "$DBNAME" -c "copy(SELECT table_name,table_schema FROM information_schema.tables where table_schema='bged') to '/home/alejo/Documentos/tablasbged$x.csv' delimiter ';'  CSV HEADER;"
done
