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

#
# Usage: icn-switch-nodes <root ssh address of "L" node> <root ssh address of "R" node>
# 
# Intended to be executed from the stand-off "controlling" workstation, but could as easily
# be run from one of the two nodes in question, referring to itself in the ssh address.

# The identity and state files are:
# 
# ${NODE_BASE_DIR}/config/genesis.json
# ${NODE_BASE_DIR}/config/node_key.json
# ${NODE_BASE_DIR}/config/priv_validator_key.json
# ${NODE_BASE_DIR}/data/priv_validator_state.json

export LSSH=$1
export RSSH=$2
export NODE_BASE_DIR="/var/lib/cudos/cudos-data"

# Check arguments exist
if [[ "$LSSH" == "" ]]
then
	echo -ne "Error: No Left hand ssh target\n\n"
	exit 1
fi

if [[ "$RSSH" == "" ]]
then
	echo -ne "Error: No Right hand ssh target\n\n"
	exit 1
fi


# Audit both nodes to make sure they're safe to switch

echo -ne "Check the LH node\n"
if ssh $LSSH icn-park-node check-live
then
	echo -ne "  Info: LH server live\n\n"
else
	echo -ne "  Error: LH server unreachable\n\n"
	exit 1
fi

echo -ne "Check the RH node\n"
if ssh $RSSH icn-park-node check-live
then
	echo -ne "  Info: RH server live\n\n"
else
	echo -ne "  Error: RH server unreachable\n\n"
	exit 1
fi

# Park both nodes with park

echo -ne "Park the LH node\n"
if ssh $LSSH icn-park-node park
then
	echo -ne "  Info: LH server parked\n\n"
else
	echo -ne "  Error: LH server parking failed\n\n"
	exit 1
fi

echo -ne "Park the RH node\n"
if ssh $RSSH icn-park-node park
then
	echo -ne "  Info: RH server parked\n\n"
else
	echo -ne "  Error: RH server parking failed\n\n"
	exit 1
fi

# Check both nodes are parked with check-parked

echo -ne "Check the LH node\n"
if ssh $LSSH icn-park-node check-parked
then
	echo -ne "  Info: LH server parked\n\n"
else
	echo -ne "  Error: LH server parking failed\n\n"
	exit 1
fi

echo -ne "Check the RH node\n"
if ssh $RSSH icn-park-node check-parked
then
	echo -ne "  Info: RH server parked\n\n"
else
	echo -ne "  Error: RH server parking failed\n\n"
	exit 1
fi

# Copy config/Parked/ on the L Node to config/Parked-switch/ on the R Node

ssh ${LSSH} chown -R root ${NODE_BASE_DIR}/config/Parked
RES=$?
if [[ "$RES" != "0" ]]
then
	echo -ne "  Error: L chown failed\n\n"
	exit 1
else
	echo -ne "  Info: L chown done\n"
fi

ssh ${RSSH} mkdir -p ${NODE_BASE_DIR}/config/Parked-switch/
RES=$?
if [[ "$RES" != "0" ]]
then
	echo -ne "  Error: R mkdir failed\n\n"
	exit 1
else
	echo -ne "  Info: R mkdir done\n"
fi

scp -3 -r  ${LSSH}:${NODE_BASE_DIR}/config/Parked/. ${RSSH}:${NODE_BASE_DIR}/config/Parked-switch/.
RES=$?
if [[ "$RES" != "0" ]]
then
	echo -ne "  Error: L to R copy failed\n\n"
	exit 1
else
	echo -ne "  Info: L to R copy done\n"
fi

# Delete the config/Parked/ directory on the L Node

ssh ${LSSH} rm -rf ${NODE_BASE_DIR}/config/Parked/
RES=$?

if [[ "$RES" != "0" ]]
then
	echo -ne "  Error: L clear failed\n\n"
	exit 1
else
	echo -ne "  Info: L clear done\n"
fi

# Copy the config/Parked/ directory of the R Node to config/Parked/ on the L Node

ssh ${RSSH} chown -R root ${NODE_BASE_DIR}/config/Parked
RES=$?
if [[ "$RES" != "0" ]]
then
	echo -ne "  Error: R chown failed\n\n"
	exit 1
else
	echo -ne "  Info: R chown done\n"
fi

ssh ${LSSH} mkdir -p ${NODE_BASE_DIR}/config/Parked
RES=$?
if [[ "$RES" != "0" ]]
then
	echo -ne "  Error: L mkdir failed\n\n"
	exit 1
else
	echo -ne "  Info: L mkdir done\n"
fi

scp -sr  ${RSSH}:${NODE_BASE_DIR}/config/Parked/. ${LSSH}:${NODE_BASE_DIR}/config/Parked/.
RES=$?

if [[ "$RES" != "0" ]]
then
	echo -ne "  Error: R to L copy failed\n\n"
	exit 1
else
	echo -ne "  Info: R to L copy done\n"
fi

# Delete the config/Parked/ directory on the R Node

ssh ${RSSH} rm -rf ${NODE_BASE_DIR}/config/Parked/
RES=$?

if [[ "$RES" != "0" ]]
then
	echo -ne "  Error: R clear failed\n\n"
	exit 1
else
	echo -ne "  Info: R clear done\n"
fi

# Rename the config/Parked-switch/ directory on the R Node to config/Parked/

ssh ${RSSH} mv ${NODE_BASE_DIR}/config/Parked-switch ${NODE_BASE_DIR}/config/Parked
RES=$?

if [[ "$RES" != "0" ]]
then
	echo -ne "  Error: R rename failed\n\n"
	exit 1
else
	echo -ne "  Info: R rename done\n"
fi

# Check both nodes are parked with check-parked

echo -ne "Check the LH node\n"
if ssh $LSSH icn-park-node check-parked
then
	echo -ne "  Info: LH server parked\n\n"
else
	echo -ne "  Error: LH server parking failed\n\n"
	exit 1
fi

echo -ne "Check the RH node\n"
if ssh $RSSH icn-park-node check-parked
then
	echo -ne "  Info: RH server parked\n\n"
else
	echo -ne "  Error: RH server parking failed\n\n"
	exit 1
fi

# Unpark both nodes with un-park

echo -ne "Un-park the LH node\n"
if ssh $LSSH icn-park-node un-park
then
	echo -ne "  Info: LH server un-parked\n\n"
else
	echo -ne "  Error: LH server un-parking failed\n\n"
	exit 1
fi

echo -ne "Check the RH node\n"
if ssh $RSSH icn-park-node un-park
then
	echo -ne "  Info: RH server un-parked\n\n"
else
	echo -ne "  Error: RH server un-parking failed\n\n"
	exit 1
fi
