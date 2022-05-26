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
