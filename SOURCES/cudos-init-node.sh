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
##########################################################################

########################################
# Initial safety and environment checks
########################################
#
# Check that this is being run as user cudos
#
if [[ "$( whoami )" != "cudos" ]]
then
    echo -ne "Error: $0 must be run as user cudos.\n\n"
    exit 1
fi

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

########################################
# Set up node type and run mode
########################################
#
# Parse command line aruments
#

print_help()
{
cat<<EOF

 Usage: cudos-init-node.sh [--help|--init|--reinit|--reconfig|--scan-peers] [node-type]

 NB For backward compatibility, if there are no arguments on the command line, the
    default behaviour of this script is "--init full-node"

 If [node-type] is not given, node type "full-node" is assumed

 -h | --help - Prints this help text

 -i | --init - Initialises and configures the node

   Requires the machine to be unconfigured and will exit with an error if the machine
   has any existing configuration. Runs "cudos init" followed by the configurator using
   the "node-type" given or "full-node" if no arguments present.

 -r | --reinit - Reinitialises and configures an already configured and initialised node

   This optioin is comparable to --init only for nodes that have already been configured.
   Removes the existing config.toml & app.toml and then runs "cudos init" followed by
   the configurator using the "node-type" given or "full-node" if no arguments present.

   Intended to "start again" on an existing node

 -c | --configure - Rebuilds the .toml files

   Reruns the toml file configuration step for that node type.

   NB Unlike --init this option is intended to be run on already configured nodes
   NB Unlike --init & --reinit this option has no effect on the database, it just updates the toml files

 -s | --scan-peers - Checks the connectivity with the declared peers and seeds

   Pick out the configured seeds and sentries from the toml files and uses cudos-p2p-scan to check
   their connectivity.

   NB Does not change the configuration. This is a read only operation.

EOF
}

TEMP=$(getopt -o hircs --long help,init,reinit,configure,scan-peers -n 'cudos-noded-init.sh' -- "$@")

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

# Note the quotes around '$TEMP': they are essential!
eval set -- "$TEMP"

OPT_INIT=false
OPT_REINIT=false
OPT_CONFIGURE=false
OPT_SCAN_PEERS=false
while true; do
  case "$1" in
    -h | --help )       RUN_MODE="help";       shift ;;
    -i | --init )       RUN_MODE="init";       shift ;;
    -r | --reinit )     RUN_MODE="reinit";     shift ;;
    -c | --configure )  RUN_MODE="configure";  shift ;;
    -s | --scan-peers ) RUN_MODE="scan-peers"; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

# Set type name from the first remaining command line argument
TYPE_NAME="$1"

# Set to "full-node" if no node type given
if [[ "$TYPE_NAME" = "" ]]
then
    TYPE_NAME="full-node"
fi
export TYPE_NAME

# Set run mode to "init" if no mode given
if [[ "$RUN_MODE" = "" ]]
then
    RUN_MODE="init"
fi

########################################
# Execute the required procedures
########################################
#
# Print the help text and exit if -h or --help given
#
if [[ "$RUN_MODE" = "help" ]]
then
    print_help
    exit 0
fi

#
# Check to see if there is already a configuration
# which is fatal in run mdoe "init"
#
for FNM in "${CUDOS_HOME}/config/config.toml" "${CUDOS_HOME}/config/app.toml"
do
if [[ -f "${FNM}" && "$RUN_MODE" = "init" ]]
    then
        echo -ne "Error: Cannot initialise, $FNM already present\nConsider using --reinit\n\n"
        exit 1
    fi
done

#
#  if run mode init or reinit requested, initialise the node using "cudos-noded init"
#
if [[ "$RUN_MODE" = "init" || "$RUN_MODE" = "reinit" ]]
then
    TMPFN="${CUDOS_HOME}/config/genesis.json-$$"
    mv -f "$CUDOS_HOME"/config/genesis.json "$TMPFN"

    echo "Info: Initialising node with 'cudos-noded init $HOSTNAME'"
    cudos-noded init "$HOSTNAME" 2>/tmp/genesis.$$.json
    if [[ $? -ne 0 ]]
    then
        echo -ne "Error: cudos-noded init failed\n\n"
        cat /tmp/genesis.$$.json
        mv -f "$TMPFN" "$CUDOS_HOME"/config/genesis.json
        exit 1
    fi

    mv -f "$TMPFN" "$CUDOS_HOME"/config/genesis.json
fi

#
# Configuration step
#
if [[ "$RUN_MODE" = "init" || "$RUN_MODE" = "reinit" || "$RUN_MODE" = "configure" ]]
then
    #
    # Select behaviour based on the node type name given
    #
    echo "Info: Configuring node as a $TYPE_NAME"

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
    
            cudos-noded-ctl set seeds ""
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
fi 

#
# Run the peer scan
#
if [[ "$RUN_MODE" = "scan-peers" ]]
then
    SEED_LIST=` grep "^seeds =" ${CUDOS_HOME}/config/config.toml | sed -e's/^seeds = "//' | sed -e's/"$//' | tr "," " "`
    SENTRY_LIST=` grep "^persistent_peers =" ${CUDOS_HOME}/config/config.toml | sed -e's/^persistent_peers = "//' | sed -e's/"$//' | tr "," " "` 

    echo -e "\nSeeds:"
    for HOST_ADDR in $SEED_LIST
    do
        echo "- Full Address: $HOST_ADDR"
        IPPRT="$( echo $HOST_ADDR | sed -e's/^.*@//' )"
	cudos-p2p-scan $IPPRT
    done

    echo -e "\nPersistent Peers:"
    for HOST_ADDR in $SENTRY_LIST
    do
        echo "- Full Address: $HOST_ADDR"
        IPPRT="$( echo $HOST_ADDR | sed -e's/^.*@//' )"
	cudos-p2p-scan $IPPRT
    done
fi
