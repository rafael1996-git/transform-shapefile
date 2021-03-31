#Script para importar shapeFile a postgres con la restructuracion de todas las tablas de las 32 bases de datos bged
#autor: Alejandro Sandoval Rodriguez
#!/bin/bash
echo "Inicia proceso de base de datos bged"
#genera un script para eliminar las bases de datos
#/var/lib/pgsql/./dropdatabasebged.sh
sh droptabasebged.sh
#llama un script sql para eliminar las bases de datos
psql -U postgres -d postgres -f /var/lib/pgsql/reestructuracionbged/dropdatabase.sql

#script para importar archivos shapefile a postgres directamente y reestructuracion de bases de datos
sh iShapeFilePostgres.sh
# se agrega un tiempo para que deje que se procese todos los shapefile 
#sleep 1h 20m
sleep 30 m
#/var/lib/pgsql/./reestructuratablasbged.sh
#script para reestructuracion de todas las tablas de las 32 bases de datos
sh reestructuratablasbged.sh

