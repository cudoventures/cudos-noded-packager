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

Source2:      etc_default_cosmovisor-osmosis
Source4:      osmosis-init-node.sh
Source5:      osmosisd-ctl.sh

Source40:     osmosis-is-node-ready.sh
Source41:     check_osmosis_block_age.sh
Source42:     check_osmosis_block_data.sh
Source43:     check_osmosis_catching_up.sh
Source44:     check_osmosis_consensus.sh

Requires:     cosmovisor

%description
Cosmovisor Node Common Files - osmosis
%pre
if getent group osmosis >/dev/null
then
  echo "  Group osmosis OK"
else
  echo "  Create Group osmosis"
  groupadd -r osmosis
fi
if getent passwd osmosis >/dev/null
then
  echo "  User osmosis OK"
else
  echo "  Create User osmosis"
  useradd -c "Osmosis User" -g osmosis -s /bin/bash -r -m -d /var/lib/osmosis osmosis
fi

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

%install
echo -e "\n\n=== install section ===\n\n"

# Make the fixed directory structure
mkdir -p ${RPM_BUILD_ROOT}/var/lib/osmosis/.osmosisd/config
mkdir -p ${RPM_BUILD_ROOT}/var/lib/osmosis/.osmosisd/cosmovisor
mkdir -p ${RPM_BUILD_ROOT}/usr/bin
mkdir -p ${RPM_BUILD_ROOT}/etc/default/
mkdir -p ${RPM_BUILD_ROOT}/usr/lib/systemd/system
mkdir -p ${RPM_BUILD_ROOT}/usr/lib/check_mk_agent/local
mkdir -p ${RPM_BUILD_ROOT}/usr/lib64/nagios/plugins/


# Install scripts
cp ${RPM_SOURCE_DIR}/osmosis-init-node.sh       ${RPM_BUILD_ROOT}/usr/bin/
cp ${RPM_SOURCE_DIR}/osmosis-is-node-ready.sh   ${RPM_BUILD_ROOT}/usr/bin/
chmod 755                                       ${RPM_BUILD_ROOT}/usr/bin/*

# Install environment setup files
cp ${RPM_SOURCE_DIR}/etc_default_cosmovisor-osmosis           ${RPM_BUILD_ROOT}/etc/default/cosmovisor@osmosis

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

%post
if [ $1 = "1" ]
then
    echo "  Install: Setting up links"
else
    echo "  Upgrade: Setting up links"
fi
echo "    Refreshing /usr/bin, /lib and /lib64 links"
rm -f /usr/bin/osmosisd /usr/lib/libwasmvm.x86_64.so /lib/libwasmvm.x86_64.so || true

ln -s /var/lib/osmosis/.osmosisd/cosmovisor/current/bin/osmosisd /usr/bin/osmosisd
ln -s /var/lib/osmosis/.osmosisd/cosmovisor/current/lib/libwasmvm.x86_64.so /usr/lib/libwasmvm.x86_64.so
ln -s /var/lib/osmosis/.osmosisd/cosmovisor/current/lib/libwasmvm.x86_64.so /lib/libwasmvm.x86_64.so

if [ -d /var/lib/osmosis/.osmosisd/cosmovisor/current ]
then
  echo "    Cosmovisor 'current' link in place already"
else
  echo "    Setting Cosmovisor 'current' link to genesis"
  mkdir -p /var/lib/osmosis/.osmosisd/cosmovisor
  ln -s /var/lib/osmosis/.osmosisd/cosmovisor/genesis /var/lib/osmosis/.osmosisd/cosmovisor/current
fi
echo "    Chowning the home dir"
chown -R osmosis:osmosis /var/lib/osmosis
# find /var/lib/osmosis -ls
echo "    Reloading systemd config"
systemctl daemon-reload 
echo "    Done"

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%config(noreplace) /etc/default/cosmovisor@osmosis
/usr/bin/osmosisd-ctl
/usr/bin/osmosis-init-node.sh
%defattr(-,osmosis,osmosis,-)
%dir /var/lib/osmosis/.osmosisd/cosmovisor
%doc

%files -n osmosis-check_mk
%defattr(-,root,root,-)
/usr/bin/osmosis-is-node-ready.sh
/usr/lib/check_mk_agent/local/check_osmosis_block_age.sh
/usr/lib/check_mk_agent/local/check_osmosis_block_data.sh
/usr/lib/check_mk_agent/local/check_osmosis_catching_up.sh
/usr/lib/check_mk_agent/local/check_osmosis_consensus.sh

%changelog
