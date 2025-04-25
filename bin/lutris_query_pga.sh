#!/bin/bash
# $@ : SQL QUERY
# depends : sqlite3

LUTRIS_DBFILE="$HOME/.local/share/lutris/pga.db"
[ ! -e "$LUTRIS_DBFILE" ] && echo "$LUTRIS_DBFILE not found" && exit 1

sqlite3 "$LUTRIS_DBFILE" << EOT
$@
EOT

