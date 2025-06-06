#!/bin/bash
# $@ : full game path
DATE_S=$(date +%s)
echo "######################"
echo "current unix time = $DATE_S"

[ -z "$1" ] && echo "$0 GAME_FULL_PATH" && exit 2

LUTRIS_GAMEDIR="/storage/GAMES_MASTER/LUTRIS/LUTRIS_RETRO/.config/lutris/games"
LUTRIS_DBFILE="/storage/GAMES_MASTER/LUTRIS/LUTRIS_RETRO/.local/lutris/pga.db"
[ ! -e "/storage/GAMES_MASTER/LUTRIS/LUTRIS_RETRO/.local/lutris/pga.db" ] && echo "pga.db not found at $/storage/GAMES_MASTER/LUTRIS/LUTRIS_RETRO/.local/lutris/pga.db" && exit 3
GAME_NAME="$(basename "$@" ".3ds")"
echo "GAME_NAME = $GAME_NAME"
SLUG="$(string_to_slug.sh "$GAME_NAME")""-3ds"
echo "SLUG = $SLUG"
ADDFILE="$(dirname "$@")""/.$GAME_NAME.added_2_lutris"
echo "ADDFILE ⁼ $ADDFILE"

[ -f "$ADDFILE" ] && echo "$GAME_NAME already added to Lutris, skipped" && exit 10

######## game file 
(
cat << EOT
citra: {}
game:
  main_file: $@
system:
  locale: ''

EOT
) > $LUTRIS_GAMEDIR/$SLUG-$DATE_S.yml || exit 3

sqlite3 $LUTRIS_DBFILE << EOT
INSERT INTO games (name, slug, platform, runner, installed, installed_at, configpath, playtime, hidden) VALUES ( "$GAME_NAME", "$SLUG", "Nintendo 3DS", "citra", 1, $DATE_S, "$SLUG-$DATE_S", 0.0, 0);
EOT

echo "$SLUG inserted successfuly"
touch "$ADDFILE"
echo "__________________________"
echo 
