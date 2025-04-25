#!/bin/bash
# Lutris runner for use by ES-DE and such
# depends : lutris

GAME="$(echo "$@" | sed 's/-run //' | sed 's/ /-/g')"

lutris "lutris:rungame/$GAME"
