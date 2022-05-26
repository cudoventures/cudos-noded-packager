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

BLOCK_AGE=$(( $( date +%s ) - $( date -d $( cudos-noded status 2>&1 | jq -M .SyncInfo.latest_block_time | tr -d '"' ) +%s ) ))
BLOCK_NUM=$( cudos-noded status 2>&1 | jq -M .SyncInfo.latest_block_height | tr -d '"' )

echo "P \"Cudos Node Block Age\" block_age=$BLOCK_AGE;:30;:300 Last block ($BLOCK_NUM) signed $BLOCK_AGE seconds ago"

