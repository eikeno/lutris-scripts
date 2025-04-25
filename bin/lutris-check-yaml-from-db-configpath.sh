#!/bin/bash
# For each game in Lutris' DB, check a configpath (Yaml config file) is set, and exists.
# grep the result for "RESULT_KO" string to limit verbosity.
# depends : sqlite3

LUTRIS_DBFILE="$HOME/.local/share/lutris/pga.db"
LUTRIS_GAMES_DIR="$HOME/.local/share/lutris/games"

function get_configpath_by_id () {
sqlite3 "$LUTRIS_DBFILE" << EOT
SELECT configpath FROM games WHERE id='$1';
EOT
	
}

function get_slug_from_id () {
sqlite3 "$LUTRIS_DBFILE" << EOT
SELECT slug FROM games WHERE id='$1';
EOT
	
}

function get_all_ids () {
sqlite3 "$LUTRIS_DBFILE" << EOT
SELECT id FROM games;
EOT
	
}


for id in $(get_all_ids); do
	echo -ne "id: $id;"
	slug=$(get_slug_from_id "$id")
	echo -ne "slug: $slug;"
	configpath=$(get_configpath_by_id "$id")
	echo -ne "configpath: $configpath;"
	echo -ne "fullpath: $LUTRIS_GAMES_DIR/$configpath.yml;"
	if [ -r "$LUTRIS_GAMES_DIR/$configpath.yml" ]; then
	echo "RESULT_OK;"
	else
	echo "RESULT_KO;"
	fi
done
