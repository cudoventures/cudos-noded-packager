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
# The CUDOS_HOME variable needs to be set in order to fix the location
# of the config files and database
#

#
# Test for the presence of an existing configuration, if present, exit.
#
# If not use "cudos-noded init" to initialise the databases and create
# the default versions of the config.toml and app.toml files. Then update
# the toml files with the settings for the desired node type.
#
# The default node type, when the script is called with no arguments is a
# stand alone full node, other node types can be set up by adding a node
# "type name" as the only argumen.
#
# The script is intended for use as a systemd service PreExec for
# the systemd cudos-noded.service
#
######################

export TYPE_NAME="$1"

#
# Set the CUDOS_HOME variable using the profile
#
source /etc/profile.d/cudos-noded.sh

#
# Check that the $CUDOS_HOME variable is set and pointing to a writeable directory
#
if [[ "$CUDOS_HOME" == "" ]]
then
	echo -ne "Error: Cudos home directory variable 'CUDOS_HOME' unset.\n\n"
	exit 1
fi

if [[ ! -d "$CUDOS_HOME" ]]
then
	echo -ne "Error: Directory '$CUDOS_HOME' does not exist\n\n"
	exit 1
fi

TCHFILE="${CUDOS_HOME}/touchtest.%%"
if ! touch "$TCHFILE"
then
	rm -f "$TCHFILE"
	echo -ne "Error: Cannot write to directory '$CUDOS_HOME'\n\n"
	ls -ld "${CUDOS_HOME}"
	exit 1
fi
rm -f "$TCHFILE"

#
# Check to see if there is already a configuration
#
FNM="${CUDOS_HOME}/config/config.toml"
if [[ -f "${FNM}" ]]
then
	echo -ne "Info: $FNM already present, not initialising\n\n"
	exit 0
fi

#
# Initialise the node using "cudos-noded init"
#
TMPFN="${CUDOS_HOME}/config/genesis.json-$$"
mv -f "$CUDOS_HOME"/config/genesis.json "$TMPFN"

cudos-noded init "$HOSTNAME" 2>/tmp/genesis.$$.json
if [[ $? -ne 0 ]]
then
	echo -ne "Error: cudos-noded init failed\n\n"
    cat /tmp/genesis.$$.json
    mv -f "$TMPFN" "$CUDOS_HOME"/config/genesis.json
    exit 1
fi

mv -f "$TMPFN" "$CUDOS_HOME"/config/genesis.json

#
# Select behaviour based on the node type name given
#
if [[ "$TYPE_NAME" == "" ]]
then
	TYPE_NAME="full-node"
fi
export TYPE_NAME

case $TYPE_NAME in
	full-node)
		cudos-noded-ctl set seeds "$CUDOS_HOME"/config/seeds.config
		cudos-noded-ctl set persistent_peers "$CUDOS_HOME"/config/persistent-peers.config
		cudos-noded-ctl set private_peers "$CUDOS_HOME"/config/private-peers.config
		cudos-noded-ctl set unconditional_peers "$CUDOS_HOME"/config/unconditional-peers.config
		cudos-noded-ctl set pex true
		cudos-noded-ctl set unsafe true
		cudos-noded-ctl set prometheus true
		cudos-noded-ctl set seed_mode false
		cudos-noded-ctl set minimum-gas-prices "5000000000000acudos"
		;;

	clustered-node)
		cudos-noded-ctl addrbook_clear

		cudos-noded-ctl set seeds "$CUDOS_HOME"/config/seeds.config
		cudos-noded-ctl set persistent_peers "$CUDOS_HOME"/config/persistent-peers.config
		cudos-noded-ctl set private_peers "$CUDOS_HOME"/config/private-peers.config
		cudos-noded-ctl set unconditional_peers "$CUDOS_HOME"/config/unconditional-peers.config
		cudos-noded-ctl set pex false
		cudos-noded-ctl set unsafe false
		cudos-noded-ctl set prometheus true
		cudos-noded-ctl set seed_mode false
		cudos-noded-ctl set minimum-gas-prices "5000000000000acudos"
		;;

	seed-node)
		cudos-noded-ctl set seeds "$CUDOS_HOME"/config/seeds.config
		cudos-noded-ctl set persistent_peers "$CUDOS_HOME"/config/persistent-peers.config
		cudos-noded-ctl set private_peers "$CUDOS_HOME"/config/private-peers.config
		cudos-noded-ctl set unconditional_peers "$CUDOS_HOME"/config/unconditional-peers.config
		cudos-noded-ctl set pex true
		cudos-noded-ctl set unsafe true
		cudos-noded-ctl set prometheus true
		cudos-noded-ctl set seed_mode true
		cudos-noded-ctl set minimum-gas-prices "5000000000000acudos"
		;;

	sentry-node)
		cudos-noded-ctl set seeds "$CUDOS_HOME"/config/seeds.config
		cudos-noded-ctl set persistent_peers "$CUDOS_HOME"/config/persistent-peers.config
		cudos-noded-ctl set private_peers "$CUDOS_HOME"/config/private-peers.config
		cudos-noded-ctl set unconditional_peers "$CUDOS_HOME"/config/unconditional-peers.config
		cudos-noded-ctl set pex true
		cudos-noded-ctl set unsafe true
		cudos-noded-ctl set prometheus true
		cudos-noded-ctl set seed_mode false
		cudos-noded-ctl set minimum-gas-prices "5000000000000acudos"
		;;

	*)
		echo -ne "Error: Unsupported Node Type: $TYPE_NAME\n\n"
		exit 1
esac

