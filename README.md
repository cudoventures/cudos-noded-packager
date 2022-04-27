# Cudos Daemon binary packaging

Packages are produced by the code in this repository and published
on a "Proof of Concept" basis for public download. Please see the following
details on how to install a Cudos node daemon using these binary packages, on a Linux system.

Please be aware that this service is being offered on a "Proof of Concept" basis.

Please see https://github.com/CudoVentures/cudos-noded-packager/blob/main/LICENSE for
the license conditions under which this software is released. 

# Install the repository

## Red Hat family (RHEL, CentOS & Fedora)

NB Every Cudos Node major version has its own repository to maintain separation while
still allowing security and utility upgrades to older versions.

The following is correct for version 0.6.0.

```bash
yum-config-manager --add-repo http://jenkins.gcp.service.cudo.org/cudos/0.6.0/cudos.repo
yum-config-manager --enable cudos-0.6.0
```

If the system doesn't recognise "yum-config-manager" it can be installed using

```bash
dnf install -y yum-utils
```

## Check to ensure the repository can be seen

```bash
dnf repolist --refresh
```

Should look something like

```
repo id                                                          repo name
appstream                                                        CentOS Stream 8 - AppStream
baseos                                                           CentOS Stream 8 - BaseOS
docker-ce-stable                                                 Docker CE Stable - x86_64
epel                                                             Extra Packages for Enterprise Linux 8 - x86_64
epel-modular                                                     Extra Packages for Enterprise Linux Modular 8 - x86_64
epel-next                                                        Extra Packages for Enterprise Linux 8 - Next - x86_64
extras                                                           CentOS Stream 8 - Extras
cudos-0.5                                                        CentOS Stream 8 - Cudo Cudos 0.5 Packages
```

## Install the cudos-noded package

```bash
dnf install cudos-noded
```

Should look something like

```
CentOS Stream 8 - Cudo Service Team Testnet Packager                                                              249 kB/s | 9.3 kB     00:00    
Dependencies resolved.
==================================================================================================================================================
 Package                               Architecture         Version                     Repository                                           Size
==================================================================================================================================================
Installing:
 cudos-noded                           x86_64               0.4-1724.el8                cudos-0.5               2.2 M

Transaction Summary
==================================================================================================================================================
Install  2 Packages

Total download size: 17 M
Installed size: 86 M
Is this ok [y/N]: y
Downloading Packages:
(1/2): cudos-noded-0.5-123.el8.x86_64.rpm                                                             82 MB/s |  15 MB     00:00    
--------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                              81 MB/s |  17 MB     00:00     
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                          1/1 
  Installing       : cudos-noded-0.5-123.el8.x86_64                                                                                            2/2 
  Running scriptlet: cudos-noded-0.5-123.el8.x86_64                                                                                            2/2 
  Verifying        : cudos-noded-0.5-123.el8.x86_64                                                                                            1/2 
  
Installed:
  cudos-noded-0.5-123.el8.x86_64                                   

Complete!
```

# Configure the daemon

This can either be done by hand, the cudos-noded-src package can be installed and the
information can taken directly from the sources

Or by downloading a "Cudos Network Definition" package, which is another rpm/deb package
that contains the relevant genesis and node addresses files for the given network.

The CUDOS_HOME variable is preset to /var/lib/cudos/cudos-data, which is owned by the
user "cudos" who's home directory is /var/lib/cudos.

It is advised that all configuration editing operations be done as user "cudos" in
order to avoid permissions issues. Everything under /var/lib/cudos should be owned by user "cudos"

# Enable and start the daemon

```bash
systemctl enable --now cudos-noded
```

The output should look like

```
Created symlink /etc/systemd/system/multi-user.target.wants/cudos-noded.service → /usr/lib/systemd/system/cudos-noded.service.
```

# Logs

As this daemon is controlled by systemd, the logs will natural flow to journald and can be watched using

```bash
journalctl -f -t cudos-noded
```

