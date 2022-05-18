#!/bin/bash

# Set the global variables and the exit trap
export PRDUMP=/tmp/prometheus-dump.$$.txt
trap "rm -f $PRDUMP; exit" INT TERM EXIT

##################################################
#
# Load and count Prometheus output and maybe exit
#
export CUDOS_CONTAINER="` cat /root/.cudos-container `"

RET=0
if ! docker exec -i "${CUDOS_CONTAINER}" curl localhost:26660 >${PRDUMP} 2>/dev/null
then
	RET=2
fi

LINE_COUNT="` wc -l $PRDUMP | awk '{ print $1 }' `"

echo "$RET \"Cudos Node Prometheus Line Count\" line_count=$LINE_COUNT;10:;10: $LINE_COUNT"

if [ "${RET}" = "2" ]
then
	exit 0	
fi

##################################################
#
# Pick out individual parameters and groups
#
##################################################
#
# Number of Peers
#
NUM_PEERS=` fgrep 'tendermint_p2p_peers{' "${PRDUMP}" | awk '{ print $2 '} `

echo "P \"Cudos Node Number of Peers\" num_vals=$NUM_PEERS;0:;0: Number of Peers: $NUM_PEERS"

#
# Block Processing Time
#
BLOCK_PROC="-1"
BLOCK_PROC_SUM=` fgrep 'tendermint_state_block_processing_time_sum{' "${PRDUMP}" | awk '{ print $2 '} `
BLOCK_PROC_COUNT=` fgrep 'tendermint_state_block_processing_time_count{' "${PRDUMP}" | awk '{ print $2 '} `

BLOCK_PROC_SUM_BC=`printf "%.12f" $BLOCK_PROC_SUM`
BLOCK_PROC_COUNT_BC=`printf "%.0f" $BLOCK_PROC_COUNT`

if [ "${BLOCK_PROC_SUM}" != "" ]
then
	BLOCK_PROC="$( echo "scale=4; $BLOCK_PROC_SUM_BC / $BLOCK_PROC_COUNT_BC" | bc -l )"
fi

echo "P \"Cudos Node Block Processing Time\" block_proc=$BLOCK_PROC;4:30;0:300|sum=$BLOCK_PROC_SUM_BC|count=$BLOCK_PROC_COUNT_BC Block Processing Time: $BLOCK_PROC"

#
# Block Interval
#
BLOCK_INTERVAL="-1"
BLOCK_INTERVAL_SUM=` fgrep 'tendermint_consensus_block_interval_seconds_sum{' "${PRDUMP}" | awk '{ print $2 '} `
BLOCK_INTERVAL_COUNT=` fgrep 'tendermint_consensus_block_interval_seconds_count{' "${PRDUMP}" | awk '{ print $2 '} `

BLOCK_INTERVAL_SUM_BC=`printf "%.12f" $BLOCK_INTERVAL_SUM`
BLOCK_INTERVAL_COUNT_BC=`printf "%.0f" $BLOCK_INTERVAL_COUNT`

if [ "${BLOCK_INTERVAL_SUM}" != "" ]
then
	BLOCK_INTERVAL="$( echo "scale=4; $BLOCK_INTERVAL_SUM_BC / $BLOCK_INTERVAL_COUNT_BC" | bc -l )"
	echo "P \"Cudos Node Block Interval\" block_interval=$BLOCK_INTERVAL;4:30;0:300|sum=$BLOCK_INTERVAL_SUM_BC|count=$BLOCK_INTERVAL_COUNT_BC Block Interval: $BLOCK_INTERVAL"
else
	echo "0 \"Cudos Node Block Interval\" - Parameter not present in prometheus data"
fi


#
# Number of Validators
#
RESULT=` fgrep 'tendermint_consensus_validators{' "${PRDUMP}" | awk '{ print $2 '} `
if [ "${RESULT}" != "" ]
then
	echo "P \"Cudos Node Number of Validators\" num_vals=$RESULT;8:;8: Number of Validators: $RESULT"
else
	echo "0 \"Cudos Node Number of Validators\" - Parameter not present in prometheus data"
fi

#
# Missing Validators
#
RESULT=` fgrep 'tendermint_consensus_missing_validators{' "${PRDUMP}" | awk '{ print $2 '} `
if [ "${RESULT}" != "" ]
then
	echo "P \"Cudos Node Missing Validators\" missing_vals=$RESULT;:1;:1 Missing Validators: $RESULT"
else
	echo "0 \"Cudos Node Missing Validators\" - Parameter not present in prometheus data"
fi

#
# Fast Syncing
#
RESULT=` fgrep 'tendermint_consensus_fast_syncing{' "${PRDUMP}" | awk '{ print $2 '} `
if [ "${RESULT}" != "" ]
then
	echo "P \"Cudos Node Fast Syncing\" fast_syncing=$RESULT Fast Syncing: $RESULT"
else
	echo "0 \"Cudos Node Fast Syncing\" - Parameter not present in prometheus data"
fi

#
# Block Height
#
RESULT_RAW=` fgrep 'tendermint_consensus_latest_block_height{' "${PRDUMP}" | awk '{ print $2 '} `
if [ "${RESULT_RAW}" != "" ]
then
	RESULT=`printf "%.0f" $RESULT_RAW`
	echo "P \"Cudos Node Block Height\" block_height=$RESULT;2:;2: Block Height: $RESULT"
else
	echo "0 \"Cudos Node Block Height\" - Parameter not present in prometheus data"
fi

#
# Validator Voting Power
#
POWER=` fgrep 'tendermint_consensus_validator_power{' "${PRDUMP}" | awk '{ print $2 '} `

if [ "$POWER" = "" ]
then
	echo "0 \"Cudos Node Validator Power\" - Not a validator"
else
	echo "P \"Cudos Node Validator Power\" validator_power=$POWER;1:;1: Validator Power: $POWER"
fi