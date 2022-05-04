# Cudos Daemon binary packaging

Packages are produced by the code in this repository and published
on a "Proof of Concept" basis for public download. Please see the following
details on how to install a Cudos node daemon using these binary packages, on a Linux system.

Every Cudos Node major version has its own repository to maintain separation while
still allowing security and utility upgrades to older versions.

The correct mix of package names and versions can be set up by install a "Cudos Network
Definition" package, which is another rpm/deb package that contains the relevant genesis
and node address files for the given network.

In order to allow easier integration of the various components the directory locations
for the daemon have been fixed and should remain at those locations. The CUDOS_HOME variable
is preset to /var/lib/cudos/cudos-data, which is owned by the user "cudos" who's home
directory is /var/lib/cudos.

It is advised that all configuration editing operations be done as user "cudos" in
order to avoid permissions issues. Everything under /var/lib/cudos should be owned
by user "cudos"

The only operations that need root involvement are installin, upgrading and removing
the software packages. It is advised that all other operations are performed as either
user "cudos" or as another non-priveledged user and specifically *not* as root. Doing 
so would leave files in the "cudos-data" area that the user running the daemon (cudos)
cannot update.

Please be aware that this code and the repo service is being offered on a "Proof of Concept" basis.

Please see https://github.com/CudoVentures/cudos-noded-packager/blob/main/LICENSE for
the license conditions under which this software is released. 

## Install from the repository

The following is correct for public-testnet

### Red Hat family (RHEL, CentOS & Fedora)

```bash
dnf install -y yum-utils
yum-config-manager --add-repo http://jenkins.gcp.service.cudo.org/cudos/cudos.repo
yum-config-manager --enable cudos-0.4
dnf install cudos-network-public-testnet
```

### Debian and Ubuntu

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

### cudos-noded binary and library

### shell environment files to fix CUDOS_HOME

### Specific upgrade scripts

## The "cudos-network-???" packages

### Genesis File

### Public Seed and Sentry Nodes

## The "cudos-gex" package

## The "cudos-monitoring" package

### CheckMK monitoring

### Chronocollector

# Status

Please be aware that none of the above is currently supported by Cudo Ventures in any way and is offered purely as a "Proof of Concept" and a working demonstration of a possible alternative way of installing Cudos Nodes in the future.
