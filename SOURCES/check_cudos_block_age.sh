#!/bin/bash

BLOCK_AGE=$(( $( date +%s ) - $( date -d $( cudos-noded status 2>&1 | jq -M .SyncInfo.latest_block_time | tr -d '"' ) +%s ) ))
BLOCK_NUM=$( cudos-noded status 2>&1 | jq -M .SyncInfo.latest_block_height | tr -d '"' )

echo "P \"Cudos Node Block Age\" block_age=$BLOCK_AGE;:30;:300 Last block ($BLOCK_NUM) signed $BLOCK_AGE seconds ago"

