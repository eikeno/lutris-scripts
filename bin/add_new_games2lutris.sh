#!/bin/bash
# Add Wine and linux game types to Lutris
# See mark_exe_path4lutris.sh and start.sh2lutris.sh  for details/
# This is meant to be run from a location containing game folders:
# $CWD/
# ----/Game1/
# ----/Game2/
# etc.

# Expected location of LUTRIS and start.sh is as follows:

# For wine games:
# ~/MyGames/
# ---------/AnotherGame/LUTRIS
# ---------/AnotherGame/another_game_realdir/
# ---------/AnotherGame/another_game_realdir/game.exe
# With a LUTRIS file containing exactly "another_game_realdir/game.exe"

# For Linux games:
# ~/MyGames/
# ---------/AnotherGame/start.sh
# ---------/AnotherGame/another_game_realdir/
# ---------/AnotherGame/another_game_realdir/game.x86_64
# With a start.sh containing whatever is needed to start the game.
# Here's a minimalist template:
# #!/bin/bash
# WD="$(dirname "${BASH_SOURCE[0]}")"
#
# export HOME="$PWD/files";
# export XDG_DATA_HOME="$PWD/files/.local";
# export XDG_CONFIG_HOME="$PWD/files/.config";
#
# \pushd  "$WD/another_game_realdir/" || exit 1
# "./game.x86_64"
#
# If you dont want to keep dotfiles in the game's folder,
# just remove the export lines.
# The pushd is to prevent problems with many games needing to be started from current directory.

WD="$(realpath -e "$PWD")"
echo
echo "### entering $WD"

# WINE GAMES
find "$WD" -maxdepth 1 -mindepth 1 -type d | while read -r d; do
	echo "d: $d"
	unset lutris_files
	if [[ -r "$d/LUTRIS" ]]; then
		add_new_games2lutris.wine.lib "$d/LUTRIS"
	fi
done

# LINUX GAMES
find "$WD" -maxdepth 1 -mindepth 1 -type d | while read -r d; do
	echo "d: $d"
	unset start_file
	if [[ -r "$d/start.sh" ]]; then
		chmod +x "$d/start.sh" ; # just in case
		add_new_games2lutris.linux.lib "$d/start.sh"
	fi
done
