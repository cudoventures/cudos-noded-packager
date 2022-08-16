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
# Runs the Osmosis Node Daemon
#

Name:         osmosisd
Version:      %{_versiontag}
Release:      %{_releasetag}%{?dist}
Summary:      Osmosis Node Common Files

License:      GPL3
URL:          https://github.com/osmosis-labs/osmosis           

Source1:      osmosisd.service
Source2:      etc_default_osmosisd
Source3:      etc_profiled_osmosisd.sh
Source4:      osmosis-init-node.sh
Source5:      osmosisd-ctl.sh
Source6:      osmosis-is-node-ready.sh

Source40:     check_osmosis_block_age.sh
Source41:     check_osmosis_block_data.sh
Source42:     check_osmosis_catching_up.sh
Source46:     check_osmosis_consensus.sh

Source60:     osmosis-cosmovisor.service
Source61:     etc_default_osmosis-cosmovisor
Source62:     etc_profiled_osmosis-cosmovisor.sh

# undefine __brp_mangle_shebangs
%global __brp_check_rpaths %{nil}

%description
Osmosis Node Common Files
%pre
getent group osmosis >/dev/null || groupadd -r osmosis || :
getent passwd osmosis >/dev/null || useradd -c "Osmosis User" -g osmosis -s /bin/bash -r -m -d /var/lib/osmosis osmosis 2> /dev/null || :

%package -n osmosis-check_mk
Summary: Osmosis Node Monitoring Agents
Requires: bc jq
%description -n osmosis-check_mk
CheckMK check_mk agents for Osmosis Nodes
%pre -n osmosis-check_mk

%prep
echo -e "\n\n=== prep section ===\n\n"

%build
echo -e "\n\n=== build section ===\n\n"

export GOPATH="${RPM_BUILD_DIR}/go"

echo -e "\n\n=== Build and install cosmovisor ===\n\n"

go install -v github.com/cosmos/cosmos-sdk/cosmovisor/cmd/cosmovisor@v1.0.0

%install
echo -e "\n\n=== install section ===\n\n"

# Make the fixed directory structure
mkdir -p ${RPM_BUILD_ROOT}/var/lib/osmosis/.osmosisd/config
mkdir -p ${RPM_BUILD_ROOT}/usr/bin
mkdir -p ${RPM_BUILD_ROOT}/etc/default/
mkdir -p ${RPM_BUILD_ROOT}/etc/profile.d/
mkdir -p ${RPM_BUILD_ROOT}/usr/lib/systemd/system
mkdir -p ${RPM_BUILD_ROOT}/usr/lib/check_mk_agent/local
mkdir -p ${RPM_BUILD_ROOT}/usr/lib64/nagios/plugins/


# Install the newly built binaries
cp -v ${RPM_BUILD_DIR}/go/bin/cosmovisor        ${RPM_BUILD_ROOT}/usr/bin/

# Install scripts
cp -v ${RPM_SOURCE_DIR}/osmosis-init-node.sh      ${RPM_BUILD_ROOT}/usr/bin/
chmod 755                                       ${RPM_BUILD_ROOT}/usr/bin/*.sh

# Install the shell scripts for /usr/bin
cp ${RPM_SOURCE_DIR}/osmosis-is-node-ready.sh            ${RPM_BUILD_ROOT}/usr/bin/
chmod 755                                              ${RPM_BUILD_ROOT}/usr/bin/*

# Install environment setup files
cp ${RPM_SOURCE_DIR}/etc_default_osmosisd           ${RPM_BUILD_ROOT}/etc/default/osmosisd
cp ${RPM_SOURCE_DIR}/etc_default_osmosis-cosmovisor      ${RPM_BUILD_ROOT}/etc/default/osmosis-cosmovisor
cp ${RPM_SOURCE_DIR}/etc_profiled_osmosisd.sh       ${RPM_BUILD_ROOT}/etc/profile.d/osmosisd.sh
cp ${RPM_SOURCE_DIR}/etc_profiled_osmosis-cosmovisor.sh  ${RPM_BUILD_ROOT}/etc/profile.d/osmosis-cosmovisor.sh

# Install systemd service files
cp ${RPM_SOURCE_DIR}/osmosisd.service                         ${RPM_BUILD_ROOT}/usr/lib/systemd/system/

# Install /usr/bin scripts
cp ${RPM_SOURCE_DIR}/osmosisd-ctl.sh                ${RPM_BUILD_ROOT}/usr/bin/osmosisd-ctl
chmod 755                                              ${RPM_BUILD_ROOT}/usr/bin/osmosisd-ctl

# Install check_mk files
cp ${RPM_SOURCE_DIR}/check_osmosis_block_age.sh          ${RPM_BUILD_ROOT}/usr/lib/check_mk_agent/local/
cp ${RPM_SOURCE_DIR}/check_osmosis_block_data.sh         ${RPM_BUILD_ROOT}/usr/lib/check_mk_agent/local/
cp ${RPM_SOURCE_DIR}/check_osmosis_catching_up.sh        ${RPM_BUILD_ROOT}/usr/lib/check_mk_agent/local/
cp ${RPM_SOURCE_DIR}/check_osmosis_consensus.sh          ${RPM_BUILD_ROOT}/usr/lib/check_mk_agent/local/
chmod 755                                                ${RPM_BUILD_ROOT}/usr/lib/check_mk_agent/local/*

# This script is only needed when there's a chain halt .. so make it 444 until needed
chmod 444                                                ${RPM_BUILD_ROOT}/usr/lib/check_mk_agent/local/check_osmosis_consensus.sh

%clean
# rm -rf $RPM_BUILD_ROOT

%post
if [ $1 = "1" ]
then
    echo "Install: Setting up links"
else
    echo "Upgrade: Setting up links"
fi
if [ -d /var/lib/osmosis/.osmosisd/cosmovisor/current ]
then
  echo "  Cosmovisor 'current' link in place already"
else
  echo "  Setting Cosmovisor 'current' link to genesis"
  ln -s /var/lib/osmosis/.osmosisd/cosmovisor/genesis /var/lib/osmosis/.osmosisd/cosmovisor/current
fi
echo "  Reloading systemd config"
systemctl daemon-reload 
echo "  Done"

%files
%defattr(-,root,root,-)
/etc/default/*
/etc/profile.d/*
/usr/bin/cosmovisor
/usr/bin/osmosisd-ctl
/usr/bin/osmosis-init-node.sh
/usr/lib/systemd/system/osmosisd.service
/usr/lib/systemd/system/osmosis-cosmovisor.service
%doc

%files -n osmosis-check_mk
%defattr(-,root,root,-)
/usr/bin/osmosis-is-node-ready.sh
/usr/lib/check_mk_agent/local/check_osmosis_block_age.sh
/usr/lib/check_mk_agent/local/check_osmosis_block_data.sh
/usr/lib/check_mk_agent/local/check_osmosis_catching_up.sh
/usr/lib/check_mk_agent/local/check_osmosis_consensus.sh

%changelog
