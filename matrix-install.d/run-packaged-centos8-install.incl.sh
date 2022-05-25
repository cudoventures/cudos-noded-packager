run-packaged-centos8-install()
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
		public-testnet)
			sudo yum-config-manager --enable cudos-0.4
			sudo dnf install -y cudos-network-public-testnet
			;;
		private-testnet)
			sudo yum-config-manager --enable cudos-0.8.0
			sudo dnf install -y cudos-network-private-testnet
			;;
	esac
	
	sudo dnf install cudos-gex cudos-monitoring

	export CUDOS_HOME=/var/lib/cudos/cudos-data

	./SOURCES/cudos-init-node.sh $NODE_TYPE
	
	sudo systemctl enable --now cudos-noded

	sleep 120

	journalctl -b -t cudos-noded
}

