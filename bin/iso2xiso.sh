#!/bin/bash
# convert normal Xbox ISO to supported Xbox ISO :

dd if="$*" of="XISO_$*" skip=387 bs=1M
