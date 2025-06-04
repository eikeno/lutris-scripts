#!/bin/bash
# Ensures all lutris coverart files are in supported JPG format
# supports avif, webp, png. More can be added if needed in any2jpg.sh
# depends : any2jpg.sh

echo ">> starting $0"
pushd ~/.local/share/lutris/coverart || exit
any2jpg.sh
echo "retval: $?"
