#!/bin/bash

if [ ! -f /root/.cudos-container ]
then
	echo "Error: /root/.cudos-container not found"
	exit 1
fi

# Set the global variables and the exit trap
export TMPFILE=/tmp/cudos-noded-$$.txt
trap "rm -f $TMPFILE; exit" INT TERM EXIT

export CUDOS_CONTAINER="` cat /root/.cudos-container `"

docker exec -i "${CUDOS_CONTAINER}" cudos-noded status > $TMPFILE 2>&1

BLOCK_AGE=$(( $( date +%s ) - $( date -d $( cat $TMPFILE | jq -M .SyncInfo.latest_block_time | tr -d '"' ) +%s ) ))
BLOCK_NUM=$( cat $TMPFILE | jq -M .SyncInfo.latest_block_height | tr -d '"' )

echo "P \"Cudos Node Block Age\" block_age=$BLOCK_AGE;:30;:300 Last block ($BLOCK_NUM) signed $BLOCK_AGE seconds ago"

