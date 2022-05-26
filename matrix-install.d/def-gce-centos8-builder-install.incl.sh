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

centos8-builder-install()
{
	export NODE_TYPE="$1"
	export CUDOS_NETWORK="$2"

	sudo dnf install -y yum-utils
	sudo yum-config-manager --add-repo http://jenkins.gcp.service.cudo.org/cudos/cudos.repo

        echo -ne "Install a $NODE_TYPE on $CUDOS_NETWORK\n"

	#
	# Select repository based on network
	#
	case $CUDOS_NETWORK in
		mainnet)
			sudo yum-config-manager --enable cudos-0.6.0
			sudo dnf install -y cudos-network-mainnet
			;;
		dressrehearsal)
			sudo yum-config-manager --enable cudos-0.6.0
			sudo dnf install -y cudos-network-dressrehearsal
			;;
		public-testnet)
			sudo yum-config-manager --enable cudos-0.4
			sudo dnf install -y cudos-network-public-testnet
			;;
		private-testnet)
			sudo yum-config-manager --enable cudos-0.8.0
			sudo dnf install -y cudos-network-private-testnet
			;;
	esac
	
	source /etc/profile.d/cudos-noded.sh

	./SOURCES/cudos-init-node.sh $NODE_TYPE
	
	sudo systemctl enable --now cudos-noded

	sleep 120

	journalctl -b -t cudos-noded
}

