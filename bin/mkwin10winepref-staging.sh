#!/bin/bash
CMD='rsync -avP /storage/GAMES_MASTER/LUTRIS/SHARED_PREFIXES/WIN10_STAGING_WAYLAND WINE'

if [ -n "$1" ]; then
	pushd "$@" || exit
	$CMD
	popd || exit
else
	$CMD
fi

