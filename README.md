# Generic Cosmos Daemon binary packaging

## Why Packaging

One of the key attractions of the Cosmos blockchain daemon family is that nodes can communicate with each other across different chains and pass tokens around seamlessly in encapsulations, and maybe switch them for other tokens through liquidity pools, with novel uses and new specialisations popping up all the time; while still allowing the different Cosmos based blockchains to focus on their own particular reason for being by crreating novel functions that can naturally integrate with everyone else.

However, in order for this to be realised on the ground, the various software components of this ecosystem must remain up and running, and up to date with chain upgrades and operating system software changes.

It's tempting to think that every new problem is unique and new, but this one isn't. The machine underneath the blockchain daemons and apps, is immensely more complex than the apps they're deployed to sustain; and contain orders of magnitudes more code. So how was the entirity of the rest of the operating system needed to run one of these daemons, installed. It was laced together with a dependancy chain of operating system packages. Be they Debian style .deb files, or Red Hat style .rpm .. or indeed any of the other package styles used for other platforms. There is no good reason why the Cosmos family of daemons and apps couldn't be built for Android, iThing, and certainly for the ARM chip family in general.

In order for this to be realised, this whole stack of software needs to become as much **part of the fabric of computing** as any other applications the operating system might have been put there to sustain, and to do that, it needs to be just another option on the panel of things you might want to install on this box/tablet/phone.

## The Generic Package Structure

The intent of this package structure is to be **chain agnostic**, with the end goal of making the choice of network and chain a tick box to which newcomers can easily be added. While allowing the individual Cosmos Daemon projects full reign to evolve their contribution to suite their own plans.

## Top Level Package

For a fully working system to be set up for the chosen network, one package is required, the so called "**Network Package**". This contains the unique files for that network, such as the genesis and the bootstrap seed servers, but nothing else. For example:

```bash
[root@cudos ~]# rpm -ql cudos-network-public-testnet
/var/lib/cudos/cudos-data
/var/lib/cudos/cudos-data/config
/var/lib/cudos/cudos-data/config/genesis.json
/var/lib/cudos/cudos-data/config/persistent-peers.config
/var/lib/cudos/cudos-data/config/private-peers.config
/var/lib/cudos/cudos-data/config/seeds.config
/var/lib/cudos/cudos-data/config/state-sync-rpc-servers.config
/var/lib/cudos/cudos-data/config/unconditional-peers.config
```

It does however enforce a set of requirements for other packages.

```bash
[root@cudos ~]# rpm -q --requires cudos-network-public-testnet
/bin/sh
cudos-gex
cudos-noded
cudos-noded-v0.9.0
cudos-noded-v1.0.0
cudos-p2p-scan
rpmlib(CompressedFileNames) <= 3.0.4-1
rpmlib(FileDigests) <= 4.6.0-1
rpmlib(PayloadFilesHavePrefix) <= 4.0-1
rpmlib(PayloadIsXz) <= 5.2-1
```

Which includes the binary packages (eg cudos-noded-v0.9.0 & cudos-noded-v1.0.0) and the framework package for that project (eg cudos-noded).

Therefore, by installing just that top level package, you will bring in all the right components for that specific network for that network project.

## Install from the package repository

Install the Network Pack for the blockchain network you want this node to be on, in whatever capacity.
The network pack contains the genesis.json file and the initial seed and RPC connection information needed to get the node connected.

The packages used to install the different networks are:
* cudos-network-mainnet
* cudos-network-public-testnet
* cudos-network-private-testnet
* osmosis-network-testnet
* osmosis-network-mainnet

NB The packs are mutually exclusive, they share the same filenames.
Currently, any given host can only run a daemon on one network at any one time.

NB These commands must all be run as root.

**Just putting "sudo" before some of these commands does not work.**

If you run the command "**sudo -i**", assuming you have permissions to do so, you will get a root prompt.

#### Red Hat family

Known Working:
- RHEL/CentOS/EL 8
- Fedora 34 & 35

For Private Testnet
```bash
dnf install -y yum-utils
dnf install http://jenkins.gcp.service.cudo.org/cudos/cudos-prtn/cudos-release.rpm
yum-config-manager --enable cudos-prtn
dnf install cudos-network-private-testnet
```

For Public Testnet
```bash
dnf install -y yum-utils
dnf install http://jenkins.gcp.service.cudo.org/cudos/cudos-testnet/cudos-release.rpm
yum-config-manager --enable cudos-testnet
dnf install cudos-network-public-testnet
```

For Mainnet
```bash
dnf install -y yum-utils
dnf install http://jenkins.gcp.service.cudo.org/cudos/cudos-mainnet/cudos-release.rpm
yum-config-manager --enable cudos-mainnet
dnf install cudos-network-mainnet
```

#### Debian Family

Known Working:
- Debian 10
- Ubuntu 20.04

For Private Testnet
```bash
echo 'deb [trusted=yes] http://jenkins.gcp.service.cudo.org/cudos/cudos-prtn/debian stable main' > /etc/apt/sources.list.d/cudos.list
apt update
apt install cudos-network-private-testnet
```

For Public Testnet
```bash
echo 'deb [trusted=yes] http://jenkins.gcp.service.cudo.org/cudos/cudos-testnet/debian stable main' > /etc/apt/sources.list.d/cudos.list
apt update
apt install cudos-network-public-testnet
```

For Mainnet
```bash
echo 'deb [trusted=yes] http://jenkins.gcp.service.cudo.org/cudos/cudos-mainnet/debian stable main' > /etc/apt/sources.list.d/cudos.list
apt update
apt install cudos-network-mainnet
```
### The software is now installed

You now have all the necessary binary and configuration files to start and operate the Cosmos Node or to use the locally installed system to connect to a node elsewhere.

## Get it running

### Configure the daemon

The underlying network (for example, Cudos Public Testnet) has already been configured
by the Network Pack, all that's left is to set the node's role and configure the neighbour
information, and it can then synchronize with the chosen network.

**If necessary**, this can be done by setting each individual parameter separately, directly in the config.toml and
app.toml files, using the specific daemon configuration tool for the network. In the
case of the Cudos network, this would be `cudos-noded-ctl`.
Please see [cudos-noded-ctl](docs/cudos-noded-ctl.md).

**However** in the case of the Cudos network, there is an additional higher level tool
that can set the node's configuration up in one go, please see
[cudos-init-node.sh](SOURCES/cudos-init-node.sh) for a more detailed explanation.

**Before you start the daemon's service** on a freshly installed node without any .toml
configuration files, the initialisation script must be run. In the case of the Cudos
network for example this would be [cudos-init-node.sh](SOURCES/cudos-init-node.sh)

If a node type other than `full-node` is needed, run [cudos-init-node.sh](SOURCES/cudos-init-node.sh) with
an argument to initialise the node as another node type **before** the node is started for the first time.

Node types available are:
* `full-node`
* `clustered-node`
* `seed-node`
* `sentry-node`

See following for specific examples

#### Full Nodes (Default)

If the script is run with no arguments, it will assume the `full-node` configuration
is required and configure `config.toml` and `app.toml` accordingly.

```bash
cudos-init-node.sh
```

#### Clustered Nodes

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

#### Solo Nodes

If a Solo Validator is needed, a basic `full-node` can be staked, much as a `clustered-node` was staked to create a Clustered Validator.

If it is intended that the Validator, Full Node, Seed or Sentry is to sit on it's own with no specific
peers, the default neighbour information can be used for any of the non-clustered node types.

If a clustered-node is left to the default neighbour configuration it will not try and connect to any other node
and will just stall indefinitely waiting for chain infomation. As soon as another node contacts it, the
synchronisation process will being.

#### Seed Nodes

```bash
cudos-init-node.sh seed-node
```

#### Sentry Nodes

```bash
cudos-init-node.sh sentry-node
```

#### The node is now configured

The node now has the right network setuo information, and is configured as the desired node type. All that is left is to enable and start the service.

### Systemd Service

The different operating system services on most modern Linux systems are managed by systemd, and this is also the case for the Cosmos node. The service configuration envokes the "**cosmovisor**" utility to select the right version of the daemon and to stop and start it as appropriate.

The Cosmovisor daemon service configuration can be found in the systemd service file [cosmovisor@.service](SOURCES/cosmovisor@.service)

This is done using a so called "parameterised service" in that the same service configuration file can be used across different contexts with the use of a parameter. The parameter in this case, is the project name:
- cudos
- osmosis
- (more to follow)

For example, so see the status of the Osmosis daemon

```bash
root@osmosis-testnet-node:~# systemctl status cosmovisor@osmosis
● cosmovisor@osmosis.service - Cosmovisor Daemon for chain osmosis
   Loaded: loaded (/lib/systemd/system/cosmovisor@.service; enabled; vendor preset: enabled)
   Active: active (running) since Sat 2022-08-20 00:55:09 UTC; 24min ago
 Main PID: 18424 (cosmovisor)
    Tasks: 19 (limit: 4915)
   Memory: 3.4G
   CGroup: /system.slice/system-cosmovisor.slice/cosmovisor@osmosis.service
           ├─18424 /usr/bin/cosmovisor start --home /var/lib/osmosis/.osmosisd --log_level info
           └─18430 /var/lib/osmosis/.osmosisd/cosmovisor/upgrades/v11/bin/osmosisd start --home /var/lib/osmosis/.osmosisd --log_level info

Aug 20 01:19:42 osmosis-testnet-node cosmovisor[18424]: 1:19AM INF committed state app_hash=DD719ABB0C6ADD95CC42C9F397F4D3836D148A0B4226
Aug 20 01:19:42 osmosis-testnet-node cosmovisor[18424]: 1:19AM INF indexed block height=6215166 module=txindex
```

.. Or the cudos daemon

```bash
[root@cudos ~]# systemctl status cosmovisor@cudos
● cosmovisor@cudos.service - Cosmovisor Daemon for chain cudos
   Loaded: loaded (/usr/lib/systemd/system/cosmovisor@.service; enabled; vendor preset: disabled)
   Active: active (running) since Fri 2022-08-19 15:05:33 BST; 11h ago
 Main PID: 2843165 (cosmovisor)
    Tasks: 34 (limit: 99834)
   Memory: 2.0G
   CGroup: /system.slice/system-cosmovisor.slice/cosmovisor@cudos.service
           ├─2843165 /usr/bin/cosmovisor start --home /var/lib/cudos/.cudosd --log_level info
           ├─2843171 /var/lib/cudos/cudos-data/cosmovisor/upgrades/v0.9.0/bin/cudos-noded start --home /var/lib/cudos/.cudosd --log_level info
           └─2843186 /usr/bin/dbus-daemon --syslog --fork --print-pid 4 --print-address 6 --session

Aug 20 02:21:12 cudos.ch.anvil.org cosmovisor[2843171]: 2:21AM INF received complete proposal block hash=170236F992A6DE12AD0FCF79B2CB76461F50366AC6EEB4CA90A8>
Aug 20 02:21:13 cudos.ch.anvil.org cosmovisor[2843171]: 2:21AM INF finalizing commit of block hash=170236F992A6DE12AD0FCF79B2CB76461F50366AC6EEB4CA90A8765BD6>
```

The cosmovisor daemon then works with the correct binary for that network.

In the Osmosis example:

```bash
/var/lib/osmosis/.osmosisd/cosmovisor/upgrades/v11/bin/osmosisd start --home /var/lib/osmosis/.osmosisd --log_level info
```

Using the version subdirectory selected by cosmovisor

```bash
/var/lib/osmosis/.osmosisd/cosmovisor/upgrades/v11
```

See below for examples of how to use the systemctl command to control the Cosmos daemon

### Managing the Service

#### Enable and Start the service

```bash
[root@cudos ~]# systemctl enable --now cosmovisor@cudos
Created symlink /etc/systemd/system/multi-user.target.wants/cosmovisor@cudos.service → /usr/lib/systemd/system/cosmovisor@.service.
```

#### Disable and Stop the Service

```bash
[root@cudos ~]# systemctl disable --now cosmovisor@cudos
Removed /etc/systemd/system/multi-user.target.wants/cosmovisor@cudos.service.
```

#### Cosmovisor Daemon version and configuration

The cosmovisor daemon can also work in client mode and can transfer commands direct to the daemon running the Cosmos Service

```bash
root@osmosis-testnet-node:~# cosmovisor version
Cosmovisor Version:  
2:21AM INF Configuration is valid:
Configurable Values:
  DAEMON_HOME: /var/lib/osmosis/.osmosisd
  DAEMON_NAME: osmosisd
  DAEMON_ALLOW_DOWNLOAD_BINARIES: false
  DAEMON_RESTART_AFTER_UPGRADE: true
  DAEMON_POLL_INTERVAL: 300ms
  UNSAFE_SKIP_BACKUP: true
  DAEMON_PREUPGRADE_MAX_RETRIES: 0
Derived Values:
        Root Dir: /var/lib/osmosis/.osmosisd/cosmovisor
     Upgrade Dir: /var/lib/osmosis/.osmosisd/cosmovisor/upgrades
     Genesis Bin: /var/lib/osmosis/.osmosisd/cosmovisor/genesis/bin/osmosisd
  Monitored File: /var/lib/osmosis/.osmosisd/data/upgrade-info.json
 module=cosmovisor
2:21AM INF running app args=["version"] module=cosmovisor path=/var/lib/osmosis/.osmosisd/cosmovisor/upgrades/v11/bin/osmosisd
11.0.0
```

NB "11.0.0" is the results of calling the underlying Cosmos Daemon with the argument "version"

## Logs

As this daemon is controlled by systemd, the logs will naturally flow to journald 
and can be watched using the standard operating system tools.

eg:
```bash
journalctl -f -u cosmovisor@cudos
```
or
```bash
journalctl -f -u cosmovisor@osmosis
```

# Anatomy of a binary install

## The Client Package
* [cudos-noded.spec](SPECS/cudos-noded.spec)
* [osmosisd.spec](SPECS/osmosisd.spec)

This contains any specific configurations required for the project in general, irrespective of version.

```bash
root@osmosis-testnet-node:~# dpkg -L osmosisd
/.
/etc
/etc/default
/etc/default/cosmovisor
/usr
/usr/bin
/usr/bin/osmosis-init-node.sh
/usr/bin/osmosisd-ctl
/usr/share
/usr/share/doc
/usr/share/doc/osmosisd
/usr/share/doc/osmosisd/changelog.Debian.gz
/usr/share/doc/osmosisd/copyright
```

It also ensures that the user can use the daemon in client mode for TX commands and other such activity



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
* Cudos Mainnet
  * [cudos-network-mainnet.spec](SPECS/cudos-network-mainnet.spec)
* Cudos Public Testnet
  * [cudos-network-public-testnet.spec](SPECS/cudos-network-public-testnet.spec)
* Cudos Private Testnet
  * [cudos-network-private-testnet.spec](SPECS/cudos-network-private-testnet.spec)
   
These packs are mutually exclusive because they all supply the same set of files.

#### Genesis File
The file ".../config/genesis.json" is the core configuration file of the network on which
this node is intended to operate. All nodes on the same network should be using this exact genesis file.
The "<Project>-network-<Network Name>" packages install the relevant file for the network.

#### Public Seed and Sentry Nodes
File containing lists of seeds and sentries and other useful node names. These are offered as "bootstrap files"
to get the node connected to the rest of the nodes in the intended network.

#### Specific upgrade scripts
Additional steps might be needed for specific updates of the software or chain-id.
These will be delivered in the network package and executed as appropriate by Cosmovisor.

## The "cudos-gex" package

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

2022-11-12 Update: However, it is entering the final stages of QA and testing and will be released soon.

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
