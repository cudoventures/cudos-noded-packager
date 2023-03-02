# Cudos Behind the Curtain

The Cudos mainnet blockchain network was recently forked to version v1.1 in it's first mainnet software upgrade. This upgrade saw a significant change in the way the daemon software is installed and laid out in the operating system. This article is intended to explain the change and look at some of the technologies being used.

## The History

The Cudos Network mainnet launch in June 2022 was the culmination of several years hard work by Cudo Ventures and our developers. By this time the code had been tested and pushed and stretched in as many ways as we could come up with. The execution of these tests was done on our private and public testnet, but also prior to that, by our developers using single node "Dev Networks". In order to provide the developers with a mechanism for using these develeopment networks a system of docker containers and docker-compose processes was created. While this was perfect for the development use case, it was less well suited to being installed on user machines. It added considerably to the installation complexity and frustrated ongoing updates and niche configuration needs. It was decided that we needed to rethink the install and maintenance experience.

## The Cosmos Interchain

One of the key strategic reasons for using the Cosmos and WASM toolkits to build the Cudos network was that it immediately became part of a greater whole, the Cosmos Interchain. As part of this Cudo runs a number of services enabling transfer of tokens between the Cudos chain and other tokens. These backend systems work best if they have their own local blockchain node on the network in question. Which of course means that Cudo needs to maintain several non-Cudos blockchain nodes. It was decided that the solution should be more generic than just the Cudos chain and that it should try and homogenise the management of the nodes across these different chains. It as also decided that the mechanism that should be used was the native OS packaging for the platforms in questio. ie RPM and DEB packaging in yum and apt repos.

## Why Packaging

One of the key attractions of the Cosmos blockchain daemon family is that nodes can communicate with each other across different chains and pass tokens around seamlessly in encapsulations, and maybe switch them for other tokens through liquidity pools, with novel uses and new specialisations popping up all the time; while still allowing the different Cosmos based blockchains to focus on their own particular reason for being by creating novel functions that can naturally integrate with everyone else.

However, in order for this to be realised on the ground, the various software components of this ecosystem must remain up and running, and up to date with chain upgrades and operating system software changes.

It's tempting to think that every new problem is unique and new, but this one isn't. The machine underneath the blockchain daemons and apps, is immensely more complex than the apps they're deployed to sustain; and contain orders of magnitudes more code. So how was the entirity of the rest of the operating system needed to run one of these daemons, installed. It was laced together with a dependancy chain of operating system packages. Be they Debian style .deb files, or Red Hat style .rpm .. or indeed any of the other package styles used for other platforms. There is no good reason why the Cosmos family of daemons and apps couldn't be built for Android, iThing, and certainly for the ARM chip family in general.

In order for this to be realised, this whole stack of software needs to become as much **part of the fabric of computing** as any other applications the operating system might have been put there to sustain, and to do that, it needs to be just another option on the panel of things you might want to install on this box/tablet/phone.

## The Generic Package Structure

The intent of this package structure is to be **chain agnostic**, with the end goal of making the choice of network and chain a tick box to which newcomers can easily be added. While allowing the individual Cosmos Daemon projects full reign to evolve their contribution to suite their own plans.

## Cosmovisor

As part of the move to use native packages rather than the previous docker based approach, the Cudos daemon is now controlled by another daemon called "Cosmovisor". This is a very clever tool that sits above the Cosmos network daemon and has the ability to watch for software upgrade governance proposals on the chain. It does this itself, without reference to the Cosmos daemon that it controls. When the chain halt, which is part of the software upgrade process, actually happens, the Cosmos daemon will throw an error and exit. Cosmovisor will then pick out the "Upgrade Name" from the data attached to the governance proposal and use it to select the new version of the Cosmos daemon, which it then starts. The new daemon then does whatever upgrades are needed to the chain data, if any, and then gets back to normal operations. In recent software upgrades this has added a few 10s of seconds to the normal progression of new blocks. The v1.1 mainnet upgrade added just 25 seconds.

## Installing a new node

Getting a new node runnng using these packages is done in 3 stages.

### Add the package repository

All of the Debian and Redhat derived Linux distributions work is roughly the same way with respect to packages. The two systems differ in format and in the details of the commands, but are otherwise very similar. In both cases a single command is required to add the Cudo repository to the operating system.

### Install the packages

This is a single command for Redhat and two for the Debian derived platforms. They both start by refreshing the package index data and then installing the package set. This generally takes a few 10s of seconds.

### Configure the daemon

Another single command will create and set up the daemon's configuration files. All that is needed now is the start the daemon .. with one more command.

## Binary Packages vs Build from Source

There is a strong tradition among blockchain operators of building all blockchain nodes from scratch for every installation and upgrading by, again, building the new version from source. However, the Cudo packages are fully open, along with the scripts used to build the packages. If the operator likes the sound of this approach, but still wants to build their own, there is absolutley nothing from stopping them from building the package set themselves and serving it to their own machines using their own web server. Even the process of signing and indexing the packages is scripted and the script published in the GitHub repository along with the rest of the the packaging code.

