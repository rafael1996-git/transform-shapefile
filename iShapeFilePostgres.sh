#script para importar masivamente archivos shapefile a base de datos postgres
# 27/01/2021 autor: Alejandro Sandoval Rodriguez
#!/bin/bash
DIRSHAPEFILE=""
for x in {1..2}
do
if [ $x -le 9 ];
       then
       ZERO=0
       NUM=$ZERO$x
       DBNAME="bged$NUM"
       psql -U postgres -c "create database $DBNAME"
       psql  -U postgres  -d "$DBNAME" -c "create schema bged"
       psql  -U postgres  -d "$DBNAME" -c "create extension postgis"
       DIRSHAPEFILE=`ls /home/alejo/Documentos/NACIONAL_201944/"$NUM"_BGD_2019_44/SHAPEFILE-PDA/CARTO_GABINETE/DTTO/*.shp`
       for i in $DIRSHAPEFILE; do
       NAMEFILE="${i##*/}"
       NAMESINEXTENSION="${NAMEFILE%.shp}"
       NAMETABLE="${NAMESINEXTENSION#[0][$x]}"
       shp2pgsql -d  -W "latin1" $i bged."$NAMETABLE" | psql -U postgres -d "$DBNAME";
       done
       else
             DBNAME="bged$x"
             DIRSHAPEFILE=`ls /home/alejo/Documentos/NACIONAL_201944/"$x"_BGD_2019_44/SHAPEFILE-PDA/CARTO_GABINETE/DTTO/*.shp`
             psql -U postgres -c "create database $DBNAME"
             psql  -U postgres  -d "$DBNAME" -c "create schema bged"
             psql  -U postgres  -d "$DBNAME" -c "create extension postgis"
             for i in $DIRSHAPEFILE; do
             NAMEFILE="${i##*/}"
             NAMESINEXTENSION="${NAMEFILE%.shp}"
             NAMETABLE="${NAMESINEXTENSION#[$x][$x]}"
             shp2pgsql -d  -W "latin1" $i bged."$NAMETABLE" | psql -U postgres -d "$DBNAME";
             done
fi;
done

