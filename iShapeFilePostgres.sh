#script para importar masivamente archivos shapefile a base de datos postgres
# 27/01/2021 autor: Alejandro Sandoval Rodriguez
#!/bin/bash
DIRSHAPEFILE=""
for x in {01..32}
do
if [ $x -eq 03 ]  [ $x -eq 26 ];
       then
       #ZERO=0
       #NUM=$ZERO$x
       DBNAME="bged$x"
       psql -U postgres -c "create database $DBNAME"
       psql  -U postgres  -d "$DBNAME" -c "create schema bged"
       psql  -U postgres  -d "$DBNAME" -c "create extension postgis"
       DIRSHAPEFILE=`ls /home/alejo/Documentos/NACIONAL_201944/"$x"_BGD_2019_44/SHAPEFILE-PDA/CARTO_GABINETE/DTTO/*.shp`
       for i in $DIRSHAPEFILE; do
       NAMEFILE="${i##*/}"
       NAMESINEXTENSION="${NAMEFILE%.shp}"
       NAMETABLE="${NAMESINEXTENSION#[0][$x]}"
       shp2pgsql -s 32612 -d  -W "latin1" $i bged."$NAMETABLE" | psql -U postgres -d "$DBNAME";
       done
         elif [ $x -eq 01 ] || [ $x -eq 06 ] || [ $x -eq 08 ] || [ $x -eq 10 ] || [ $x -eq 14 ] || [ $x -eq 18 ] || [ $x -eq 25 ] || [ $x -eq 32 ]
	    then
             DBNAME="bged$x"
             DIRSHAPEFILE=`ls /home/alejo/Documentos/NACIONAL_201944/"$x"_BGD_2019_44/SHAPEFILE-PDA/CARTO_GABINETE/DTTO/*.shp`
             psql -U postgres -c "create database $DBNAME"
             psql  -U postgres  -d "$DBNAME" -c "create schema bged"
             psql  -U postgres  -d "$DBNAME" -c "create extension postgis"
             for i in $DIRSHAPEFILE; do
             NAMEFILE="${i##*/}"
             NAMESINEXTENSION="${NAMEFILE%.shp}"
             NAMETABLE="${NAMESINEXTENSION#[$x][$x]}"
             shp2pgsql -s 32613 -d  -W "latin1" $i bged."$NAMETABLE" | psql -U postgres -d "$DBNAME";
            done
             elif [ $x -eq 04 ] || [ $x -eq 07 ] || [ $x -eq 27 ]
             then
	     DBNAME="bged$x"
             DIRSHAPEFILE=`ls /home/alejo/Documentos/NACIONAL_201944/"$x"_BGD_2019_44/SHAPEFILE-PDA/CARTO_GABINETE/DTTO/*.shp`
             psql -U postgres -c "create database $DBNAME"
             psql  -U postgres  -d "$DBNAME" -c "create schema bged"
             psql  -U postgres  -d "$DBNAME" -c "create extension postgis"
             for i in $DIRSHAPEFILE; do
             NAMEFILE="${i##*/}"
             NAMESINEXTENSION="${NAMEFILE%.shp}"
             NAMETABLE="${NAMESINEXTENSION#[$x][$x]}"
             shp2pgsql -s 32615 -d  -W "latin1" $i bged."$NAMETABLE" | psql -U postgres -d "$DBNAME";
             done
             elif [ $x -eq 23 ] || [ $x -eq 31 ]
             then
	     DBNAME="bged$x"
             DIRSHAPEFILE=`ls /home/alejo/Documentos/NACIONAL_201944/"$x"_BGD_2019_44/SHAPEFILE-PDA/CARTO_GABINETE/DTTO/*.shp`
             psql -U postgres -c "create database $DBNAME"
             psql  -U postgres  -d "$DBNAME" -c "create schema bged"
             psql  -U postgres  -d "$DBNAME" -c "create extension postgis"
             for i in $DIRSHAPEFILE; do
             NAMEFILE="${i##*/}"
             NAMESINEXTENSION="${NAMEFILE%.shp}"
             NAMETABLE="${NAMESINEXTENSION#[$x][$x]}"
             shp2pgsql -s 32616 -d  -W "latin1" $i bged."$NAMETABLE" | psql -U postgres -d "$DBNAME";
             done
             elif [ $x -eq 02 ]
	     then
	     DBNAME="bged$x"
             DIRSHAPEFILE=`ls /home/alejo/Documentos/NACIONAL_201944/"$x"_BGD_2019_44/SHAPEFILE-PDA/CARTO_GABINETE/DTTO/*.shp`
             psql -U postgres -c "create database $DBNAME"
             psql  -U postgres  -d "$DBNAME" -c "create schema bged"
             psql  -U postgres  -d "$DBNAME" -c "create extension postgis"
             for i in $DIRSHAPEFILE; do
             NAMEFILE="${i##*/}"
             NAMESINEXTENSION="${NAMEFILE%.shp}"
             NAMETABLE="${NAMESINEXTENSION#[$x][$x]}"
             shp2pgsql -s 32611 -d  -W "latin1" $i bged."$NAMETABLE" | psql -U postgres -d "$DBNAME";
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
             shp2pgsql -s 32614 -d  -W "latin1" $i bged."$NAMETABLE" | psql -U postgres -d "$DBNAME";
             done
fi;
done

