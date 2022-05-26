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

gce-centos8-builder-install()
{
	set -x
	
	export CUDOS_NETWORK="$1"
	export NODE_TYPE="$2"

	sudo dnf install -y yum-utils
	sudo yum-config-manager --add-repo http://jenkins.gcp.service.cudo.org/cudos/cudos.repo

    echo -ne "\n\n     Install a $NODE_TYPE on $CUDOS_NETWORK\n\n"

	#
	# Select repository and install the packages based on CUDOS_NETWORK
	#
	case $CUDOS_NETWORK in
		mainnet)
			YUMREPO=cudos-0.6.0
			NETPACK=cudos-network-mainnet
			;;
		dressrehearsal)
			YUMREPO=cudos-0.6.0
			NETPACK=cudos-network-dressrehearsal
			;;
		public-testnet)
			YUMREPO=cudos-0.4
			NETPACK=cudos-network-public-testnet
			;;
		private-testnet)
			YUMREPO=cudos-0.8.0
			NETPACK=cudos-network-private-testnet
			;;
	esac
	
	#
    # Set the yum repository to $YUMREPO
	#
	if ! sudo yum-config-manager --enable "${YUMREPO}"
	then
		echo -ne "\nError: Repository switch to ${YUMREPO} failed\n\n"
		exit 1
	fi
		
	#
	# Install the packages
	#
	if ! sudo dnf install -y ${NETPACK} cudos-noded cudos-gex cudos-monitoring
	then
		echo -ne "\nError: dnf install failed\n\n"
		exit 1
	fi
			
	#
	# Set the CUDOS_HOME variable using the profile
	# just installed through the cudos-noded package
	#
	source /etc/profile.d/cudos-noded.sh

	#
	# Initialise the node using the node type
	#
	if ! sudo -u cudos /usr/bin/cudos-init-node.sh $NODE_TYPE
	then
		echo -ne "\nError: cudos-init-node.sh returned an error\n\n"
		exit 1
	fi
	
	#
	# Enable and start the cudos-noded service
	#
	if ! sudo systemctl enable --now cudos-noded
	then
		echo -ne "\nError: Service enable failed\n\n"
		exit 1
	fi
		

	#
	# Hang around a bit to let some logs build up
	#
	echo -ne "Sleeping for 120 seconds\n"
	sleep 120

	#
	# Dump the log since boot for cudos-noded both to the screen
	# for the CI/CD job log, and to a logfile for export as an
	# artifact
	#
	journalctl -b -t cudos-noded | tee log-${CUDOS_NETWORK}_-_${NODE_TYPE}.txt
	
}

