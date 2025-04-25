#!/bin/bash
# $@ : full game path
DATE_S=$(date +%s)
echo "######################"
echo "current unix time = $DATE_S"

[ -z "$1" ] && echo "$0 GAME_FULL_PATH" && exit 2

auto_category=''
# use ENV VAR for adding to category
[ -n "LUTRIS_ADD_AUTO_CATEGORY" ] && auto_category="$LUTRIS_ADD_AUTO_CATEGORY"

LUTRIS_GAMEDIR="$HOME/.local/share/lutris/games"
LUTRIS_DBFILE="$HOME/.local/share/lutris/pga.db"
[ ! -e "$LUTRIS_DBFILE" ] && echo "pga.db not found at $LUTRIS_DBFILE" && exit 3
GAME_NAME="$(basename "$@" ".cue")"
GAME_NAME="$(basename "$GAME_NAME" ".zip")"

GAME_NAME=$(echo "$GAME_NAME" | sed 's/\!//g' | sed 's/\[\]//g')

echo "GAME_NAME = $GAME_NAME"
SLUG="$(string_to_slug.sh "$GAME_NAME")""-lynx"
SLUG=$(echo "$SLUG" | sed 's/\!//g')
SLUG=$(echo "$SLUG" | sed 's/--/-/g')
SLUG=$(echo "$SLUG" | sed 's/-$//g')

echo "SLUG = $SLUG"

######## game file 
(
cat << EOT
game:
  core: mednafen_lynx
  main_file: $@
libretro: {}
system: {}

EOT
) > $LUTRIS_GAMEDIR/$SLUG-$DATE_S.yml || exit 3

sqlite3 $LUTRIS_DBFILE << EOT
INSERT INTO games (name, slug, platform, runner, installed, installed_at, configpath, playtime, hidden) VALUES ( "$GAME_NAME", "$SLUG", "Lynx", "libretro", 1, $DATE_S, "$SLUG-$DATE_S", 0.0, 0);
EOT

echo "$SLUG inserted successfuly"
#ouch "$ADDFILE"
echo "__________________________"
echo 

if [ -n "$auto_category" ]; then
	echo "Adding $SLUG to category $auto_category"
	lutris_add_game_to_category.sh "$SLUG" "$auto_category"
	echo $?
fi
