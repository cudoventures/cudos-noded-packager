#!/bin/bash
#
# Copyright 2023 Andrew Meredith <andrew.meredith@cudoventures.com>
# Copyright 2023 Cudo Ventures - All rights reserved.
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

# The identity and state files are:
# 
# ${NODE_BASE_DIR}/config/genesis.json
# ${NODE_BASE_DIR}/config/node_key.json
# ${NODE_BASE_DIR}/config/priv_validator_key.json
# ${NODE_BASE_DIR}/data/priv_validator_state.json

export MODE=$1
export NODE_BASE_DIR="/var/lib/cudos/cudos-data"

# Unset "DISPLAY" variable to prevent spurrious messages
unset DISPLAY

#
#
# Check that this is being run as user root
#
if [[ "$( whoami )" != "root" ]]
then
    echo -ne "Error: $0 must be run as user root.\n\n"
    exit 1
fi
#
#
# Set the CUDOS_HOME variable using the profile
#
source /etc/profile.d/cudos-noded.sh


function check-live()
{
	echo "Checking that the node is live"

	# If the node isn't signing blocks, error out
	echo -ne "  Checking for node moniker: "
	if ! cudos-noded status 2>&1 | jq .NodeInfo.moniker
	then
		echo "  Error: Node is not running"
		return 1
	else
		echo -ne " - [running]"
	fi

	# If there is already a ${NODE_BASE_DIR}/config/Parked directory, error out
	if [[ -d ${NODE_BASE_DIR}/config/Parked ]]
	then
		echo "  Error: This node is already parked"
		return 1
	else
		echo -ne "[not parked]"
	fi

	# If any of the identity and state files are missing, error out
	if [[ ! -f ${NODE_BASE_DIR}/config/genesis.json ]]
	then
		echo "  Error: Genesis file missing"
		return 1
	else
		echo -ne "[genesis]"
	fi

	if [[ ! -f ${NODE_BASE_DIR}/config/node_key.json ]]
	then
		echo "  Error: Node key missing"
		return 1
	else
		echo -ne "[node key]"
	fi

	if [[ ! -f ${NODE_BASE_DIR}/config/priv_validator_key.json ]]
	then
		echo "  Error: Validator key missing"
		return 1
	else
		echo -ne "[val key]"
	fi

	if [[ ! -f ${NODE_BASE_DIR}/data/priv_validator_state.json ]]
	then
		echo "  Error: Validator state file missing"
		return 1
	else
		echo -ne "[val state]\n"
	fi

	# Otherwise return True
	echo -ne "  Result: Node is Live\n\n"
	return 0
}

function park()
{
	# Check that it's live with the check-live subcommand, if not error out
	if ! check-live
	then
	    echo -ne "  Error: Node is not Live\n\n"
	    return 1
	fi

	echo "Parking"

	# Make sure there isn't already a Parked directory
	if [[ -d ${NODE_BASE_DIR}/config/Parked ]]
	then
		echo -ne "  Error: Parked directory already present\n\n"
		return 1
	fi

	# Shut down and disable the daemon
	systemctl disable cosmovisor@cudos
	systemctl stop cosmovisor@cudos

	# Move the identity and state files into config/Parked/
	mkdir -p ${NODE_BASE_DIR}/config/Parked
	mv ${NODE_BASE_DIR}/config/genesis.json            ${NODE_BASE_DIR}/config/Parked/
	mv ${NODE_BASE_DIR}/config/node_key.json           ${NODE_BASE_DIR}/config/Parked/
	mv ${NODE_BASE_DIR}/config/priv_validator_key.json ${NODE_BASE_DIR}/config/Parked/
	mv ${NODE_BASE_DIR}/data/priv_validator_state.json ${NODE_BASE_DIR}/config/Parked/
	#
	# Clean up permissions
	chown -R cudos:cudos ${NODE_BASE_DIR}

	echo -ne "  Info: Parked\n\n"
}

function check-parked()
{
	echo "Checking that the node is parked"

	# If the node daemon is not running
	if ! cudos-noded status >/dev/null 2>&1 
	then
		echo "  Info: Node is not running"
	else
		echo "  Error: Node is running"
		return 1
	fi

	# If there is already a ${NODE_BASE_DIR}/config/Parked directory, error out
	if [[ -d ${NODE_BASE_DIR}/config/Parked ]]
	then
		echo -ne "[parked dir]"
	else
		echo "  Error: Node has no Parked data"
		return 1
	fi

	# If any of the identity and state files are missing, error out
	if [[ ! -f ${NODE_BASE_DIR}/config/genesis.json ]]
	then
		echo -ne "[genesis cleared]"
	else
		echo "  Error: Genesis still in place"
		return 1
	fi

	if [[ -f ${NODE_BASE_DIR}/config/Parked/genesis.json ]]
	then
		echo -ne "[genesis parked]"
	else
		echo "  Error: Genesis file not parked"
		return 1
	fi

	if [[ ! -f ${NODE_BASE_DIR}/config/node_key.json ]]
	then
		echo -ne "[node key cleared]"
	else
		echo "  Error: Node key still in place"
		return 1
	fi

	if [[ -f ${NODE_BASE_DIR}/config/Parked/node_key.json ]]
	then
		echo -ne "[node key parked]"
	else
		echo "  Error: Node key not parked"
		return 1
	fi

	if [[ ! -f ${NODE_BASE_DIR}/config/priv_validator_key.json ]]
	then
		echo -ne "[val key cleared]"
	else
		echo "  Error: Validator key still in place"
		return 1
	fi

	if [[ -f ${NODE_BASE_DIR}/config/Parked/priv_validator_key.json ]]
	then
		echo -ne "[val key parked]"
	else
		echo "  Error: Validator key not parked"
		return 1
	fi

	if [[ ! -f ${NODE_BASE_DIR}/data/priv_validator_state.json ]]
	then
		echo -ne "[val state cleared]"
	else
		echo "  Error: Validator state file still in place"
		return 1
	fi

	if [[ -f ${NODE_BASE_DIR}/config/Parked/priv_validator_state.json ]]
	then
		echo -ne "[val state parked]\n"
	else
		echo "  Error: Validator state not parked"
		return 1
	fi

	# Otherwise return True
	echo -ne "  Result: Node is Parked\n\n"
	return 0
}

function un-park()
{
	# Check that it's live with the check-live subcommand, if not error out
	if ! check-parked
	then
	    echo -ne "  Error: Node is not Parked\n\n"
	    return 1
	fi

	echo "Unparking"

	# Make sure there is already a Parked directory
	if [[ ! -d ${NODE_BASE_DIR}/config/Parked ]]
	then
		echo -ne "  Error: Parked directory not present\n\n"
		return 1
	fi

	# Move the identity and state files out of config/Parked/
	mv ${NODE_BASE_DIR}/config/Parked/genesis.json              ${NODE_BASE_DIR}/config/genesis.json           
	mv ${NODE_BASE_DIR}/config/Parked/node_key.json             ${NODE_BASE_DIR}/config/node_key.json
	mv ${NODE_BASE_DIR}/config/Parked/priv_validator_key.json   ${NODE_BASE_DIR}/config/priv_validator_key.json
	mv ${NODE_BASE_DIR}/config/Parked/priv_validator_state.json ${NODE_BASE_DIR}/data/priv_validator_state.json
	rmdir ${NODE_BASE_DIR}/config/Parked

	# Clean up permissions
	chown -R cudos:cudos ${NODE_BASE_DIR}

	#
	# Start up and enable the daemon
	systemctl enable cosmovisor@cudos
	systemctl start cosmovisor@cudos

	echo -ne "  Info: Un-parked\n\n"
}

case $MODE in
	check-live)
		check-live
		exit $?
		;;

	park)
		park
		exit $?
		;;

	check-parked)
		check-parked
		exit $?
		;;

	un-park )
		un-park
		exit $?
		;;

	*)
		echo "Unkown option: '$1'"
		exit 1
		;;

esac		
