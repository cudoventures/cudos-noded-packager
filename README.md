# Cudos Daemon binary packaging

## Notes

The binary packages are produced by the scripting in this git repository, directly from
the code in the original git repositories and published on a "Proof of Concept" basis
for public download from yum/apt repositories.

The correct mix of package names and versions can be set up on a target machine by installing a `Cudos Network
Pack`, which is another rpm/deb package that contains the relevant genesis
and node address files for the given network, along with the relevant Cosmovisor config files.

Every Cudos Node major version has its own yum/apt repository to maintain separation while
still allowing security and utility upgrades to older versions, although with the adoption
of the Cosmovisor tool this is going to change in the near future. In the future the different
networks and versions will be handled by the "cudos-network-???" packages.

In order to allow easier integration of the various components the directory locations
for the daemon have been fixed and should remain at those locations. The `$CUDOS_HOME` variable
is preset to `/var/lib/cudos/cudos-data`, which is owned by the user `cudos` who's home
directory is `/var/lib/cudos`.

It is advised that all configuration editing operations be done as user `cudos` in
order to avoid permissions issues. Everything under `/var/lib/cudos` should be owned
by user `cudos`. The cudos-noded-ctl script, used for configuring the .toml files will
refuse to run as anything other than user cudos for this reason.

The only operations that need root involvement are installing, upgrading and removing
the software packages and operations involving systemctl. It is advised that all other
operations are performed as either user `cudos` or as another non-priviledged user and specifically *not* as `root`. Doing 
so would leave files in the `$CUDOS_HOME` area that the user running the daemon (`cudos`)
cannot update.

Please be aware that this code and the repo service is being offered on a "Proof of Concept" basis,
although it is now being considered as the production method for the future.

Please see [License](LICENSE) for the license conditions under which this software is released. 

Please see the following details on how to install a Cudos node daemon using these binary packages, on a Linux system.

## Install from the package repository

Install the Network Pack for the Cudos blockchain network you want this node to be on, in whatever capacity.
The network pack contains the genesis.json file and the initial seed and RPC connection information needed to get the node connected.

The packages used to install the different networks are:
* cudos-network-mainnet
* cudos-network-public-testnet
* cudos-network-private-testnet

NB The packs are mutually exclusive, they share the same filenames.
Using this system of packaging, any given host can only be on one Cudos network at any one time.

The following examples are correct for Cudos Mainnet.

#### Red Hat family (RHEL, CentOS & Fedora)

```bash
dnf install -y yum-utils
yum-config-manager --add-repo http://jenkins.gcp.service.cudo.org/cudos/cudos.repo
yum-config-manager --enable cudos-1.0.0
dnf install cudos-network-mainnet
```

#### Debian and Ubuntu

```bash
echo 'deb [trusted=yes] http://jenkins.gcp.service.cudo.org/cudos/1.0.0/debian stable main' > /etc/apt/sources.list.d/cudos.list
apt update
apt install cudos-network-mainnet
```

## Configure the daemon

The underlying network (in the above example, mainnet) has already been configured
by the Network Pack, the only thing left to get this node synchronized with
the network is to set up the neighbour information.
This is done directly in the config.toml and app.toml files by `cudos-noded-ctl`.
Please see [cudos-noded-ctl](docs/cudos-noded-ctl.md)

For an example of how the `cudos-noded-ctl` command is to be used, please see
[cudos-init-node.sh](SOURCES/cudos-init-node.sh)

If you start the cudos-noded service on a freshly installed node without any .toml
configuration files, the initialisation script [cudos-init-node.sh](SOURCES/cudos-init-node.sh) which
is run by the systemd service file [cudos-cosmovisor.service](SOURCES/cudos-cosmovisor.service) will assume
the `full-node` configuration is required and configure `config.toml` and `app.toml` accordingly.

If a node type other than `full-node` is needed, run [cudos-init-node.sh](SOURCES/cudos-init-node.sh) with
an argument to initialise the node as another node type **before** the node is started for the first time.

Node types available are:
* `full-node`
* `clustered-node`
* `seed-node`
* `sentry-node`

### Clustered Nodes

If the intent is to build a Cudos Node Cluster for a Clustered Validator the `clustered-node` type is used for the validator.

```bash
cudos-init-node.sh clustered-node
```
The usual seed and sentry node types are used when building the cluster's seeds and sentries.

Once the Clustered Node and its associated seeds and sentries have been configured, started and synchronized,
the Clustered Node can then be staked as a Clustered Validator.

NB If the node is intended to be a member of a cluster of Cudos Nodes, and as such requires specific seeds,
sentries, private peers amd unconditional peers, it is important to also configure the peer files.
Please see [cudos-noded-ctl](docs/cudos-noded-ctl.md) for further details.

### Solo Nodes

If a Solo Validator is needed, a basic `full-node` can be staked, much as a `clustered-node` was staked to create a Clustered Validator.

If it is intended that the Validator, Full Node, Seed or Sentry is to sit on it's own with no specific
peers, the default neighbour information can be used for any of the non-clustered node types.

If a clustered-node is left to the default neighbour configuration it will not try and connect to any other node
and will just stall indefinitely waiting for chain infomation. As soon as another node contacts it, the
synchronisation process will being.

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
As this service is controlled by the cosmovisor daemon, the binary and library are installed in cosmovisor's
work area (/var/lib/cudos/cudos-data/cosmovisor/).

These binaries are built using the "make" command in the cudos-builders repo in the same way as the docker install.

There is in addition a link to the current cudos-noded binary installed in the standard system binary location "/usr/bin"
and a link for the library library installed in "/lib64".


### Systemd integration
The service can be stopped and started under systemd, integrating it seamlessly into the overall OS.

### Shell environment files to fix CUDOS_HOME
The Daemon user "cudos" is a machine account, so the LFHS suggests their data should be located under /var/lib.
To this end the Cudos Node home area is fixed as the cudos-data subdirectory of the Cudos User's home directory "/var/lib/cudos".

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
The file "/usr/cudos/cudos-data/config/genesis.json" is the core configuration file of the network on which
this node is intended to operate. All nodes on the same network should be using this exact genesis file.
The "cudos-network-<Network Name>" packages install the relevant file for the network.

#### Public Seed and Sentry Nodes
File containing lists of seeds and sentries and other useful node names. These are offered as "bootstrap files"
to get the node connected to the rest of the nodes in the intended network.

#### Specific upgrade scripts
Additional steps might be needed for specific updates of the software or chain-id.
These will be delivered in the network package and executed as appropriate by Cosmovisor.

## The "cudos-gex" package
  * [Package File List](http://jenkins.gcp.service.cudo.org/cudos/0.6.0/RPMS/x86_64/cudos-gex-0.6.0-30.el8.x86_64.rpm-lst.txt)
  * [Package RPM Headers](http://jenkins.gcp.service.cudo.org/cudos/0.6.0/RPMS/x86_64/cudos-gex-0.6.0-30.el8.x86_64.rpm.txt)

The "Cosmos Gex" tool is a really useful console app to run on a node for debug purposes.
It displays some basic information about the current state of the node.
This package is supplied prebuilt as a utility only and is built directly from the Cosmos repository unchanged.
The binary's name is cudos-gex in order to differentiate it from other installations of Cosmos Gex and from other
OS binaries that are also called gex. 

## The "cudos-monitoring" package
Those running system, OS and hardware monitoring systems like OMD/CHeckMK/Nagios or Prometheus/Grafana can
install this package and gain access to package metrics, states and alerts to add to the OS and hardware metrics, states and alerts.

### CheckMK monitoring
The probes are installed as additional executable scripts in the ".../local/" plugins directory.
The next full scan after the package has been installed on a running Cudos Node, the Cudos metrics
for that node will become visible.

### Chronocollector
The cudos-noded daemon produces a considerable number of strategic metrics, which can be harvested
and sent to prometheus/Chronosphere front-ends using this package.

# Status

**Please be aware that none of the above is currently supported by Cudo Ventures in any way and is
offered purely as a "Proof of Concept" and a working demonstration of a possible alternative way
of installing Cudos Nodes in the future.**

