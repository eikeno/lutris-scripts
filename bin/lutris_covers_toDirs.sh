#!/bin/bash
# deprecated, do not use
# mv covers that's be under <dir>/coverarts/ to <dir>/coverarts/n
# Where 'n' is the first character of the filename. To be used with patched Lutris.
# depends : any2jpg.sh

for i in {a..z} {0..9}; do
	echo ">> $i"
	mkdir -p "$i"
	mv "./$i"*.jpg "./$i/" &>/dev/null && echo -n "+"
	( pushd "./$i" || return; any2jpg.sh ; popd || return )
done
