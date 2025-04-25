#!/bin/bash

basename "$PWD" | tr '[:upper:]' '[:lower:]'|
sed "s/'//g" |\
sed 's/,//g' |\
sed 's/_/ /g'|\
sed 's/(//g' |\
sed 's/)//g' |\
sed 's/\[//g' |\
sed 's/\]//g' |\
sed 's/:/ /g' |\
sed 's/+/ /g' |\
sed 's/=//g' |\
sed 's/\&/ and /g' |\
sed 's/\./ /g' |\
sed 's/  / /g' |\
sed 's/ /-/g' |\
sed 's/--/-/g' |\
sed 's/--/-/g' |\
sed 's/--/-/g' |\
sed 's/--/-/g' |\
sed 's/--/-/g' |\
sed 's/--/-/g' |\
sed 's/--/-/g' |\
sed 's/--/-/g'
