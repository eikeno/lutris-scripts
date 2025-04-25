#!/bin/bash
# Check all yaml config file and report those not matching any
# game in Lutris' DB, or more than 1.
# shellcheck disable=SC2001
# depends : sqlite3

LUTRIS_DBFILE="$HOME/.local/share/lutris/pga.db"
LUTRIS_GAMES_DIR="$HOME/.local/share/lutris/games"


function get_games_by_configpath {
sqlite3 "$LUTRIS_DBFILE" << EOT
SELECT id FROM games WHERE configpath='$1';
EOT

}

# the remaining with exe bit set are orphans, can be deleted manually:
find "$LUTRIS_GAMES_DIR" -type f -name "*.yml" | while read -r yaml; do
	configpath=$(basename "$yaml" .yml)
	slug=$(echo "$configpath" | sed  's/\-[[:digit:]]\{10\}$//g')
	matches=$(get_games_by_configpath "$configpath")
	count=$(echo "$matches" | wc -l)

	if [ "$count" -gt 1 ]; then
		echo "WARN	multi matches -- yaml:$yaml; slug:$slug; matches(lutris IDs): $matches"
	elif [ "$count" -eq 0 ]; then
		echo "WARN	zero match -- yaml:$yaml; slug:$slug;"
		chmod 744 "$yaml"

	else
		echo "OK	one match found -- yaml:$yaml; slug:$slug;"
	fi
done

exit 0
