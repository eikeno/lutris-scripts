#!/bin/bash
# List game folders in working directory without LUTRIS or start.sh files.

find . -type d -mindepth 2 -maxdepth 2 | while read -r d; do
	\pushd "$d" &>/dev/null || exit
	unset TAG
	TAG=0
	[ -e "LUTRIS" ] && (( TAG++ ))
	[ -e "start.sh" ] && (( TAG++ ))
	[ "$TAG" -eq 0 ] && echo "$d" && ls
	\popd &>/dev/null || exit
done

