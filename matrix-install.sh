#!/bin/bash -x

echo -ne "Install Method: $matrix_method\n"
echo -ne "Agent:          $matrix_agent\n"
echo -ne "Node Type:      $matrix_node_type\n"
echo -ne "Cudos Network:  $matrix_cudos_network\n"

#
# Source low level install functions
#
for FNM in matrix-install.d/*.incl.sh
do
	source $FNM
done

#
# Docker vs Packaged functions
#
run-docker-install()
{
	case $1 in
		gce-centos8-docker)
			run-docker-centos8-install $2 $3
			;;
		gce-ubuntu2004-docker)
			run-docker-ubuntu2004-install $2 $3
			;;
		*) 
			echo -ne "\nError: Bad agent $1\n\n"
			exit 1
			;;
	esac
}

run-packaged-install()
{
	case $1 in
		gce-centos8-docker)
			run-packaged-centos8-install $2 $3
			;;
		gce-ubuntu2004-docker)
			run-packaged-ubuntu2004-install $2 $3
			;;
		*) 
			echo -ne "\nError: Bad agent $1\n\n"
			exit 1
			;;
	esac
}

#
# Outer case statement
#
case $matrix_method in
	docker)
		run-docker-install $matrix_agent $matrix_node_type $matrix_cudos_network
		;;

	package)
		run-packaged-install $matrix_agent $matrix_node_type $matrix_cudos_network
		;;

	*) 
		echo -ne "\nError: Bad install method $matrix_method\n\n"
		exit 1
		;;
esac
