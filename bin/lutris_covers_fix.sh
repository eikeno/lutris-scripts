#!/bin/bash
# depends : any2jpg.sh

echo ">> starting $0"

for i in {a..z} {0..9}; do

	echo ">> $i"
	pushd "$i" &> /dev/null|| exit
	ls -1 | grep -v ^"$i" | while read -r misplaced; do
		mv "$misplaced" ..
	done

	any2jpg.sh
	echo "OK"
	popd &> /dev/null || exit

done

