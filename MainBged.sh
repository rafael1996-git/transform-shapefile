#!/bin/bash
echo "Inicia proceso de base de datos bged"
#elimina base de datos
/var/lib/pgsql/./dropdatabasebged.sh
psql -U postgres -d postgres -f /var/lib/pgsql/reestructuracionbged/dropdatabase.sql

#importar shapefile y reestructuracion de bases de datos
sh iShPostgres.sh
/var/lib/pgsql/./queryDblink.sh
