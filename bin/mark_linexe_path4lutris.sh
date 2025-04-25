#!/bin/bash
# Can be used to insert relative game executable path; from game topdir.

chmod +x "$@"
echo "$@" > .linux_exe || exit 2
