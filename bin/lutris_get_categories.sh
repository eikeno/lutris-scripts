#!/bin/bash
# $@ : optional category_name
# Report id and name of each game categories.
# If a category_name is passed, only this one will be shown.
# depends : sqlite3

[ -n "$2" ] && echo "$0 'optional catgeory name'" && exit 2

LUTRIS_DBFILE="$HOME/.local/share/lutris/pga.db"
[ ! -e "$LUTRIS_DBFILE" ] && echo "pga.db not found at $LUTRIS_DBFILE" && exit 3

[ -n "$1" ] && WHERE_CLAUSE="WHERE name='$1'"

sqlite3 "$LUTRIS_DBFILE" << EOT
SELECT id, name FROM categories $WHERE_CLAUSE;
EOT
