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
# of the config files and database.
#

#
# This needs to be rewritten in Go and folded in with cudos-noded (ADM 2022-05-23)
# But for now it needs to stay in Bash
#

#
# Check that this is being run as user cudos
#
if [[ "$( whoami )" != "cudos" ]]
then
	echo -ne "Error: $0 must be run as user cudos.\n\n"
	exit 1
fi

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
	exit 1
fi
rm -f "$TCHFILE"

#
# Check that there is a configuration
#
FNM="${CUDOS_HOME}/config/config.toml"
if [[ ! -f "${FNM}" ]]
then
	echo -ne "Error: '$FNM' file not found\n\n"
	exit 0
fi

FNM="${CUDOS_HOME}/config/app.toml"
if [[ ! -f "${FNM}" ]]
then
	echo -ne "Error: '$FNM' file not found\n\n"
	exit 0
fi

#
# Define individual parameter set functions
#
addrbook_clear()
{
  > "$CUDOS_HOME/config/addrbook.json"
}

set_config_seeds()
{
	FARG="` cat $1 `"
	sed -i -e'1,$s'"/^seeds =.*/seeds = \"$FARG\"/" "$CUDOS_HOME/config/config.toml"
}

set_config_persistent_peers()
{
	FARG="` cat $1 `"
	sed -i -e'1,$s'"/^persistent_peers =.*/persistent_peers = \"$FARG\"/" "$CUDOS_HOME/config/config.toml"
}

set_config_private_peers()
{
	FARG="` cat $1 `"
	sed -i -e'1,$s'"/^private_peers =.*/private_peers = \"$FARG\"/" "$CUDOS_HOME/config/config.toml"
}

set_config_unconditional_peers()
{
	FARG="` cat $1 `"
	sed -i -e'1,$s'"/^unconditional_peers =.*/unconditional_peers = \"$FARG\"/" "$CUDOS_HOME/config/config.toml"
}

set_config_pex()
{
	FARG="$1"
	sed -i -e'1,$s'"/^pex =.*/pex = $FARG/" "$CUDOS_HOME/config/config.toml"
}

set_config_unsafe()
{
	FARG="$1"
	sed -i -e'1,$s'"/^unsafe =.*/unsafe = $FARG/" "$CUDOS_HOME/config/config.toml"
}

set_config_prometheus()
{
	FARG="$1"
	sed -i -e'1,$s'"/^prometheus =.*/prometheus = $FARG/" "$CUDOS_HOME/config/config.toml"
}

set_config_seed_mode()
{
	FARG="$1"
	sed -i -e'1,$s'"/^seed_mode =.*/seed_mode = $FARG/" "$CUDOS_HOME/config/config.toml"
}

set_config_minimum-gas-prices()
{
	FARG="$1"
	sed -i -e'1,$s'"/^minimum-gas-prices =.*/minimum-gas-prices = $FARG/" "$CUDOS_HOME/config/app.toml"
}

#
# Function to set configuration values in cudos-noded config.toml and app.toml
#
config_set()
{
  CONF_NAME="$1"
  shift
  CONF_VAL="$*"

  case $CONF_NAME in
    seeds)               set_config_seeds "$CONF_VAL" ;;
    persistent_peers)    set_config_persistent_peers "$CONF_VAL" ;;
    private_peers)       set_config_private_peers "$CONF_VAL" ;;
    unconditional_peers) set_config_unconditional_peers "$CONF_VAL" ;;
    pex)                 set_config_pex "$CONF_VAL" ;;
    unsafe)              set_config_unsafe "$CONF_VAL" ;;
    prometheus)          set_config_prometheus "$CONF_VAL" ;;
    seed_mode)           set_config_seed_mode "$CONF_VAL" ;;
    minimum-gas-prices)  set_config_minimum-gas-prices "$CONF_VAL" ;;

    *) echo "Unknown Node Config Name: $CONF_NAME"; exit;;
  esac
}

#
# Parse and execute the command line
#
while getopts "hf:" arg
do
  case $arg in
    h)
      echo "$0 [-h] <command> [command_options]" 
      ;;
  esac
done

export IP_COMMAND="$1"
shift

case $IP_COMMAND in
  set)
    config_set $*
    ;;
  genesis_md5)
    md5sum /var/lib/cudos/cudos-data/config/genesis.json
    ;;
  genesis_dump)
    cat /var/lib/cudos/cudos-data/config/genesis.json
    ;;
  addrbook_clear)
    addrbook_clear
    ;;
  *)
    echo "Unknown command: $IP_COMMAND $*"
    ;;
esac

