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

Name:         hermes
Version:      %{_versiontag}
Release:      %{_releasetag}%{?dist}
Summary:      Hermes Relayer

License:      GPL3
URL:          https://github.com/informalsystems/ibc-rs.git

Source0:      hermes-config.toml
Source1:      check-osmosis-relay.sh

%description
The Hermes rust based IBC relayer
- Hermes version %{version} binary
- Systemd control script
- Simple example check_mk probe script
- Privilege separation user (hermes)

%pre
if getent group hermes >/dev/null
then
  echo "  Group hermes OK"
else
  echo "  Create Group hermes"
  groupadd -r hermes
fi
if getent passwd hermes >/dev/null
then
  echo "  User hermes OK"
else
  echo "  Create User hermes"
  useradd -c "hermes User" -g hermes -s /bin/bash -r -m -d /var/lib/hermes hermes
fi

%build
echo -e "\n\n=== Build Hermes ===\n\n"
git clone https://github.com/informalsystems/ibc-rs.git
cd ibc-rs
git checkout v%{version}
cargo build --release --bin hermes

%clean
rm -rf $RPM_BUILD_ROOT

%install
echo -e "\n\n=== install section ===\n\n"

# Make the fixed directory structure
mkdir -p ${RPM_BUILD_ROOT}/usr/bin
mkdir -p ${RPM_BUILD_ROOT}/usr/lib/systemd/system
mkdir -p ${RPM_BUILD_ROOT}/usr/lib/check_mk_agent/local
mkdir -p ${RPM_BUILD_ROOT}/var/lib/hermes/.hermes/keys

# Install the binary
cp -v ${RPM_BUILD_DIR}/ibc-rs/target/release/hermes  ${RPM_BUILD_ROOT}/usr/bin/

# Install systemd service files
cp ${RPM_SOURCE_DIR}/hermes.service  ${RPM_BUILD_ROOT}/usr/lib/systemd/system/

# Install the check_mk probe
cp ${RPM_SOURCE_DIR}/check-osmosis-relay.sh  ${RPM_BUILD_ROOT}/usr/lib/check_mk_agent/local/

# Install the config file
cp ${RPM_SOURCE_DIR}/hermes-config.toml  ${RPM_BUILD_ROOT}/var/lib/hermes/.hermes/config.toml

%post
if [ $1 = "1" ]
then
    echo "  Install:"
else
    echo "  Upgrade:"
fi

echo "  - Reloading systemd config"
systemctl daemon-reload 

%files
%defattr(-,root,root,-)
/usr/bin/hermes
/usr/lib/systemd/system/hermes.service
/usr/lib/check_mk_agent/local/check-osmosis-relay.sh
%defattr(-,hermes,hermes,-)
%config(noreplace) /var/lib/hermes/.hermes/config.toml
%doc

%changelog
