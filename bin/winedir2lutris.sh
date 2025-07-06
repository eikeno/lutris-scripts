#!/bin/bash
# $1: slug
# $2: relative exe path

# spellcheck disable=SC2001
# depends: sqlite3

pwd="$PWD"
DATE_S=$(date +%s)
echo "current dir = $pwd"
echo "current unix time = $DATE_S"

[[ -z "$1" ]] && echo "$0 GAMEID EXEPATH" && exit 2
[[ -z "$2" ]] && echo "$0 GAMEID EXEPATH" && exit 2

# FIXME: make this overridable via env vars or conf file:
LUTRIS_GAMEDIR="$HOME/.local/share/lutris/games"
LUTRIS_DBFILE="$HOME/.local/share/lutris/pga.db"
GAME_NAME="$(basename "$pwd")"

EXE="$(realpath "$2")"
PFX="$(realpath "$pwd")/WINE"

echo "GAME_NAME: $GAME_NAME"
echo "EXE: $EXE"
echo "PFX: $PFX"
echo "working_dir: $(dirname "$EXE")"

function esq {
  echo "${*//\'/\'\'}"
}

######## game file 
(
cat << EOT
game:
  arch: win64
  args: ''
  exe: "$EXE"
  prefix: "$HOME/LUTRIS/SHARED_PREFIXES/PROTON"
  working_dir: "$(dirname "$EXE")"
system:
  prefer_system_libs: true
  prefix_command: '/storage/GAMES_MASTER/BindToInterface/bindToInterface_noWAN.sh '
wine:
  show_debug: -all
  version: ge-proton
EOT
) > "$LUTRIS_GAMEDIR/$1-$DATE_S.yml" || exit

echo "added game file: $LUTRIS_GAMEDIR/$1-$DATE_S.yml"

####### sqlite record 

sqlite3 "$LUTRIS_DBFILE" << EOT
INSERT INTO games (name, slug, platform, runner, installed, installed_at, configpath, playtime, hidden) VALUES ( '$(esq "$GAME_NAME")', '$1', 'Windows', 'wine', 1, $DATE_S, '$1-$DATE_S', 0.0, 0)
EOT

echo "$1 inserted successfuly"
echo 
