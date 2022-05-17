#!/bin/bash

CATCHING_UP=$( cudos-noded status 2>&1 | jq -M ".SyncInfo.catching_up" )
BLOCK_HEIGHT=$( cudos-noded status 2>&1 | jq -M ".SyncInfo.latest_block_height" | tr -d '"' )


if [ $BLOCK_HEIGHT -lt 2 ]
then
	STATE=false
else
	if [ "$CATCHING_UP" = "true" ]
	then
		STATE=false
	else
		STATE=true
	fi
fi

echo "Is node ready: $STATE"
echo "  Latest Block Height: $BLOCK_HEIGHT"
echo "  Catching up: $CATCHING_UP"
echo "  `date`"

if [ "$STATE" = "true" ]
then
	exit 0
else
	exit 1
fi
