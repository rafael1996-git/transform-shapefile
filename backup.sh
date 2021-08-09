
#!/bin/bash
#Alejandro Sandoval Rodriguez
#script que genera backup masivamente y los comprime con fecha
for x in {01..32}
do
  pg_dump  --attribute-inserts  -U postgres    -f  /home/alejo/Documentos/respaldobged/$(date +%Y-%m-%d)bged$x.sql bged$x
 
  gzip /home/alejo/Documentos/respaldobged/$(date +%Y-%m-%d)bged$x.sql
  echo "Pull Complete"


done

