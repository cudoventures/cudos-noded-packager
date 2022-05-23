# Cudos Daemon binary packaging

## Notes

The binary packages are produced by the scripting in this git repository, directly from
the code in the original git repositories and published on a "Proof of Concept" basis
for public download from yum/apt repositories.

Every Cudos Node major version has its own yum/apt repository to maintain separation while
still allowing security and utility upgrades to older versions.

The correct mix of package names and versions can be set up by installing a `Cudos Network
Pack`, which is another rpm/deb package that contains the relevant genesis
and node address files for the given network.

In order to allow easier integration of the various components the directory locations
for the daemon have been fixed and should remain at those locations. The `$CUDOS_HOME` variable
is preset to `/var/lib/cudos/cudos-data`, which is owned by the user `cudos` who's home
directory is `/var/lib/cudos`.

It is advised that all configuration editing operations be done as user `cudos` in
order to avoid permissions issues. Everything under `/var/lib/cudos` should be owned
by user `cudos`

The only operations that need root involvement are installing, upgrading and removing
the software packages and operations involing systemctl. It is advised that all other
operations are performed as either user `cudos` or as another non-priveledged user and specifically *not* as `root`. Doing 
so would leave files in the `$CUDOS_HOME` area that the user running the daemon (`cudos`)
cannot update.

Please be aware that this code and the repo service is being offered on a "Proof of Concept" basis.

Please see [License](LICENSE) for the license conditions under which this software is released. 

Please see the following details on how to install a Cudos node daemon using these binary packages, on a Linux system.

## Install direct from the package repository

The following is correct for public-testnet

#### Red Hat family (RHEL, CentOS & Fedora)

```bash
dnf install -y yum-utils
yum-config-manager --add-repo http://jenkins.gcp.service.cudo.org/cudos/cudos.repo
yum-config-manager --enable cudos-0.4
dnf install cudos-network-public-testnet
```

#### Debian and Ubuntu

```bash
echo 'deb [trusted=yes] http://jenkins.gcp.service.cudo.org/cudos/0.4/debian stable main' > /etc/apt/sources.list.d/cudos.list
apt update
apt install cudos-network-public-testnet
```

## Configure the daemon

The underlying network (in the above example, testnet) has already been configured
by the network pack, the only thing left is to set up the neighbour information.
This is done directy in the config.toml and app.toml files.

Tools are being developed to easily manage the neighbourhood connections and
perform other routine tasks and generic layouts.

Please see
  [cudos-noded-ctl](docs/cudos-noded-ctl.md)
  and
  [cudos-init-node.sh](SOURCES/cudos-init-node.sh)
  
If on a freshly installed node, the cudos-noded service is just started without any further configuration, the initialisation script [cudos-init-node.sh](SOURCES/cudos-init-node.sh) which is run by the systemd service file [cudos-noded.service](SOURCES/cudos-noded.service) will assume the `full-node` configuration.

If another config is needed, the [cudos-init-node.sh](SOURCES/cudos-init-node.sh) can be run to initialise the node as other node types

## Enable and start the daemon

```bash
systemctl enable --now cudos-noded
```

## Logs

As this daemon is controlled by systemd, the logs will naturally flow to journald 
and can be watched using the standard operating system tools .. eg:

```bash
journalctl -f -t cudos-noded
```

# Anatomy of a binary install

## The "cudos-noded" package
* [Package File List](http://jenkins.gcp.service.cudo.org/cudos/0.6.0/RPMS/x86_64/cudos-noded-0.6.0-67.el8.x86_64.rpm-lst.txt)
* [Package RPM Headers](http://jenkins.gcp.service.cudo.org/cudos/0.6.0/RPMS/x86_64/cudos-noded-0.6.0-67.el8.x86_64.rpm.txt)
* [Spec File](http://jenkins.gcp.service.cudo.org/cudos/0.6.0/SPECS/cudos-noded.spec)

### cudos-noded binary and library
The cudos-noded binary is installed in the standard system binary location "/usr/bin" and is owned by root.
The libarary is installed in /usr/lib
These binaries are built using the "make" command in the cudos-builders repo in the same way as the docker install.

### Systemd integration
The service can be stopped and started under systemd, integrating it seamlessly into the overall OS.

### Shell environment files to fix CUDOS_HOME
The Daemon user "cudos" is a machine account, so the LFHS suggests their data should be located under /var/lib. To this end the Cudos Node home area is fixed as the cudos-data subdirectory of the Cudos User's home directory "/var/lib/cudos".

## The Cudos Network Packs
* mainnet
  * [Package File List](http://jenkins.gcp.service.cudo.org/cudos/0.6.0/RPMS/x86_64/cudos-network-mainnet-0.6.0-30.el8.x86_64.rpm-lst.txt)
  * [Package RPM Headers](http://jenkins.gcp.service.cudo.org/cudos/0.6.0/RPMS/x86_64/cudos-network-mainnet-0.6.0-30.el8.x86_64.rpm.txt)
  * [Spec File](http://jenkins.gcp.service.cudo.org/cudos/0.6.0/SPECS/cudos-network-mainnet.spec)
* public-testnet
  * [Package File List](http://jenkins.gcp.service.cudo.org/cudos/0.4/RPMS/x86_64/cudos-network-public-testnet-0.4-13.el8.x86_64.rpm-lst.txt)
  * [Package RPM Headers](http://jenkins.gcp.service.cudo.org/cudos/0.4/RPMS/x86_64/cudos-network-public-testnet-0.4-13.el8.x86_64.rpm.txt)
  * [Spec File](http://jenkins.gcp.service.cudo.org/cudos/0.6.0/SPECS/cudos-network-public-testnet.spec)
* dressrehearsal
  * [Package File List](http://jenkins.gcp.service.cudo.org/cudos/0.6.0/RPMS/x86_64/cudos-network-dressrehearsal-0.6.0-45.el8.x86_64.rpm-lst.txt)
  * [Package RPM Headers](http://jenkins.gcp.service.cudo.org/cudos/0.6.0/RPMS/x86_64/cudos-network-dressrehearsal-0.6.0-45.el8.x86_64.rpm.txt)
  * [Spec File](http://jenkins.gcp.service.cudo.org/cudos/0.6.0/SPECS/cudos-network-dressrehearsal.spec)
   
These packs are mutually exclusive because they all supply the same set of files.

#### Genesis File
The file "/usr/cudos/cudos-data/config/genesis.json" is the core configuration file of the network on which this node is intended to operate. All nodes on the same netwprk should be using this exact genesis file.

#### Public Seed and Sentry Nodes
File containing lists of seeds and sentries and other useful nodenames. These are offered as "bootstrap files" to get the node conected to the rest of the nodes in the intneded network.

#### Specific upgrade scripts
Additional steps might be needed for specific updates of the software or chain-id. These will be delivered in the network package.

## The "cudos-gex" package
  * [Package File List](http://jenkins.gcp.service.cudo.org/cudos/0.6.0/RPMS/x86_64/cudos-gex-0.6.0-30.el8.x86_64.rpm-lst.txt)
  * [Package RPM Headers](http://jenkins.gcp.service.cudo.org/cudos/0.6.0/RPMS/x86_64/cudos-gex-0.6.0-30.el8.x86_64.rpm.txt)

The "Cosmos Gex" tool is a really useful console app to run on a node for debug purposes. It displays some basic information about the current state of the node. This package is supplied prebuilt as a utility only and is built directly from the Cosmos repository.

## The "cudos-monitoring" package
Those running system, OS and hardware monitoring systems like OMD/CHeckMK/Nagios or Prometheus/Grafana can install this package and gain access to package metrics, states and alerts to add to the OS and hardware metrics, states and alerts.

### CheckMK monitoring
The probes are installed as additional executable scripts in the ".../local/" plugins directory. The next full scan after the package has been installed on a running Cudos Node, the CUdos metrics for that node will become visible.

### Chronocollector
The cudos-noded daemon produces a considerable number of strategic metrics, which can be harvested and sent to prometheus front-ends using this package.

# Status

**Please be aware that none of the above is currently supported by Cudo Ventures in any way and is offered purely as a "Proof of Concept" and a working demonstration of a possible alternative way of installing Cudos Nodes in the future.**

