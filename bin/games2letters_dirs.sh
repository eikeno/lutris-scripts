#!/bin/bash
# Move game folders in curent working dir to sorted tree, for use with patched Lutris.

for i in A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 0 1 2 3 4 5 6 7 8 9; do
	echo "=========> $i "
	mkdir -p ./$i || exit
	mv ./$i* ./$i
	echo "HC: $?"
	mv ./${i,,}* ./$i 
	echo "LC: $?"
done
