#!/bin/bash
#
# Copyright 2022 Andrew Meredith <andrew.meredith@cudoventures.com>
# Copyright 2022 Cudo Ventures - All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

if [ ! -f /root/.cudos-container ]
then
	echo "Error: /root/.cudos-container not found"
	exit 1
fi

# Set the global variables and the exit trap
export TMPFILE=/tmp/cudos-noded-$$.txt
trap "rm -f $TMPFILE; exit" INT TERM EXIT

export CUDOS_CONTAINER="` cat /root/.cudos-container `"

docker cp /usr/bin/cudos-is-node-ready.sh "${CUDOS_CONTAINER}":/usr/cudos

if docker exec "${CUDOS_CONTAINER}" ./cudos-is-node-ready.sh >$TMPFILE 2>&1
then
  ERR=0
else
  ERR=2
fi

dos2unix $TMPFILE >/dev/null 2>&1

BLOCKHEIGHT_RAW=` fgrep Block "$TMPFILE" | sed -e'1,$s/.*Block Height: //'`
BLOCKHEIGHT=`printf "%.12f" $BLOCKHEIGHT_RAW`
CATCHING_UP=` fgrep Catch "$TMPFILE" | sed -e'1,$s/.*Catching up: //'`

if [ "$CATCHING_UP" = "true" ]
then
  CATCHING_UP=1
else
  CATCHING_UP=0
fi

cat << EOF
${ERR} "Cudos Node Catching Up" latest_block_height=${BLOCKHEIGHT}|catching_up=${CATCHING_UP} `cat $TMPFILE | tr "\n" " "`
EOF
