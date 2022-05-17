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
Source4:      cudos-init-node.sh
Source5:      cudos-noded-ctl.sh
Source6:      cudos-is-node-ready.sh

Source40:     check_cudos_block_age.sh
Source41:     check_cudos_block_data.sh
Source42:     check_cudos_catching_up.sh
Source43:     check_cudos_block_age_docker.sh
Source44:     check_cudos_block_data_docker.sh
Source45:     check_cudos_catching_up_docker.sh
Source46:     check_cudos_consensus.sh

Source51:     env.sh-tmpl
Source52:     config.yml-tmpl
Source53:     chronocollector-init.sh
Source54:     chronocollector-linux-amd64.gz

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

%package -n cudos-gex
Summary: Gex - Cosmos Node Monitor App
%description -n cudos-gex
Gex console app

%package -n cudos-monitoring
Summary: Cudos Node Monitoring Agents
Requires: bc jq
%description -n cudos-monitoring
CheckMK and ChronoSphere monitoring agents for Cudos Nodes
%pre -n cudos-monitoring
getent group chronoc >/dev/null || groupadd -r chronoc || :
getent passwd chronoc >/dev/null || useradd -c "Cudos User" -g chronoc -s /bin/bash -r -m -d /var/lib/chronoc chronoc 2> /dev/null || :

%package -n cudos-monitoring-docker
Summary: Cudos Node Monitoring Agents
Requires: bc jq
%description -n cudos-monitoring-docker
CheckMK and ChronoSphere monitoring agents for Cudos Nodes Using the Docker containers
%pre -n cudos-monitoring-docker
getent group chronoc >/dev/null || groupadd -r chronoc || :
getent passwd chronoc >/dev/null || useradd -c "Cudos User" -g chronoc -s /bin/bash -r -m -d /var/lib/chronoc chronoc 2> /dev/null || :

%prep
echo -e "\n\n=== prep section ===\n\n"
# Unpack tarball

BASEDR="$( pwd )"
tar xzvf %{SOURCE0}

%build
echo -e "\n\n=== build section ===\n\n"

export GOPATH="${RPM_BUILD_DIR}/go"
cd CudosNode
make

echo -e "\n\n=== Build and install gex ===\n\n"

go install -v github.com/cosmos/gex@latest

%install
echo -e "\n\n=== install section ===\n\n"

# Make the fixed directory structure
mkdir -p ${RPM_BUILD_ROOT}/var/lib/cudos/cudos-data/config
mkdir -p ${RPM_BUILD_ROOT}/etc/default/
mkdir -p ${RPM_BUILD_ROOT}/etc/profile.d/
mkdir -p ${RPM_BUILD_ROOT}/usr/bin/
mkdir -p ${RPM_BUILD_ROOT}/usr/lib/systemd/system
mkdir -p ${RPM_BUILD_ROOT}/lib64
mkdir -p ${RPM_BUILD_ROOT}/usr/lib/check_mk_agent/local
mkdir -p ${RPM_BUILD_ROOT}/var/lib/chronoc/bin

# Copy the sources to /var/lib/cudos
cp -rv ${RPM_BUILD_DIR}/Cudos*                         ${RPM_BUILD_ROOT}/var/lib/cudos/

# Copy the newly built binaries into /usr/bin and /usr/lib
cp -v ${RPM_BUILD_DIR}/go/bin/cudos-noded                                          ${RPM_BUILD_ROOT}/usr/bin/
cp -v ${RPM_BUILD_DIR}/go/bin/gex                                                  ${RPM_BUILD_ROOT}/usr/bin/cudos-gex
cp -v ${RPM_SOURCE_DIR}/cudos-init-node.sh                                         ${RPM_BUILD_ROOT}/usr/bin/
cp -v ${RPM_BUILD_DIR}/go/pkg/mod/github.com/'!cosm!wasm'/wasmvm*/api/libwasmvm.so ${RPM_BUILD_ROOT}/usr/lib/
chmod 644                                                                          ${RPM_BUILD_ROOT}/usr/lib/*.so
chmod 755                                                                          ${RPM_BUILD_ROOT}/usr/bin/*.sh

# Install the shell scripts for /usr/bin
cp ${RPM_SOURCE_DIR}/cudos-is-node-ready.sh            ${RPM_BUILD_ROOT}/usr/bin/
chmod 755                                              ${RPM_BUILD_ROOT}/usr/bin/*

# Install environment setup files
cp ${RPM_SOURCE_DIR}/etc_default_cudos-noded           ${RPM_BUILD_ROOT}/etc/default/cudos-noded
cp ${RPM_SOURCE_DIR}/etc_profiled_cudos-noded.sh       ${RPM_BUILD_ROOT}/etc/profile.d/cudos-noded.sh

# Install systemd service file
cp ${RPM_SOURCE_DIR}/*.service                         ${RPM_BUILD_ROOT}/usr/lib/systemd/system/

# Install /usr/bin scripts
cp ${RPM_SOURCE_DIR}/cudos-noded-ctl.sh                ${RPM_BUILD_ROOT}/usr/bin/cudos-noded-ctl
chmod 755                                              ${RPM_BUILD_ROOT}/usr/bin/cudos-noded-ctl

# Install chronocollector files
cp ${RPM_SOURCE_DIR}/chronocollector-linux-amd64.gz    ${RPM_BUILD_ROOT}/var/lib/chronoc/bin
gunzip ${RPM_BUILD_ROOT}/var/lib/chronoc/bin/chronocollector-linux-amd64.gz
cp ${RPM_SOURCE_DIR}/chronocollector-init.sh           ${RPM_BUILD_ROOT}/var/lib/chronoc/bin
cp ${RPM_SOURCE_DIR}/config.yml-tmpl                   ${RPM_BUILD_ROOT}/var/lib/chronoc/
cp ${RPM_SOURCE_DIR}/env.sh-tmpl                       ${RPM_BUILD_ROOT}/var/lib/chronoc/
chmod 755                                              ${RPM_BUILD_ROOT}/var/lib/chronoc/bin/*
chmod 755                                              ${RPM_BUILD_ROOT}/var/lib/chronoc/env.sh-tmpl

# Install check_mk files
cp ${RPM_SOURCE_DIR}/check_cudos_block_age.sh          ${RPM_BUILD_ROOT}/usr/lib/check_mk_agent/local/
cp ${RPM_SOURCE_DIR}/check_cudos_block_data.sh         ${RPM_BUILD_ROOT}/usr/lib/check_mk_agent/local/
cp ${RPM_SOURCE_DIR}/check_cudos_catching_up.sh        ${RPM_BUILD_ROOT}/usr/lib/check_mk_agent/local/
cp ${RPM_SOURCE_DIR}/check_cudos_block_age_docker.sh   ${RPM_BUILD_ROOT}/usr/lib/check_mk_agent/local/
cp ${RPM_SOURCE_DIR}/check_cudos_block_data_docker.sh  ${RPM_BUILD_ROOT}/usr/lib/check_mk_agent/local/
cp ${RPM_SOURCE_DIR}/check_cudos_catching_up_docker.sh ${RPM_BUILD_ROOT}/usr/lib/check_mk_agent/local/
cp ${RPM_SOURCE_DIR}/check_cudos_consensus.sh          ${RPM_BUILD_ROOT}/usr/lib/check_mk_agent/local/
chmod 755                                              ${RPM_BUILD_ROOT}/usr/lib/check_mk_agent/local/*

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
/usr/bin/cudos-noded-ctl
/usr/bin/cudos-init-node.sh
/usr/lib/systemd/system/cudos-noded.service
/usr/lib/*.so
%doc

%files -n cudos-node-src
%defattr(-,cudos,cudos,-)
/var/lib/cudos/Cudos*

%files -n cudos-gex
%defattr(-,root,root,-)
/usr/bin/cudos-gex

%files -n cudos-monitoring
%defattr(-,root,root,-)
/usr/bin/cudos-is-node-ready.sh
/var/lib/chronoc
/usr/lib/systemd/system/cudos-chronocollector.service
/usr/lib/check_mk_agent/local/check_cudos_block_age.sh
/usr/lib/check_mk_agent/local/check_cudos_block_data.sh
/usr/lib/check_mk_agent/local/check_cudos_catching_up.sh
/usr/lib/check_mk_agent/local/check_cudos_consensus.sh

%files -n cudos-monitoring-docker
%defattr(-,root,root,-)
/usr/bin/cudos-is-node-ready.sh
/var/lib/chronoc
/usr/lib/systemd/system/cudos-chronocollector.service
/usr/lib/check_mk_agent/local/check_cudos_block_age_docker.sh
/usr/lib/check_mk_agent/local/check_cudos_block_data_docker.sh
/usr/lib/check_mk_agent/local/check_cudos_catching_up_docker.sh

%changelog
