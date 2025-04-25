#!/bin/bash
# $@ : full game path
DATE_S=$(date +%s)
echo "######################"
echo "current unix time = $DATE_S"

[ -z "$1" ] && echo "$0 GAME_FULL_PATH" && exit 2

LUTRIS_GAMEDIR="$HOME/.local/share/lutris/games"
LUTRIS_DBFILE="$HOME/.local/share/lutris/pga.db"
[ ! -e "$LUTRIS_DBFILE" ] && echo "pga.db not found at $LUTRIS_DBFILE" && exit 3
GAME_NAME="$(basename "$@" ".z64")"
GAME_NAME="$(echo "$GAME_NAME" | sed 's/.v64//g')"

echo "GAME_NAME = $GAME_NAME"
SLUG="$(string_to_slug.sh "$GAME_NAME")""-n64"
SLUG="$(echo $SLUG | sed 's/-!-/-/g')"
SLUG="$(echo $SLUG | sed 's/--/-/g')"
echo "SLUG = $SLUG"

######## game file 
(
cat << EOT
game:
  core: parallel_n64
  main_file: $@
libretro: {}
system: {}

EOT
) > $LUTRIS_GAMEDIR/$SLUG-$DATE_S.yml || exit 3

sqlite3 $LUTRIS_DBFILE << EOT
INSERT INTO games (name, slug, platform, runner, installed, installed_at, configpath, playtime, hidden) VALUES ( "$GAME_NAME", "$SLUG", "Nintendo 64", "libretro", 1, $DATE_S, "$SLUG-$DATE_S", 0.0, 0);
EOT

echo "$SLUG inserted successfuly"
#ouch "$ADDFILE"
echo "__________________________"
echo 
