#!/bin/bash
# Extract gamedir from wine prefix if installed to C:\
# This is to allow using symlink to a shared prefix instead of having 
# a full wine prefix per game; that ends up taking significan space.
# shellcheck disable=SC2012

root=$(pwd)
echo "root: $root"

find -maxdepth 4 -type d -name "GOG Games" | while read d; do 
	pushd "$(dirname "$d")" || exit
	mv -- "./GOG Games"/* && rmdir "./GOG Games"/
done

move_gamedir_to_wineroot.sh
exit $?
