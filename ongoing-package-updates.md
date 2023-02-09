# Ongoing Package Updates

## Introduction

Once you have created and started your node, you will then need to keepo the packages up to date so the node can weather software updates automatically. As the node software develops new versions with breaking changes as well as patch versions that fix issues within the same chain version will be released. The packaging has been designed to facilitate this process. The only thing the operator needs to do is keep the node up to date with the latest package sets.

This document will guide you through this process

## Scope

This document is purely related to updating an existing properly installed node. Please see the main documentationi for the process of installing the node in the first place.

NB If your node still uses the old docker based installation process, this document does not apply. If this is the case please seek support in the Discord channels.

## Debian and Redhat

The packages are available for both Redhat and Debian based systems using rpm and deb format package files respectively. Please follow the relevant section.

### Debian

For Debian and Ubuntu based systems the following update process applies

First get to a fully logged in root prompt. This can be achieved using either "sudo -i" or "su -" as well as a console login as root.

NB Putting "sudo" in front of the command does not necessarily set the command up properly. In some cases the command get to run as root, but with the previous users environemnt (home paths etc)

```
# apt update
# apt upgrade
```

Assuming there are no errors, the machine is now updated to the latest package set and is ready for the next fork.

### Redhat

For Redhat based systems like CentOS and Fedora the following update process applies

First get to a fully logged in root prompt. This can be achieved using either "sudo -i" or "su -" as well as a console login as root.

NB Putting "sudo" in front of the command does not necessarily set the command up properly. In some cases the command get to run as root, but with the previous users environemnt (home paths etc)

```
# dnf upgrade --refresh
```

Assuming there are no errors, the machine is now updated to the latest package set and is ready for the next fork.

## Checking that all is well

### package list

The best way of checking whether the right packages are installed or not is to list them

#### Debian

```
dpkg -l "*cudo*" "*osmo*"
```

which should look somethig like

```
root@cudos-validator-node-02:~# dpkg -l "*cudo*" "*osmo*"
Desired=Unknown/Install/Remove/Purge/Hold
| Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
|/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
||/ Name                         Version       Architecture Description
+++-============================-=============-============-======================================================
ii  cosmovisor                   1.0.0-104.el8 amd64        Osmosis Node Common Files
ii  cudos-gex                    1.1.0-104.el8 amd64        Gex - Cosmos Node Monitor App
ii  cudos-monitoring             1.1.0-104.el8 amd64        Cudos Node Monitoring Agents
ii  cudos-network-public-testnet 1.1.0-104.el8 amd64        Cudos Public Testnet Network Definition Files
ii  cudos-noded                  1.1.0-104.el8 amd64        Cosmovisor Node Client Files - cudos
un  cudos-noded-v0.0.0           <none>        <none>       (no description available)
ii  cudos-noded-v0.9.0           1.1.0-104.el8 amd64        Cudos Node v0.9.0 Binary Pack for System version 1.1.0
un  cudos-noded-v1.0.0           <none>        <none>       (no description available)
ii  cudos-noded-v1.0.1           1.1.0-104.el8 amd64        Cudos Node v1.0.1 Binary Pack for System version 1.1.0
ii  cudos-noded-v1.1.0           1.1.0-104.el8 amd64        Cudos Node v1.1.0 Binary Pack for System version 1.1.0
un  cudos-noded-v1.1.0.1         <none>        <none>       (no description available)
ii  cudos-p2p-scan               1.1.0-104.el8 amd64        cudos-p2p-scan
```

Note that the packages are all (in this case) package build number 104

#### Redhat

```
rpm -qa "*cudo*" "*osmo*"
```

which should look somethig like

```
[root@validator ~]# rpm -qa "*cudo*" "*osmo*"
cudos-noded-v1.1.0-1.1.0-104.el8.x86_64
cudos-gex-1.1.0-104.el8.x86_64
cudos-noded-1.1.0-104.el8.x86_64
cudos-noded-v1.0.1-1.1.0-104.el8.x86_64
cudos-release-1.1.0-104.el8.noarch
cosmovisor-1.0.0-104.el8.x86_64
cudos-noded-v0.9.0-1.1.0-104.el8.x86_64
cudos-monitoring-1.1.0-104.el8.x86_64
cudos-network-public-testnet-1.1.0-104.el8.x86_64
cudos-p2p-scan-1.1.0-104.el8.x86_64
```

Note that the packages are all (in this case) package build number 104

### Service restart

While the node should now be ready for the fork, you might like to double check that all is well by forcing the service to restart. This will mean that the node will likely miss 2 or 3 blocks while rebooting, but unless there is an issue that should be it.

```
# systemctl restart cosmovisor@cudos
```

You can then monitor the node's log using

```
# journalctl -f -u cosmovisor@cudos
```

You should see block index logs going past every 6 or 7 seconds.

## Automation

It is also possible to set the node's operating system to automatically run updates unattended. It is a matter of local policy as to whether this is done, in place of specific manual updates.
