#!/bin/bash

RESULT="$( hermes --json query packet pending --chain osmosis-1 --port transfer --channel channel-298 2>/dev/null)"

SRC_ACK_STR=$(  echo "$RESULT" | jq .result.src.unreceived_acks )
SRC_PACK_STR=$( echo "$RESULT" | jq .result.src.unreceived_packets )
DST_ACK_STR=$(  echo "$RESULT" | jq .result.dst.unreceived_acks )
DST_PACK_STR=$( echo "$RESULT" | jq .result.dst.unreceived_packets )

SRC_ACK=$(  echo "$RESULT" | jq '.result.src.unreceived_acks | length' )
SRC_PACK=$( echo "$RESULT" | jq '.result.src.unreceived_packets | length' )
DST_ACK=$(  echo "$RESULT" | jq '.result.dst.unreceived_acks | length' )
DST_PACK=$( echo "$RESULT" | jq '.result.dst.unreceived_packets | length' )

RELAY_STATUS=$( echo "$RESULT" | jq .status | tr -d '"' )

if [[ "$RELAY_STATUS" = "success" ]]
then
	RELAY_STATUS_OUT="0"
else
	RELAY_STATUS_OUT="1"
	ERR_OUT=2
fi

RSTR="$( echo "\nsrc_ack $SRC_ACK_STR\nsrc_pack $SRC_PACK_STR\ndst_ack $DST_ACK_STR\ndst_pack $DST_PACK_STR\n" | tr -d '\n' )"

echo "P \"Osmosis Relay Status\" src_ack=$SRC_ACK;:1;:1|src_pack=$SRC_PACK;:1;:1|dst_ack=$DST_ACK;:1;:1|dst_pack=$DST_PACK;:1;:1|relay_status=$RELAY_STATUS_OUT;:1;:1 Relay Status $RELAY_STATUS - $SRC_ACK $SRC_PACK $DST_ACK $DST_PACK $RELAY_STATUS $RSTR"
