#!/bin/bash
# Extract gamedir from wine prefix if installed to C:\
# This is to allow using symlink to a shared prefix instead of having 
# a full wine prefix per game; that ends up taking significan space.
# shellcheck disable=SC2012

root=$(pwd)
echo "root: $root"
ls -1 | while read -r dir; do
	echo 
	echo "dir: $dir"
	(
	pushd "$root/$dir/WINE/drive_c" &>/dev/null || exit

		ls -1 | while read -r sub; do
			#echo "sub: $sub"
			if [ "$sub" == "ProgramData" ]; then continue; fi
			if [ "$sub" == "Program Files" ]; then continue; fi
			if [ "$sub" == "Program Files (x86)" ]; then continue; fi
			if [ "$sub" == "users" ]; then continue; fi
			if [ "$sub" == "windows" ]; then continue; fi
			
			echo "mv $sub $root/$dir"
			mv "$sub/" "$root/$dir/"
			echo $?
		
		done

	popd &>/dev/null || exit
	)

done
