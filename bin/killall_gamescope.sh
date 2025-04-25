#!/usr/bin/env bash
ps faux | grep gamescope | grep -v grep | awk '{print $2}' | while read -r pid; do kill -9 $pid; done
