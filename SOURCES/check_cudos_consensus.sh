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

CSTATE="$( curl -s http://localhost:26657/consensus_state | jq -M .result.round_state.height_vote_set[0].prevotes_bit_array | tr -d '"' )"

CMASK="$( echo "$CSTATE" | sed -e'1,$s/^.*://' | sed -e'1,$s/}.*$//' )"
NUMVALS="$( echo -n $CMASK | wc -c )"
MASK1="$( echo -n $CMASK | tr -d _ | wc -c )"
MASK0="$( echo -n $CMASK | tr -d x | wc -c )"

ACTIVEVOTE="$( echo "$CSTATE" | sed -e'1,$s/^.*} //' | sed -e'1,$s/\/.*$//' )"
TOTVOTE="$( echo "$CSTATE" | sed -e'1,$s/^.*\///' | sed -e'1,$s/ = .*$//' )"
CONS="$( echo "scale=4; $ACTIVEVOTE * 100 / $TOTVOTE " | bc )"

echo "P \"Cudos Consensus Level\" signed=$MASK1|missing=$MASK0;:1;:$NUMVALS|num_vals=$NUMVALS|active_vote=$ACTIVEVOTE|tot_vote=$TOTVOTE|consensus=$CONS;75:;66: Signed by $MASK1 out of $NUMVALS ($CONS)"

# "prevotes_bit_array": "BA{27:_xxx______x___x____x___x_xx} 631572998/975355277 = 0.65",

