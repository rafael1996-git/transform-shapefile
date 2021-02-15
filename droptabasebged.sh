#Script elimina todas las base de datos que empiezan con bged Autor: Alejandro Sandoval Rodriguez
#!/bin/bash

psql -U postgres -d postgres -c "copy (SELECT 'drop database IF EXISTS '||pg_database.datname||';' FROM pg_database JOIN pg_shadow ON pg_database.datdba = pg_shadow.usesysid where datname like 'bged%' order by pg_database.datname) to '/var/lib/pgsql/reestructuracionbged/dropdatabase.sql';"

