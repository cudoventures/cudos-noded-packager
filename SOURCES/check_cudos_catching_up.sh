#!/bin/bash

export TMPFILE=/tmp/cudos-noded-$$.txt

RESULTS="`/usr/bin/cudos-is-node-ready.sh`"

dos2unix $TMPFILE >/dev/null 2>&1

BLOCKHEIGHT_RAW=` echo "$RESULTS" | fgrep Block | sed -e'1,$s/.*Block Height: //'`
BLOCKHEIGHT=`printf "%.0f" $BLOCKHEIGHT_RAW`
CATCHING_UP=` echo "$RESULTS" | fgrep Catch | sed -e'1,$s/.*Catching up: //'`

if /usr/bin/cudos-is-node-ready.sh >$TMPFILE 2>&1
then
  ERR=0
else
  ERR=2
fi

if [ "$CATCHING_UP" = "true" ]
then
  CATCHING_UP=1
else
  CATCHING_UP=0
fi

cat << EOF
${ERR} "Cudos Node Catching Up" latest_block_height=${BLOCKHEIGHT}|catching_up=${CATCHING_UP} `cat $TMPFILE| tr "\n" " "`
EOF
