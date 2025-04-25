#!/bin/bash
# Prepares a series of game folders for later batch import into lutris, regardless of tree depth
# relies on the presence of .exe - gives choice if needed

WD="$(dirname "${BASH_SOURCE[0]}")"
echo ">> $0 starting"
if [ "$GOG" = "1" ]; then
	find "$(pwd)" -maxdepth 1 -mindepth 1 -type d -exec "$WD/game_prep_export_GOG.lib" "{}" \;
else
	find "$(pwd)" -maxdepth 1 -mindepth 1 -type d -exec "$WD/game_prep_export.lib" "{}" \;
fi
echo ">> $0 ending."
