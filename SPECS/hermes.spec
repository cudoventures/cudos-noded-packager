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
Version:      1.0.0
Release:      %{_releasetag}%{?dist}
Summary:      Hermes Relayer

License:      GPL3
URL:          https://github.com/informalsystems/ibc-rs.git

%description
The Hermes rust based IBC relayer

%build
echo -e "\n\n=== Build Hermes ===\n\n"
git clone https://github.com/informalsystems/ibc-rs.git
cd ibc-rs
git checkout v%{version}
cargo build --release --bin hermes

%install
echo -e "\n\n=== install section ===\n\n"

# Make the fixed directory structure
mkdir -p ${RPM_BUILD_ROOT}/usr/bin
mkdir -p ${RPM_BUILD_ROOT}/usr/lib/systemd/system

# Install the binary
cp -v ${RPM_BUILD_DIR}/ibc-rs/target/release/hermes  ${RPM_BUILD_ROOT}/usr/bin/

# Install systemd service files
cp ${RPM_SOURCE_DIR}/hermes.service  ${RPM_BUILD_ROOT}/usr/lib/systemd/system/

%files
%defattr(-,root,root,-)
/usr/bin/hermes
/usr/lib/systemd/system/hermes.service
%doc

%changelog
