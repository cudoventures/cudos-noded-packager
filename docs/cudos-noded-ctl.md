# Cudos Node Daemon Control Utility

## Introduction
This tool is intended to provide a simple, reliable command line utility for
manageing the cudos-noded daemon, configuration files and database. Any higher
level scripts provided to execute system level events, upgrades and hard forks
for example, should use the primitives in this script for all daemon control.

For a working example see: https://github.com/CudoVentures/cudos-noded-packager/blob/main/SOURCES/cudos-init-node.sh

## Command Line

#### Example

```bash
cudos-noded-ctl set seeds "$CUDOS_HOME"/config/seeds.config
```

#### Syntax

```
cudos-noded-ctl  [-h] <command> [command_options]
```

#### cudos-noded-ctl set seeds `<filename>`

Fills in the "seeds =" variable in config.toml with the contents of `<filename>` eg:

```
 /var/lib/cudos/cudos-data/config/seeds.config
 ```

This file is installed by the "cudos-network-??" package. For public testnet this would be **cudos-network-public-testnet** package.

The contents of the file must be a single line, comma separated list of seed nodes to connect to in the form:

```
 <tendermint ID>@<IP address or hostname>:<Port number>[,<tendermint ID>@<IP address or hostname>:<Port number>
```

 eg
 
``` 86a2f5d723718a030ee4fred792d14c42ba0bd3f@34.67.137.129:26656,a48e90ce5fred1c40bc4352794f034880c2f2041@34.102.114.30:26656,fred129f120fd1de3e9d60d2bd376ae96af325dd@34.141.129.16:26656
```

The use of this format is required in order to integrate with the files in: https://github.com/CudoVentures/cudos-builders/tree/cudos-master/docker/config

#### cudos-noded-ctl set persistent_peers `<filename>`

<filename> contains a comma separated list of nodes to keep persistent connections to

Fills in the ```persistent_peers =``` variable in config.toml with the the contents of `<filename>` eg

```
/var/lib/cudos/cudos-data/config/persistent-peers.config
```

This file is installed empty by the "cudos-network-??" package as each node will have its own set of persistent peers.

The contents of the file must be a single line, comma separated list of sentry nodes to connect to in the same form as for the seeds variable

The use of this format is required in order to integrate with the files in: https://github.com/CudoVentures/cudos-builders/tree/cudos-master/docker/config

##### cudos-noded-ctl set private_peers `<filename>`

<filename> contains a comma separated list of peer IDs to keep private (will not be gossiped to other peers)

This fills in the ```private_peer_ids =``` variable in config.toml using the contents of the `<filename>`.

The contents of the file must be a single line, comma separated list of tendermint ids in the form:

```
<tendermint ID>[,<tendermint ID>]
```

 eg
 
```
86a2f5d723718a03fred36dc792d14c42ba0bd3f,a48e90cdfred01c40bc4352794f034880c2f2041,f93e129f120fd1de3fred0d2bd376ae96af325dd
```

The use of this format is required in order to integrate with the files in: https://github.com/CudoVentures/cudos-builders/tree/cudos-master/docker/config

##### cudos-noded-ctl set unconditional_peers `<filename>`

<filename> contains a comma separated list of node IDs, to which a connection will be (re)established ignoring any existing limits

This fills in the ```unconditional_peer_ids =``` variable in config.toml using the contents of the `<filename>`.

The contents of the file must be a single line, comma separated list of tendermint ids in the form:

```
 <tendermint ID>[,<tendermint ID>]
```

 eg
 
```
86a2f5d723718a03fred36dc792d14c42ba0bd3f,a48e90cdfred01c40bc4352794f034880c2f2041,f93e129f120fd1de3fred0d2bd376ae96af325dd
```

The use of this format is required in order to integrate with the files in: https://github.com/CudoVentures/cudos-builders/tree/cudos-master/docker/config

##### cudos-noded-ctl set pex <true/false>

Set true to enable the peer-exchange reactor

Default: pex = true

##### cudos-noded-ctl set unsafe <true/false>

Activate unsafe RPC commands like /dial_seeds and /unsafe_flush_mempool

Default: unsafe = false

##### cudos-noded-ctl set prometheus <true/false>

When true, Prometheus metrics are served under /metrics on PrometheusListenAddr.
Check out the documentation for the list of available metrics.

Default: prometheus = true
