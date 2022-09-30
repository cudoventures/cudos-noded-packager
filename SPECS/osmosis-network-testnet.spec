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
# Contains the Network definition files for the Osmosis Testnet network
#

Name:         osmosis-network-testnet
Version:      %{_versiontag}
Release:      %{_releasetag}%{?dist}
Summary:      osmosis Testnet Network Definition Files

License:      GPL3
URL:          https://github.com/osmosis-labs/osmosis

Source0:      osmosis-network-testnet_config.tar.gz

Requires:     cosmovisor
Requires:     osmosisd
Requires:     osmosisd-v11.0.0
Requires:     osmosisd-v12.0.0
Requires:     cudos-p2p-scan
Requires:     cudos-gex

%description
Osmosis Testnet Network Definition Files

%prep
echo -e "\n\n=== prep section ===\n\n"
tar -C ${RPM_SOURCE_DIR} -xzf ${RPM_SOURCE_DIR}/osmosis-network-testnet_config.tar.gz

%build

%install
echo -e "\n\n=== install section ===\n\n"

# Make the fixed directory structure
mkdir -p ${RPM_BUILD_ROOT}/var/lib/osmosis/.osmosisd/config
mkdir -p ${RPM_BUILD_ROOT}/var/lib/osmosis/.osmosisd/cosmovisor/upgrades/v11.0.0

# Install the .osmosisd/config files
cp -v ${RPM_SOURCE_DIR}/osmosis-network-testnet_config/genesis.json                   ${RPM_BUILD_ROOT}/var/lib/osmosis/.osmosisd/config/
cp -v ${RPM_SOURCE_DIR}/osmosis-network-testnet_config/persistent-peers.config        ${RPM_BUILD_ROOT}/var/lib/osmosis/.osmosisd/config/
cp -v ${RPM_SOURCE_DIR}/osmosis-network-testnet_config/seeds.config                   ${RPM_BUILD_ROOT}/var/lib/osmosis/.osmosisd/config/
cp -v ${RPM_SOURCE_DIR}/osmosis-network-testnet_config/state-sync-rpc-servers.config  ${RPM_BUILD_ROOT}/var/lib/osmosis/.osmosisd/config/
cp -v ${RPM_SOURCE_DIR}/osmosis-network-testnet_config/unconditional-peers.config     ${RPM_BUILD_ROOT}/var/lib/osmosis/.osmosisd/config/
cp -v ${RPM_SOURCE_DIR}/osmosis-network-testnet_config/private-peers.config           ${RPM_BUILD_ROOT}/var/lib/osmosis/.osmosisd/config/

cd ${RPM_BUILD_ROOT}/var/lib/osmosis/.osmosisd/cosmovisor
ln -s upgrades/v11.0.0 genesis
cd -

%clean
# rm -rf $RPM_BUILD_ROOT

%pre
getent group osmosis >/dev/null || groupadd -r osmosis || :
getent passwd osmosis >/dev/null || useradd -c "Osmosis User" -g osmosis -s /bin/bash -r -m -d /var/lib/osmosis osmosis 2> /dev/null || :

%files
%defattr(-,osmosis,osmosis,-)
%dir /var/lib/osmosis/.osmosisd
%dir /var/lib/osmosis/.osmosisd/config
%config(noreplace) /var/lib/osmosis/.osmosisd/config/genesis.json
%config(noreplace) /var/lib/osmosis/.osmosisd/config/persistent-peers.config
%config(noreplace) /var/lib/osmosis/.osmosisd/config/seeds.config
%config(noreplace) /var/lib/osmosis/.osmosisd/config/state-sync-rpc-servers.config
%config(noreplace) /var/lib/osmosis/.osmosisd/config/unconditional-peers.config
%config(noreplace) /var/lib/osmosis/.osmosisd/config/private-peers.config
/var/lib/osmosis/.osmosisd/cosmovisor

%doc
