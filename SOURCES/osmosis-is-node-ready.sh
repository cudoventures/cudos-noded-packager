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

CATCHING_UP=$( osmosisd status 2>&1 | jq -M ".SyncInfo.catching_up" )
BLOCK_HEIGHT=$( osmosisd status 2>&1 | jq -M ".SyncInfo.latest_block_height" | tr -d '"' )


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
