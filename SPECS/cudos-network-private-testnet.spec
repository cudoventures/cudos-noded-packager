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
# Contains the Network definition files for the Cudos Private Testnet network
#

Name:         cudos-network-private-testnet
Version:      %{_versiontag}
Release:      %{_releasetag}%{?dist}
Summary:      Cudos Private Testnet Network Definition Files

License:      GPL3
URL:          https://github.com/CudoVentures/cudos-node

Source0:      toml-config-private-testnet.tar.gz

Requires:     cosmovisor
Requires:     cudos-noded
Requires:     cudos-noded-v0.8.0
Requires:     cudos-noded-v0.9.0
Requires:     cudos-noded-v1.0.1
Requires:     cudos-noded-v1.1.0.1
Requires:     cudos-p2p-scan
Requires:     cudos-gex

%description
Cudos Private Testnet Definition Files

%prep
echo -e "\n\n=== prep section ===\n\n"
tar -C ${RPM_SOURCE_DIR} -xzf ${RPM_SOURCE_DIR}/toml-config-private-testnet.tar.gz

%build
echo -e "\n\n=== build section ===\n\n"

%install
echo -e "\n\n=== install section ===\n\n"

# Make the fixed directory structure
mkdir -p ${RPM_BUILD_ROOT}/var/lib/cudos/cudos-data/config
mkdir -p ${RPM_BUILD_ROOT}/var/lib/cudos/cudos-data/cosmovisor/upgrades/v0.8
mkdir -p ${RPM_BUILD_ROOT}/var/lib/cudos/cudos-data/cosmovisor/upgrades/v0.9
mkdir -p ${RPM_BUILD_ROOT}/var/lib/cudos/cudos-data/cosmovisor/upgrades/v1.0
mkdir -p ${RPM_BUILD_ROOT}/var/lib/cudos/cudos-data/cosmovisor/upgrades/v1.1

# Install the cudos-data/config files
cp -v ${RPM_SOURCE_DIR}/genesis.json                   ${RPM_BUILD_ROOT}/var/lib/cudos/cudos-data/config/
cp -v ${RPM_SOURCE_DIR}/persistent-peers.config        ${RPM_BUILD_ROOT}/var/lib/cudos/cudos-data/config/
cp -v ${RPM_SOURCE_DIR}/seeds.config                   ${RPM_BUILD_ROOT}/var/lib/cudos/cudos-data/config/
cp -v ${RPM_SOURCE_DIR}/state-sync-rpc-servers.config  ${RPM_BUILD_ROOT}/var/lib/cudos/cudos-data/config/
cp -v ${RPM_SOURCE_DIR}/unconditional-peers.config     ${RPM_BUILD_ROOT}/var/lib/cudos/cudos-data/config/
cp -v ${RPM_SOURCE_DIR}/private-peers.config           ${RPM_BUILD_ROOT}/var/lib/cudos/cudos-data/config/

cd ${RPM_BUILD_ROOT}/var/lib/cudos/cudos-data/cosmovisor
ln -s /var/lib/cudos/cudos-data/cosmovisor/upgrades/v0.8 genesis
cd -

%clean
rm -rf $RPM_BUILD_ROOT

%post
if [ $1 = "1" ]
then
    echo "Install:"
else
    echo "Upgrade:"
fi

%files
%defattr(-,cudos,cudos,-)
%dir /var/lib/cudos/cudos-data
%dir /var/lib/cudos/cudos-data/config
/var/lib/cudos/cudos-data/cosmovisor
%config(noreplace) /var/lib/cudos/cudos-data/config/genesis.json
%config(noreplace) /var/lib/cudos/cudos-data/config/persistent-peers.config
%config(noreplace) /var/lib/cudos/cudos-data/config/private-peers.config
%config(noreplace) /var/lib/cudos/cudos-data/config/seeds.config
%config(noreplace) /var/lib/cudos/cudos-data/config/state-sync-rpc-servers.config
%config(noreplace) /var/lib/cudos/cudos-data/config/unconditional-peers.config

%doc
