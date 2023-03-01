# Public Testnet Seed Upgrade

## Introduction

The Cudos Public Testnet Network seeds are being replaced with new machines on different addresses.

This document explains the change and lays out a simple process that can be used to update Cudos Node configurations to take account of these changes.

NB This change and this document only applies to the Cudos Public Testnet.

NB This change does affect custom configurations, including clustered validators and their seeds and sentries, however, they will need a custom update. If any assistance is required, please raise a Discord ticket.

## What is changing

Since the earliest deays of the Cudos Public Testnet the public seeds have not changed. However, we are now rebuilding the infrastructure for this network on our own hardware. One of the consequences of this change is that the addresses used to connect a Cudos node to the 3 seed nodes have changed. This will require the config.toml file that is used to configure nodes on pulic testnet to have the new node addresses in the "seeds =" variable.

## How to make this change

If the nodes in question are using the standard Cudos Network yum/apt packages and they have been up-dated to the at least build 107, no further package updates will be required. 

If not, then please follow the instructions in: [ongoing-package-updates.md](ongoing-package-updates.md) 

Once the packages are at build 107, the update command can be used.

## The command to update the seeds variable

The Cudos packages contain a number of tools including ```cudos-noded-ctl``` which is a low level utility normally associated with ```cudos-init-node.sh``` but on this occasion is being used on its own. The command that will update the seeds setting is:

```cudos-noded-ctl set seeds /var/lib/cudos/cudos-data/config/seeds.config```

It is important to have at least build 107 in place as this is the build that updates the default seed layout in ```/var/lib/cudos/cudos-data/config/seeds.config``` so that the correct seed addresses end up in config.toml.

## The full process

Log into the node in question as root.

Run the following commands:
```
systemctl stop cosmovisor@cudos
su - cudos -c "cudos-noded-ctl set seeds /var/lib/cudos/cudos-data/config/seeds.config"
systemctl start cosmovisor@cudos
```

You will then see that the "seeds =" variable in /var/lib/cudos/cudos-data/config/config.toml has been updated to the new values:

```
[......]

# Comma separated list of seed nodes to connect to
seeds = "ee9f57fa3d29a7b88df01dd69f1537c5687b8fd6@seed-01.hosts.testnet.cudos.org:26656,8c9f61d1783b4ab9707ef4dc99d07c9cd0ae5155@seed-02.hosts.testnet.cudos.org:26656,56543c24150a939095558c16dee031bf2fb2feb5@seed-03.hosts.testnet.cudos.org:26656"

# Comma separated list of nodes to keep persistent connections to
[.....]
```

Please also note that the addresses use fully qualified domain names, rather than IP addresses. This is deliberate as it is likely that the seed node IP addresses will change again. The hostnames and tendermint IDs of the seeds will however stay the same, meaning that the above entry will remain valid, although will need a restart to re-resolve the seed IP addresses.

## Check that all is well

Once the packages have been updated, the config.toml updated and the node restarted, it is best to make sure tha tthe node is still running properly.

The easiest way of doing this is to use the tool ```cudos-gex``` which will present a text console app frontend showing amongst other things, the current block. If yo usee the current advancing, it is likely that allk is well.

If you have any issues with any of the above, please open a ticket in the Cudos Discord support ticket system.

