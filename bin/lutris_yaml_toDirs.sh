#!/bin/bash
# Force use of "first letter" subdirectories for LUTRIS config (yaml) files.
echo ">> Starting $0"

# FIXME: make this overridable via env vars or conf file:
LUTRIS_GAMEDIR="$HOME/.local/share/lutris/games"
pushd "$LUTRIS_GAMEDIR" || exit

for i in {a..z} {0..9}; do
	echo -n "$i"
	mkdir -p "$LUTRIS_GAMEDIR/$i"
	mv "$LUTRIS_GAMEDIR/$i"*".yml" "$LUTRIS_GAMEDIR/$i/" 2> /dev/null
	echo ": done"
done

echo "<< Ending: $0"
exit 0
