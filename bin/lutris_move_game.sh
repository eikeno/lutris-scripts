#!/bin/bash
# $1: base64 encoded string for: gamedir;slug  A.k.a -> poorest man's serialization :-)
# depends : sqlite3
# depends : fzf
# WARNING: This is configured for the way I organize my games on a NAS, do not
# WARNING: use it without fully understanding what it does and modify it to
# WARNING: YOUR needs. Chances are you do not need this at all.
# WARNING: Also, despite it would be possible to call this script directly,
# WARNING: it's intended to be called via a modified Lutris desktop client.

echo ">>> $0 :: $*"

LUTRIS_GAMEDIR="$HOME/.local/share/lutris/games"
LUTRIS_DBFILE="$HOME/.local/share/lutris/pga.db"
DESTPATHS_FILE="$HOME/.config/lutris_migration_paths.conf"

# debugf="/dev/null" # lazy...
debugf="/tmp/lutris_debug.txt"
echo > $debugf

EXE="$(echo "$@" | base64 -d | cut -f1 -d';')"
SLUG="$(echo "$@" | base64 -d | cut -f2 -d';')"

echo "EXE = $EXE"    | tee -a $debugf
echo "SLUG = $SLUG"  | tee -a $debugf

[ -z "$EXE" ] && echo  "$0 BASE64_STR" && echo "err_empty_EXE" && exit 2
[ ! -e "$EXE" ] && exit 21
[ -z "$SLUG" ] && echo "$0 BASE64_STR" && echo "err_empty_SLUG" && exit 2

EXEDIR=$(dirname "$EXE")
_exedir_parent="$(dirname "$EXEDIR")"
GAMEDIR="$(basename "$_exedir_parent")"

echo "EXEDIR = $EXEDIR" | tee -a $debugf
echo "GAMEDIR = $GAMEDIR"| tee -a $debugf

echo "$EXE" | grep -a ^/storage/nas || exit 3

SRC_DRIVE=$(echo $EXE | cut -f4 -d'/')
[ -s "$SRC_DRIVE" ] && exit 4
echo "SRC_DRIVE = $SRC_DRIVE" | tee -a $debugf

# FIXME: doing like this doesn't work when the exe file is not directly at
# the root of the gamedir. Instead, should check parent dirs, one by one
# until the LUTRIS file is found:
DN1=$(dirname "$EXEDIR")
DN2=$(dirname "$DN1")
DN3=$(dirname "$DN2")
GAMESTORE=$(basename "$DN3")
echo "GAMESTORE = $GAMESTORE" | tee -a $debugf

fl=${GAMEDIR:0:1}
FL=${fl^^}
echo "FL = $FL" | tee -a $debugf

[ ! -r "$DESTPATHS_FILE" ] && echo "$0 ERR_DESTPATHS_FILE" && exit 5
echo "Select destination drive:"
SELECTED_DEST_DRIVE=$(cat "$DESTPATHS_FILE" | fzf)
echo "SELECTED_DEST_DRIVE = $SELECTED_DEST_DRIVE" | tee -a $debugf

# Abort if destination already exists
DESTINATION_GAMEDIR_PATH="/storage/nas/$SELECTED_DEST_DRIVE/Games/LUTRIS/$GAMESTORE/$FL/$GAMEDIR"
DESTINATION_GAMEDIR_PARENT="$(dirname "$DESTINATION_GAMEDIR_PATH")"
[ -e "$DESTINATION_GAMEDIR_PATH" ] && echo "$0 DESTDIR_EXISTS" && exit 6

migration_text="###\nWill attempt migrating:\n/storage/nas/$SRC_DRIVE/Games/LUTRIS/$GAMESTORE/$FL/$GAMEDIR\nto\n$DESTINATION_GAMEDIR_PARENT\n###\n"
echo -e $migration_text | tee -a $debugf

function get_configpath () {
(
sqlite3 "$LUTRIS_DBFILE" << EOT
SELECT configpath FROM games WHERE slug='$1' ORDER BY configpath DESC LIMIT 1;
EOT
)
}

# Check yaml file
YAML="$LUTRIS_GAMEDIR/$(get_configpath $SLUG).yml"
if [ 1 -r "$YAML" ]; then
	echo "ERROR yaml file find not found, or unreadable at expected location: $YAML" | tee -a $debugf
	exit 15
fi
echo "YAML = $YAML" | tee -a $debugf

echo "Copying data..." | tee -a $debugf
echo mkdir -p "$DESTINATION_GAMEDIR_PARENT/" | tee -a $debugf
rsync -avP "/storage/nas/$SRC_DRIVE/Games/LUTRIS/$GAMESTORE/$FL/$GAMEDIR" "$DESTINATION_GAMEDIR_PARENT/" | tee -a $debugf

echo "Modifying YAML game file with new path $DESTINATION_GAMEDIR_PATH" | tee -a $debugf
sed -i "s;/storage/nas/$SRC_DRIVE/Games/LUTRIS/$GAMESTORE/$FL/;$DESTINATION_GAMEDIR_PARENT/;g" "$YAML" || exit 20

echo "Delete /storage/nas/$SRC_DRIVE/Games/LUTRIS/$GAMESTORE/$FL/$GAMEDIR ?" | tee -a $debugf
echo "Confirm with YES, or type anything else to dismiss cancel" | tee -a $debugf
read -r choice
echo "choice = $choice" | tee -a $debugf

case "$choice" in
	"YES") rm -Rf "/storage/nas/$SRC_DRIVE/Games/LUTRIS/$GAMESTORE/$FL/$GAMEDIR" ;;
	*) echo "skip delete" | tee -a $debugf ;;
esac

exit 0
