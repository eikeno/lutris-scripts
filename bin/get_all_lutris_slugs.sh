#!/bin/bash
# List all games slugs stored in Lutris' DB.
# depends : sqlite3

LUTRIS_DBFILE="$HOME/.local/share/lutris/pga.db"

(
sqlite3 "$LUTRIS_DBFILE" << EOT
SELECT slug FROM games;
EOT
) | sort | uniq
