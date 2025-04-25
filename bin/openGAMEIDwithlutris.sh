#!/bin/bash
# Run lutris game when called from a web browser using lurtris:// 
# depends : lutris

gameid="${*//lutris:\/\/}" 
echo lutris "lutris:rungameid/$gameid"
