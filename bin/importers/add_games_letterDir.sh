#!/bin/bash

\pushd "$@" || exit 2
( add_new_games2lutris.sh )
\popd
