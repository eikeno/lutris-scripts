#!/bin/bash
# $1 = GAMEID (slug)
# depends : sqlite3

pwd="$PWD"
DATE_S=$(date +%s)
echo "current dir = $pwd"
echo "current unix time = $DATE_S"

[[ -z "$1" ]] && echo "$0 GAMEID" && exit 2

LUTRIS_GAMEDIR="$HOME/.local/share/lutris/games"
LUTRIS_DBFILE="$HOME/.local/share/lutris/pga.db"
GAME_NAME="$(basename "$pwd")"
EXE="$(realpath "start.sh")"

function esq {
  echo "${*//\'/\'\'}"
}


######## game file
(
cat << EOT
game:
  exe: "$EXE"
  working_dir: "$(dirname "$EXE")"
linux: {}
system:
  disable_compositor: true
  prefer_system_libs: true
  prefix_command: '/storage/GAMES_MASTER/BindToInterface/bindToInterface_noWAN.sh '
EOT
) > "$LUTRIS_GAMEDIR/$1-$DATE_S.yml" || exit 3

####### sqlite record

sqlite3 "$LUTRIS_DBFILE" << EOT
INSERT INTO games (name, slug, platform, runner, installed, installed_at, configpath, playtime, hidden) VALUES ( '$(esq "$GAME_NAME")', '$1', 'Linux', 'linux', 1, $DATE_S, '$1-$DATE_S', 0.0, 0);
EOT

echo "$1 inserted successfuly"
echo
