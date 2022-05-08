# Cudos Node Daemon Control Utility

## Introduction
This tool is intended to provide a simple, reliable command line utility for
manageing the cudos-noded daemon, configuration files and database. Any higher
level scripts provided to execute system level events, upgrades and hard forks
for example, should use the primitives in this script for all daemon control.

## Command Line

#### Example

```bash
cudos-noded-ctl set seeds "$CUDOS_HOME"/config/seeds.config
```

#### Syntax

```
cudos-noded-ctl  [-h] <command> [command_options]
```

#### Commands
##### set
Sets the named config variable from the .toml files to the prodided value
* Variables supported
  * seeds
  * persistent_peers
  * private_peers
  * unconditional_peers
  * pex
  * unsafe
  * prometheus

