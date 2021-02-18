#Script para importar shapeFile a postgres con la restructuracion de todas las tablas de las 32 bases de datos bged
#autor: Alejandro Sandoval Rodriguez
#!/bin/bash
echo "Inicia proceso de base de datos bged"
#elimina base de datos
/var/lib/pgsql/./dropdatabasebged.sh
psql -U postgres -d postgres -f /var/lib/pgsql/reestructuracionbged/dropdatabase.sql

#importar shapefile y reestructuracion de bases de datos
sh iShPostgres.sh
sleep 2h 20m
/var/lib/pgsql/./queryDblink.sh

