#!/bin/bash

dd if="$1.BIN" of="$1.bin" skip=387 bs=1M
