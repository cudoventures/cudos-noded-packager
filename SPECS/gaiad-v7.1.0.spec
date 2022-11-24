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

Version:      %{_versiontag}
Name:         gaiad-v7.1.0
Release:      %{_releasetag}%{?dist}
Summary:      Cosmos Node Binary Pack for v7.1.0

License:      GPL3
URL:          https://github.com/cosmos/gaia

Requires:     gaiad

Obsoletes:    gaiad-v7.0.0

%description
Cosmos Node binary and library

Installed into the Cosmovisor directories

%pre
getent group gaia >/dev/null || echo "  Create Group gaia" || groupadd -r gaia || :
getent passwd gaia >/dev/null || echo "  Create User gaia"  useradd -c "Cosmos User" -g gaia -s /bin/bash -r -m -d /var/lib/gaia gaia 2> /dev/null || :

%prep
echo -e "\n\n=== prep section ===\n\n"

%build
echo -e "\n\n=== build section ===\n\n"
export GOPATH="${RPM_BUILD_DIR}/go"

rm -rf gaia
git clone https://github.com/cosmos/gaia
cd gaia
git checkout v7.1.0
echo -e "\n\n***** Build Cosmos Daemon *****\n\n"
make install
echo -e "\n\n***** Run Cosmos Daemon Self Test *****\n\n"
make test || true

%install
echo -e "\n\n=== install section ===\n\n"

# Make the fixed directory structure
mkdir -p ${RPM_BUILD_ROOT}/var/lib/gaia/.gaia/cosmovisor/upgrades/v7.1.0/bin
mkdir -p ${RPM_BUILD_ROOT}/var/lib/gaia/.gaia/cosmovisor/upgrades/v7.1.0/lib/

# Install the newly built binaries
cp -v ${RPM_BUILD_DIR}/gaia/build/gaiad                                                             ${RPM_BUILD_ROOT}/var/lib/gaia/.gaia/cosmovisor/upgrades/v7.1.0/bin/
cp -v ${RPM_BUILD_DIR}'/go/pkg/mod/github.com/!cosm!wasm/wasmvm@'v*.*.*/internal/api/libwasmvm.x86_64.so  ${RPM_BUILD_ROOT}/var/lib/gaia/.gaia/cosmovisor/upgrades/v7.1.0/lib/
chmod 644  ${RPM_BUILD_ROOT}/var/lib/gaia/.gaia/cosmovisor/upgrades/v7.1.0/lib/*

%files
%defattr(-,gaia,gaia,-)
/var/lib/gaia/.gaia/cosmovisor/*
%doc

%changelog
