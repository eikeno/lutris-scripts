#!/bin/bash
# depends: wine-dirname2lutris_slug.sh
# depends: winedir2lutris.sh
if [[ $# == 0 ]]; then
	echo "usage: add_to_lutris.sh LUTRIS"
	echo "LUTRIS file must contains relative path to exe"
	exit 1
fi

if [[ ! -e "$1" ]]; then
	echo "no $1 file found, please check"
	exit 2
fi

if [[ -e ".lutris_added" ]]; then
	echo "Already added to LUTRIS. Skipping."
	exit 0
else
	winedir2lutris.sh \
		"$(wine-dirname2lutris_slug.sh)" \
		"$(<"$1")" && \
	touch "${1/LUTRIS/.lutris_added}"
fi

echo "# <<<<< $0"

