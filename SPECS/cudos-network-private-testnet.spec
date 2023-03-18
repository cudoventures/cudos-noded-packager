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

%global project_title  Cudos
%global parent_url     https://github.com/CudoVentures
%global project_name   cudos-node

%global daemon_name    cudos-noded
%global daemon_version v1.1.0
%global upgrade_name   v1.1
%global obsoletes      cudos-noded-v1.1.0.1

%global username       cudos
%global data_directory cudos-data

%global network_name   cudos
%global network_class  private-testnet

###########################################

Name:         %{network_name}-network-%{network_class}
Version:      %{_versiontag}
Release:      %{_releasetag}%{?dist}
Summary:      %{project_title} %{network_class} Network Definition Files for System version %{version}

License:      GPL3
URL:          %{parent_url}/%{project_name}

Source0:      toml-config-%{network_name}-%{network_class}.tar.gz

Requires:     cosmovisor
Requires:     %{daemon_name}
Requires:     %{daemon_name}-v0.8.0
Requires:     %{daemon_name}-v0.9.0
Requires:     %{daemon_name}-v1.0.1
Requires:     %{daemon_name}-v1.1.0

Requires:     cudos-p2p-scan
Requires:     cudos-gex

%description
%{project_title} %{network_class} Network Definition Files for System version %{version}

%prep
echo -e "\n\n=== prep section ===\n\n"
tar -C ${RPM_SOURCE_DIR} -xzf toml-config-%{network_name}-%{network_class}.tar.gz

%build
echo -e "\n\n=== build section ===\n\n"

%install
echo -e "\n\n=== install section ===\n\n"

# Make the fixed directory structure
mkdir -p ${RPM_BUILD_ROOT}/etc/default
mkdir -p ${RPM_BUILD_ROOT}/var/lib/%{username}/%{data_directory}/config

# Install the %{data_directory}/config files
cp -v ${RPM_SOURCE_DIR}/genesis.json                   ${RPM_BUILD_ROOT}/var/lib/%{username}/%{data_directory}/config/
cp -v ${RPM_SOURCE_DIR}/persistent-peers.config        ${RPM_BUILD_ROOT}/var/lib/%{username}/%{data_directory}/config/
cp -v ${RPM_SOURCE_DIR}/seeds.config                   ${RPM_BUILD_ROOT}/var/lib/%{username}/%{data_directory}/config/
cp -v ${RPM_SOURCE_DIR}/state-sync-rpc-servers.config  ${RPM_BUILD_ROOT}/var/lib/%{username}/%{data_directory}/config/
cp -v ${RPM_SOURCE_DIR}/unconditional-peers.config     ${RPM_BUILD_ROOT}/var/lib/%{username}/%{data_directory}/config/
cp -v ${RPM_SOURCE_DIR}/private-peers.config           ${RPM_BUILD_ROOT}/var/lib/%{username}/%{data_directory}/config/

# Create genesis link to the chains genesis version
ln -s /var/lib/%{username}/%{data_directory}/cosmovisor/upgrades/v0.8 ${RPM_BUILD_ROOT}/var/lib/%{username}/%{data_directory}/cosmovisor/genesis

# Create /etc/default link for cosmovisor
ln -s cosmovisor@%{username} ${RPM_BUILD_ROOT}/etc/default/cosmovisor 

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
%attr(-, root, root) %config(noreplace) /etc/default/cosmovisor
%defattr(-,%{username},%{username},-)
%dir /var/lib/%{username}/%{data_directory}
%dir /var/lib/%{username}/%{data_directory}/config
%config(noreplace) /var/lib/%{username}/%{data_directory}/config/genesis.json
%config(noreplace) /var/lib/%{username}/%{data_directory}/config/persistent-peers.config
%config(noreplace) /var/lib/%{username}/%{data_directory}/config/private-peers.config
%config(noreplace) /var/lib/%{username}/%{data_directory}/config/seeds.config
%config(noreplace) /var/lib/%{username}/%{data_directory}/config/state-sync-rpc-servers.config
%config(noreplace) /var/lib/%{username}/%{data_directory}/config/unconditional-peers.config

%doc
