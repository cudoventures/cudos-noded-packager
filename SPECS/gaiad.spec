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
# Runs the Cosmos Node Daemon
#

Name:         gaiad
Version:      %{_versiontag}
Release:      %{_releasetag}%{?dist}
Summary:      Cosmos Node Common Files

License:      GPL3
URL:          https://github.com/cosmos/gaia

Source2:      etc_default_cosmovisor-gaia

Requires:     cosmovisor

%description
Cosmovisor Node Common Files - gaia
%pre
if getent group gaia >/dev/null
then
  echo "  Group gaia OK"
else
  echo "  Create Group gaia"
  groupadd -r gaia
fi
if getent passwd gaia >/dev/null
then
  echo "  User gaia OK"
else
  echo "  Create User gaia"
  useradd -c "Cosmos User" -g gaia -s /bin/bash -r -m -d /var/lib/gaia gaia
fi

%package -n gaia-check_mk
Summary: Cosmos Node Monitoring Agents
Requires: bc jq
%description -n gaia-check_mk
CheckMK check_mk agents for Cosmos Nodes
%pre -n gaia-check_mk

%prep
echo -e "\n\n=== prep section ===\n\n"

%build
echo -e "\n\n=== build section ===\n\n"

export GOPATH="${RPM_BUILD_DIR}/go"

%install
echo -e "\n\n=== install section ===\n\n"

# Make the fixed directory structure
mkdir -p ${RPM_BUILD_ROOT}/var/lib/gaia/.gaia/config
mkdir -p ${RPM_BUILD_ROOT}/var/lib/gaia/.gaia/cosmovisor
mkdir -p ${RPM_BUILD_ROOT}/usr/bin
mkdir -p ${RPM_BUILD_ROOT}/etc/default/
mkdir -p ${RPM_BUILD_ROOT}/etc/profile.d/
mkdir -p ${RPM_BUILD_ROOT}/usr/lib/systemd/system

# Install environment setup files
cp ${RPM_SOURCE_DIR}/etc_default_cosmovisor-gaia           ${RPM_BUILD_ROOT}/etc/default/cosmovisor

%clean
# rm -rf $RPM_BUILD_ROOT

%post
if [ $1 = "1" ]
then
    echo "  Install: Setting up links"
else
    echo "  Upgrade: Setting up links"
fi
echo "    Refreshing /usr/bin, /lib and /lib64 links"
rm -f /usr/bin/gaiad /usr/lib/libwasmvm.x86_64.so /lib/libwasmvm.x86_64.so || true

ln -s /var/lib/gaia/.gaia/cosmovisor/current/bin/gaiad /usr/bin/gaiad
ln -s /var/lib/gaia/.gaia/cosmovisor/current/lib/libwasmvm.x86_64.so /usr/lib/libwasmvm.x86_64.so
ln -s /var/lib/gaia/.gaia/cosmovisor/current/lib/libwasmvm.x86_64.so /lib/libwasmvm.x86_64.so

if [ -d /var/lib/gaia/.gaia/cosmovisor/current ]
then
  echo "    Cosmovisor 'current' link in place already"
else
  echo "    Setting Cosmovisor 'current' link to genesis"
  mkdir -p /var/lib/gaia/.gaia/cosmovisor
  ln -s /var/lib/gaia/.gaia/cosmovisor/genesis /var/lib/gaia/.gaia/cosmovisor/current
fi
echo "    Chowning the home dir"
chown -R gaia:gaia /var/lib/gaia
# find /var/lib/gaia -ls
echo "    Reloading systemd config"
systemctl daemon-reload 
echo "    Done"

%files
%defattr(-,root,root,-)
/etc/default/*
%defattr(-,gaia,gaia,-)
%dir /var/lib/gaia/.gaia/cosmovisor
%doc

%changelog
