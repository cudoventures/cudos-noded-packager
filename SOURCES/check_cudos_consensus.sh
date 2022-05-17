#!/bin/bash

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

