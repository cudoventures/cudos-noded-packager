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
# Runs the Cudos Node Daemon
#

Name:         cudos-noded
Version:      %{_versiontag}
Release:      %{_releasetag}%{?dist}
Summary:      Cudos Full Node

License:      GPL3
URL:          https://github.com/CudoVentures/cudos-node           

Source0:      cudos-noded-%{version}.tar.gz
Source1:      cudos-noded.service
Source2:      etc_default_cudos-noded
Source3:      etc_profiled_cudos-noded.sh

Provides:     libwasmvm.so()(64bit)

BuildRequires: golang

# undefine __brp_mangle_shebangs

%description
Cudos node binary and library
%pre
getent group cudos >/dev/null || groupadd -r cudos || :
getent passwd cudos >/dev/null || useradd -c "Cudos User" -g cudos -s /bin/bash -r -m -d /var/lib/cudos cudos 2> /dev/null || :

%package -n cudos-node-src
Summary: CUDOS Node Sources
Requires: cudos-noded
%description -n cudos-node-src
CUDOS Node Sources

%prep
echo -e "\n\n=== prep section ===\n\n"
# Unpack tarball

BASEDR="$( pwd )"
tar xzvf %{SOURCE0}

%build
echo -e "\n\n=== build section ===\n\n"

export VERSION="%{version}"
export COMMIT=%{release}
cd CudosNode
make

%install
echo -e "\n\n=== install section ===\n\n"

# Make the fixed directory structure
mkdir -p ${RPM_BUILD_ROOT}/var/lib/cudos/cudos-data/config
mkdir -p ${RPM_BUILD_ROOT}/etc/default/
mkdir -p ${RPM_BUILD_ROOT}/etc/profile.d/
mkdir -p ${RPM_BUILD_ROOT}/usr/bin/
mkdir -p ${RPM_BUILD_ROOT}/usr/lib/systemd/system
mkdir -p ${RPM_BUILD_ROOT}/lib64

# Copy the sources to /var/lib/cudos
cp -rv ${RPM_BUILD_DIR}/Cudos*                         ${RPM_BUILD_ROOT}/var/lib/cudos/

# Copy the newly built binaries into /usr/bin and /usr/lib
cp -v ${RPM_BUILD_DIR}/go/bin/cudos-noded                                         ${RPM_BUILD_ROOT}/usr/bin/
cp -v ${RPM_BUILD_DIR}'/go/pkg/mod/github.com/!cosm!wasm/wasmvm/api/libwasmvm.so' ${RPM_BUILD_ROOT}/usr/lib/
chmod 644                                                                         ${RPM_BUILD_ROOT}/usr/lib/*.so

# Install environment setup files
cp ${RPM_SOURCE_DIR}/etc_default_cudos-noded           ${RPM_BUILD_ROOT}/etc/default/cudos-noded
cp ${RPM_SOURCE_DIR}/etc_profiled_cudos-noded.sh       ${RPM_BUILD_ROOT}/etc/profile.d/cudos-noded.sh

# Install systemd service file
cp ${RPM_SOURCE_DIR}/*.service                         ${RPM_BUILD_ROOT}/usr/lib/systemd/system/

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
%defattr(-,root,root,-)
/etc/default/*
/etc/profile.d/*
/usr/bin/cudos-noded
/usr/lib/systemd/system/cudos-noded.service
/usr/lib/*
%doc

%files -n cudos-node-src
%defattr(-,cudos,cudos,-)
/var/lib/cudos/Cudos*

%changelog
