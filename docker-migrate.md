# Using the docker-migrate utility in testnet

The docker-migrate utility has been created to ease the migration of Cudos nodes installed using the original docker based install process to a layout compatible with the native packaging based install process.

This documemnt has been drafted to summarise the process for migrating Cudos Testnet nodes from a Docker based to a native package based install.

It is advised that the following steps are taken in order

## Survey the node

Under docker the main payload data (the chain database) lives in an arbitrary location in the filesystem. It is often /usr/cudos/CudosData/xxxx but could be anywhere. Whereas the payload data lives in a fixed location on machines installed using the packaging ... /var/lib/cudos/cudos-data

While the docker-migrate script will find both of these locations automatically, it would be as well to check in advance that there is sufficient free space, as well as room for future data, under the directory /var/lib/cudos. If there isn't it would be best to adjust the filesystems on the node to make such space available.

If the host for the node is built as a single root filesystem, so the current database location and /var/lib/cudos/cudos-data are on the same filesystem, this check is not needed. In this case the docker-migrate process will simply move the data within the same filesystem and no additional space will be taken.

If however the existing chain data is on a subvolume, and /var/lib/cudos/cudos-data will actually be on a separate filesystem, the chain data will be copied, and so take up the same amount of space again on the target filesystem. The target filesystem, if no other preparations have been made will more than likely be the root filesystem, which in many cases is actually quite small. It is quite conventional to have a small root filesystem and to have any substantive amount of data held on a separate volume mounted into the root filesystem. In this case you will more than likely have to attach another volume at /var/lib/cudos to be able to handle the chain data.

NB Once the packages have been installed the directory /var/lib/cudos will have been created as the home directory of the 'cudos' user. This is where the chain database will be based, so it needs to have sufficient space to take this data. If a new cudos volume is to be created, make sure to copy the current content of /var/lib/cudos over to the new volume, preserving all the permissions and owenrship.

NB The directory /var/lib/cudos and everything under it should be owned by user cudos and group cudos

## Install the packages

First get to a root prompt on the node to be migrated, then....

Red Hat Family
```
dnf install -y yum-utils
dnf install -y http://jenkins.gcp.service.cudo.org/cudos/cudos-testnet/cudos-release.rpm
yum-config-manager --enable cudos-testnet
dnf install -y cudos-network-public-testnet
```

Debian Family
```
echo 'deb [trusted=yes] http://jenkins.gcp.service.cudo.org/cudos/cudos-testnet/debian stable main' > /etc/apt/sources.list.d/cudos.list
apt update
apt install cudos-network-public-testnet
```
For further reference, see the packager documentation at https://github.com/CudoVentures/cudos-noded-packager/blob/main/README.md#install-from-the-package-repository with particular reference to the Testnet commands for either Debian based or Red Hat based hosts as applicable.

## Run the migration

Once the packages are installed, all that is left is to run the docker-migrate tool while logged in as the root user.

First get to a root prompt on the node to be migrated, then....

```
docker-migrate
```

## Check the system

If the docker-migrate tool finished with no errors, you should be able to monitor the progress of the node using "cudos-gex" which was installed along with the cudos-noded software and other tools when the package set was installed.

You should also see blocks being indexed if the system log viewer is used to display the Journal

```
journalctl -f --since=-2m -u cosmovisor@cudos
```
