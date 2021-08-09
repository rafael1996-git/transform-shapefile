#!/bin/bash
for x in {01..04}
do
 if [ $x -eq 02 ] || [ $x -eq 03 ];
then
echo "aqui son iguales $x"
else
	echo "no son iguales $x"
fi;
done

