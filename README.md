## Cudos Daemon binary packaging

Packages are produced by the code in this repository and published
on a "Proof of Concept" basis for public download. Please see the following
details on how to install a Cudos node daemon using these binary packages, on a Linux system.

Please be aware that this service is being offered on a "Proof of Concept" basis.

Please see https://github.com/CudoVentures/cudos-noded-packager/blob/main/LICENSE for
the license conditions under which this software is released. 

# Install the repository

## Red Hat family (RHEL, CentOS & Fedora)

```bash
wget http://jenkins.gcp.service.cudo.org/cudos/cudos.repo -O /etc/yum.repos.d/cudos.repo
```

Should look something like

```
--2022-02-21 21:56:15--  http://jenkins.gcp.service.cudo.org/svcteam-cudos-testnet-packager-latest/svcteam-cudos-testnet-packager-latest.repo
Resolving jenkins.gcp.service.cudo.org (jenkins.gcp.service.cudo.org)... 35.246.48.197
Connecting to jenkins.gcp.service.cudo.org (jenkins.gcp.service.cudo.org)|35.246.48.197|:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 211
Saving to: ‘/etc/yum.repos.d/cudos.repo’

/etc/yum.repos.d/cudos.repo 100%[====================================================================>]     211  --.-KB/s    in 0s      

2022-02-21 21:56:15 (51.0 MB/s) - ‘/etc/yum.repos.d/cudos.repo’ saved [211/211]
```

## Check to ensure it has taken

```bash
dnf repolist
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
dnf install cudos-gex cudos-monitoring-docker
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

## Configure the daemon

This can either be done by hand, or by downloading a "Cudos Network Definition" package,
which is another rpm/deb package that contains the relevant genesis and node addresses
for that gioven network, or the cudos-noded-src package can be installed and the
information taken directly from the source tree.

The CUDOS_HOME variable is preset to /var/lib/cudos/cudos-data and is owned by the
user "cudos" who's home directory is /var/lib/cudos.

## Enable and start the daemon

```bash
systemctl enable --now cudos-noded
```

The output should look like

```
Created symlink /etc/systemd/system/multi-user.target.wants/cudos-noded.service → /usr/lib/systemd/system/cudos-noded.service.
```

## Logs

As this daemon is controlled by systemd, the logs will natural flow to journald and can be watched using

```bash
journalctl -f -t cudos-noded
```

