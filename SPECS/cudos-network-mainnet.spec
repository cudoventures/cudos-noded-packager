#
# Copyright 2022 Andrew Meredith <andrew.meredith@cudoventures.com>
# Copyright 2022 Cudo Ventures - All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Contains the Network definition files for the Cudos Dress Rehearsal network
#

Name:         cudos-network-mainnet
Version:      %{_versiontag}
Release:      %{_releasetag}%{?dist}
Summary:      Cudos Dress Rehearsal Network Definition Files

License:      GPL3
URL:          https://github.com/CudoVentures/cudos-node

Source0:      genesis.json
Source1:      seeds.config
Source2:      persistent-peers.config
Source3:      state-sync-rpc-servers.config

Requires:     cudos-noded = 1.0.0

%description
Cudos Dress Rehearsal Network Definition Files

%prep
echo -e "\n\n=== prep section ===\n\n"
wget "https://github.com/CudoVentures/cudos-builders/blob/v1.0.0/docker/config/genesis.mainnet.json?raw=true"                  -O ${RPM_SOURCE_DIR}/genesis.json
wget "https://github.com/CudoVentures/cudos-builders/blob/v1.0.0/docker/config/persistent-peers.mainnet.config?raw=true"       -O ${RPM_SOURCE_DIR}/persistent-peers.config
wget "https://github.com/CudoVentures/cudos-builders/blob/v1.0.0/docker/config/seeds.mainnet.config?raw=true"                  -O ${RPM_SOURCE_DIR}/seeds.config
wget "https://github.com/CudoVentures/cudos-builders/blob/v1.0.0/docker/config/state-sync-rpc-servers.mainnet.config?raw=true" -O ${RPM_SOURCE_DIR}/state-sync-rpc-servers.config
touch ${RPM_SOURCE_DIR}/unconditional-peers.config
touch ${RPM_SOURCE_DIR}/private-peers.config
%build

%install
echo -e "\n\n=== install section ===\n\n"

# Make the fixed directory structure
mkdir -p ${RPM_BUILD_ROOT}/var/lib/cudos/cudos-data/config

# Install the cudos-data/config files
cp -v ${RPM_SOURCE_DIR}/genesis.json                   ${RPM_BUILD_ROOT}/var/lib/cudos/cudos-data/config/
cp -v ${RPM_SOURCE_DIR}/persistent-peers.config        ${RPM_BUILD_ROOT}/var/lib/cudos/cudos-data/config/
cp -v ${RPM_SOURCE_DIR}/seeds.config                   ${RPM_BUILD_ROOT}/var/lib/cudos/cudos-data/config/
cp -v ${RPM_SOURCE_DIR}/state-sync-rpc-servers.config  ${RPM_BUILD_ROOT}/var/lib/cudos/cudos-data/config/
cp -v ${RPM_SOURCE_DIR}/unconditional-peers.config     ${RPM_BUILD_ROOT}/var/lib/cudos/cudos-data/config/
cp -v ${RPM_SOURCE_DIR}/private-peers.config           ${RPM_BUILD_ROOT}/var/lib/cudos/cudos-data/config/

%clean
# rm -rf $RPM_BUILD_ROOT

%post
if [ $1 = "1" ]
then
    echo "Install .. but no scripts today"
else
    echo "Upgrade .. still no scripts today"
fi

%files
%defattr(-,cudos,cudos,-)
%dir /var/lib/cudos/cudos-data
%dir /var/lib/cudos/cudos-data/config
/var/lib/cudos/cudos-data/config/*
%doc
