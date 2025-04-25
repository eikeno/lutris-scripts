#!/bin/bash
# $1: base64 encoded string for: gamedir;slug # -> poorest man's serialization :-)
# depends : sqlite3
echo ">>> $0 :: $*"
# TODO: modify to work on arch (/run/media inst. of /media)

LUTRIS_GAMEDIR="$HOME/.local/share/lutris/games"
LUTRIS_DBFILE="$HOME/.local/share/lutris/pga.db"
NAS="/storage/nas"

src="$(echo "$@" | base64 -d | cut -f1 -d';')"
SLUG="$(echo "$@" | base64 -d | cut -f2 -d';')"

echo "src=$src"
echo "SLUG=$SLUG"

[ -z "$src" ] && echo  "$0 BASE64_STR" && echo "err_empty_src" && exit 2
[ -z "$SLUG" ] && echo "$0 BASE64_STR" && echo "err_empty_SLUG" && exit 2

gamedir="$(basename "$src")"
echo "gamedir=$gamedir"

# find source media
if echo "$src" | grep  -q ^"/media/$USERNAME/"; then
	SRC_TYPE="local"
	# local disk
	srcmed="$(echo "$src" | sed "s,^/media/$USERNAME/,," | cut -f1 -d'/')"
	echo "srcmed=$srcmed"

	srcpath="$(echo "$src" | sed "s,^/media/$USERNAME/,," | sed "s,$srcmed/,,") "
	echo "srcpath=$srcpath"

elif echo "$src" | grep  -q ^"/storage/nas/"; then
	SRC_TYPE="nas"
	# Disk on NAS:
	srcmed="$(echo "$src" | sed "s,^/storage/nas/,," | cut -f1 -d'/')"
	echo "srcmed=$srcmed"

	srcpath="$(echo "$src" | sed "s,^/storage/nas/,," | sed "s,$srcmed/,,")"
	echo "srcpath=$srcpath"
else
	echo "exit 3"
	exit 3
fi

echo "==="
echo "SRC_TYPE: $SRC_TYPE"
echo "srcmed: $srcmed"
echo "srcpath: $srcpath"
echo "==="

# add NAS to choices if accessible
if [ -n "$DEST_MEDIA" ]; then
	echo "Overriding 'dstmed' with $DEST_MEDIA  based on DEST_MEDIA env var."
	dstmed="$DEST_MEDIA" # useful to allow call from other scripts, with destination already defined
else
	echo "Please select destination media:" 
	if [ -e "$NAS/.nas_is_mounted" ]; then
		echo  "NAS seems accessible"
		dstmed="$( (ls -1 $NAS ; ls -1 "/media/$USERNAME/") | fzf)"
		echo "dstmed: $dstmed"
	else
		echo "NAS is not accessible, listing local disks only"
		dstmed="$(ls -1 "/media/$USERNAME/" | fzf)"
	fi
	[ -z "$dstmed" ] && echo "ERR dstmed is empty" && exit 10
	[ "$dstmed" == 'NAS----' ] && echo "wrong value select in fzf" && exit 101
	[ "$dstmed" == 'LOCAL----' ] && echo "wrong value select in fzf" && exit 101
fi
echo "dstmed: $dstmed (final)"

# determine the type of chosen destination (local or nas) safely
if [ -e "/media/$USERNAME/$dstmed" ] && [ -e "$NAS/$dstmed" ]; then
	echo "$dstmed seems to exist on both local and nas, can't continue, please check"
	exit 11
fi

# since we know it's unique (from above) we can proceed in any order:
if [ -e "$NAS/$dstmed" ]; then
	DEST_TYPE='nas'
	echo "DEST_TYPE: $DEST_TYPE"

elif [ -e "/media/$USERNAME/$dstmed" ]; then
	DEST_TYPE='local'
	echo "DEST_TYPE: $DEST_TYPE"

else
	echo "$dstmed not found on either local or nas. exit 12"
	exit 12
fi

if [ "$DEST_TYPE" = "local" ]; then
	dst="/media/$USERNAME/$dstmed/$(dirname "$srcpath")/"
	echo "dst: $dst"
elif [ "$DEST_TYPE" = "nas" ]; then
	dst="$NAS/$dstmed/$(dirname "$srcpath")/"
	echo "dst: $dst"
else
	echo "DEST_TYPE cannot be empty. exit 13"
	exit 13
fi

function get_configpath () {
(
sqlite3 "$LUTRIS_DBFILE" << EOT
SELECT configpath FROM games WHERE slug="$SLUG" ORDER BY configpath DESC LIMIT 1;
EOT
)
}

# get yaml file name:
if [ -r "$LUTRIS_GAMEDIR"/"$(get_configpath "$SLUG")"".yml" ]; then
	YAML="$LUTRIS_GAMEDIR"/"$(get_configpath "$SLUG")"".yml"
elif [ -e "$LUTRIS_GAMEDIR"/"${SLUG:0:1}"/"$(get_configpath "$SLUG")"".yml" ]; then
	# use FirstLetterDir variant:
	YAML="$LUTRIS_GAMEDIR"/"${SLUG:0:1}"/"$(get_configpath "$SLUG")"".yml"
else
	echo "ERROR, yaml find not found at normal or alternative locations"
	exit 15
fi

echo "YAML = $YAML"

echo "Copying data..."
rsync -avP "$src" "$dst"  || exit 1

echo "Modifying game file with: "
if [ "$DEST_TYPE" == "nas" ]; then
	dest_string="$NAS/$dstmed"
else
	dest_string="/media/$USERNAME/$dstmed"
fi

if [ "$SRC_TYPE" == "nas" ]; then
	src_string="$NAS/$srcmed"
else
	src_string="/media/$USERNAME/$srcmed"
fi

echo "sed -i \"s,$src_string,$dest_string,g\" \"$YAML\""
sed -i "s,$src_string,$dest_string,g" "$YAML" || exit 20

if [ "$DELETE_SRC" != "1" ]; then
	echo "Delete $src ?"
	echo "YES  or anything else to dismiss cancel"
	read -r choice
	
	case "$choice" in
		"YES") rm -Rf "$src" ;;
		*) echo "skip delete" ;;
	esac
else
	rm -Rf "$src"
	echo "ret: $?"
fi

exit 0
