#!/bin/bash
# $@ : <game_slug> <category_name>
# shellcheck disable=SC2086
# depends : sqlite3

DATE_S="$(date +%s)"
echo "######################"
echo "current unix time = $DATE_S"

[ -z "$1" ] && echo "$0 GAME_SLUG CATEGORY_NAME" && exit 2

LUTRIS_DBFILE="$HOME/.local/share/lutris/pga.db"
[ ! -e "$HOME/.local/share/lutris/pga.db" ] && echo "pga.db not found at $HOME/.local/share/lutris/pga.db" && exit 3

# get game ID(s) for the given slug
GAME_ID="$(lutris_query_pga.sh SELECT id from games WHERE slug=\"$1\";)"
[ -z "$GAME_ID" ] && echo "GAMEID not found for $1" && exit 10

# get category ID
CAT_NAME="$(lutris_query_pga.sh SELECT id FROM categories WHERE name=\"$2\";)"
if [ -z "$CAT_NAME" ]; then 
	echo "Creating missing category $2..."

sqlite3 "$LUTRIS_DBFILE" << EOT
INSERT OR IGNORE INTO categories (name) VALUES ("$2");
EOT

echo "$?"
fi

sqlite3 "$LUTRIS_DBFILE" << EOT
INSERT OR IGNORE INTO games_categories (game_id, category_id) VALUES ( "$GAME_ID", "$CAT_NAME");
EOT

exit "$?"
