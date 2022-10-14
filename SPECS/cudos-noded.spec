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
Summary:      Cosmovisor Node Client Files - cudos

License:      GPL3
URL:          https://github.com/CudoVentures/cudos-node           

Source1:      etc_default_cosmovisor-cudos

Source3:      etc_default_cudos-noded
Source4:      etc_profiled_cudos-noded.sh

Source5:      cudos-init-node.sh
Source6:      cudos-noded-ctl.sh
Source7:      cudos-is-node-ready.sh
Source8:      docker-migrate.sh

Source40:     check_cudos_block_age.sh
Source41:     check_cudos_block_data.sh
Source42:     check_cudos_catching_up.sh
Source43:     check_cudos_block_age_docker.sh
Source44:     check_cudos_block_data_docker.sh
Source45:     check_cudos_catching_up_docker.sh
Source46:     check_cudos_consensus.sh
Source47:     check_cudos_p2p

Source51:     env.sh-tmpl
Source52:     config.yml-tmpl
Source53:     chronocollector-init.sh
Source54:     chronocollector-linux-amd64.gz

Requires:     cosmovisor

%description
Cosmovisor client files for - cudos 
%pre
if getent group cudos >/dev/null
then
  echo "  Group cudos OK"
else
  echo "  Create Group cudos"
  groupadd -r cudos
fi
if getent passwd cudos >/dev/null
then
  echo "  User cudos OK"
else
  echo "  Create User cudos"
  useradd -c "Cudos User" -g cudos -s /bin/bash -r -m -d /var/lib/cudos cudos
fi

%package -n cudos-gex
Summary: Gex - Cosmos Node Monitor App
%description -n cudos-gex
Gex console app

%package -n cudos-p2p-scan
Summary: cudos-p2p-scan
Requires: jq
%description -n cudos-p2p-scan
Stand alone probe for examining PEX ports

%package -n cudos-monitoring
Summary: Cudos Node Monitoring Agents
Requires: bc jq cudos-p2p-scan
%description -n cudos-monitoring
CheckMK and ChronoSphere monitoring agents for Cudos Nodes
%pre -n cudos-monitoring
getent group chronoc >/dev/null || echo "  Create Group chronoc" || groupadd -r chronoc || :
getent passwd chronoc >/dev/null || echo "  Create User chronoc" || useradd -c "Cudos User" -g chronoc -s /bin/bash -r -m -d /var/lib/chronoc chronoc 2> /dev/null || :

%package -n cudos-monitoring-docker
Summary: Cudos Node Monitoring Agents
Requires: bc jq cudos-p2p-scan
%description -n cudos-monitoring-docker
CheckMK and ChronoSphere monitoring agents for Cudos Nodes Using the Docker containers
%pre -n cudos-monitoring-docker
getent group chronoc >/dev/null || groupadd -r chronoc || :
getent passwd chronoc >/dev/null || useradd -c "Cudos User" -g chronoc -s /bin/bash -r -m -d /var/lib/chronoc chronoc 2> /dev/null || :

%prep
echo -e "\n\n=== prep section ===\n\n"

%build
echo -e "\n\n=== build section ===\n\n"

export GOPATH="${RPM_BUILD_DIR}/go"

echo -e "\n\n=== Build and install gex ===\n\n"

go install -v github.com/cosmos/gex@latest

echo -e "\n\n=== Build and install cudos-p2p-scan ===\n\n"

go install -v github.com/CudoVentures/cudos-p2p-scan@latest

%install
echo -e "\n\n=== install section ===\n\n"

# Make the fixed directory structure
mkdir -p ${RPM_BUILD_ROOT}/var/lib/cudos/cudos-data/config
mkdir -p ${RPM_BUILD_ROOT}/var/lib/cudos/cudos-data/cosmovisor
mkdir -p ${RPM_BUILD_ROOT}/etc/default/
mkdir -p ${RPM_BUILD_ROOT}/etc/profile.d/
mkdir -p ${RPM_BUILD_ROOT}/usr/bin/
mkdir -p ${RPM_BUILD_ROOT}/usr/lib/systemd/system
mkdir -p ${RPM_BUILD_ROOT}/lib
mkdir -p ${RPM_BUILD_ROOT}/lib64

mkdir -p ${RPM_BUILD_ROOT}/usr/lib/check_mk_agent/local
mkdir -p ${RPM_BUILD_ROOT}/var/lib/chronoc/bin
mkdir -p ${RPM_BUILD_ROOT}/usr/lib64/nagios/plugins/

# Install the newly built binaries
cp -v ${RPM_BUILD_DIR}/go/bin/gex               ${RPM_BUILD_ROOT}/usr/bin/cosmos-gex
ln -s cosmos-gex                                ${RPM_BUILD_ROOT}/usr/bin/cudos-gex
cp -v ${RPM_BUILD_DIR}/go/bin/cudos-p2p-scan    ${RPM_BUILD_ROOT}/usr/bin/cosmos-p2p-scan
ln -s cosmos-p2p-scan                           ${RPM_BUILD_ROOT}/usr/bin/cudos-p2p-scan

# Install scripts
cp ${RPM_SOURCE_DIR}/cudos-init-node.sh         ${RPM_BUILD_ROOT}/usr/bin/
cp ${RPM_SOURCE_DIR}/cudos-is-node-ready.sh            ${RPM_BUILD_ROOT}/usr/bin/
chmod 755                                              ${RPM_BUILD_ROOT}/usr/bin/*

# Install the files for /usr/lib64/nagios/plugins/
cp ${RPM_SOURCE_DIR}/check_cudos_p2p                   ${RPM_BUILD_ROOT}/usr/lib64/nagios/plugins/
chmod 755                                              ${RPM_BUILD_ROOT}/usr/lib64/nagios/plugins/*

# Install environment setup files
# NB The name change to a cosmovisor is deliberate
#    It ensures only one of the client packages can be installed at any one time
#
cp ${RPM_SOURCE_DIR}/etc_default_cosmovisor-cudos      ${RPM_BUILD_ROOT}/etc/default/cosmovisor

cp ${RPM_SOURCE_DIR}/etc_default_cudos-noded           ${RPM_BUILD_ROOT}/etc/default/cudos-noded
cp ${RPM_SOURCE_DIR}/etc_profiled_cudos-noded.sh       ${RPM_BUILD_ROOT}/etc/profile.d/cudos-noded.sh

# Install systemd service files
cp ${RPM_SOURCE_DIR}/cudos-chronocollector.service     ${RPM_BUILD_ROOT}/usr/lib/systemd/system/

# Install /usr/bin scripts
cp ${RPM_SOURCE_DIR}/cudos-noded-ctl.sh                ${RPM_BUILD_ROOT}/usr/bin/cudos-noded-ctl
chmod 755                                              ${RPM_BUILD_ROOT}/usr/bin/cudos-noded-ctl
cp ${RPM_SOURCE_DIR}/docker-migrate.sh                 ${RPM_BUILD_ROOT}/usr/bin/docker-migrate
chmod 755                                              ${RPM_BUILD_ROOT}/usr/bin/docker-migrate

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

# This script is only needed when there's a chain halt .. so make it 444 until needed
chmod 444                                              ${RPM_BUILD_ROOT}/usr/lib/check_mk_agent/local/check_cudos_consensus.sh

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
rm -f /usr/bin/cudos-noded /lib64/libwasmvm.so /lib/libwasmvm.so || true

ln -s /var/lib/cudos/cudos-data/cosmovisor/current/bin/cudos-noded /usr/bin/cudos-noded
ln -s /var/lib/cudos/cudos-data/cosmovisor/current/lib/libwasmvm.so /lib64/libwasmvm.so
ln -s /var/lib/cudos/cudos-data/cosmovisor/current/lib/libwasmvm.so /lib/libwasmvm.so

if [ -d /var/lib/cudos/.cudosd/. ]
then
  echo "    Cosmovisor '.cudosd' to'cudos-data' link in place already"
else
  echo "    Setting Cosmovisor link '.cudosd' to 'cudos-data'" 
  ln -s /var/lib/cudos/cudos-data /var/lib/cudos/.cudosd
fi
if [ -d /var/lib/cudos/cudos-data/cosmovisor/current ]
then
  echo "    Cosmovisor 'current' link in place already"
else
  echo "    Setting Cosmovisor 'current' link to genesis"
  ln -s /var/lib/cudos/cudos-data/cosmovisor/genesis /var/lib/cudos/cudos-data/cosmovisor/current
fi
echo "    Chowning the home dir"
chown -R cudos:cudos /var/lib/cudos
# find /var/lib/cudos -ls
echo "    Reloading systemd config"
systemctl daemon-reload 
echo "    Done"

%files
%defattr(-,root,root,-)
/etc/default/*
/etc/profile.d/*
/usr/bin/cudos-noded-ctl
/usr/bin/docker-migrate
/usr/bin/cudos-init-node.sh
%defattr(-,cudos,cudos,-)
%dir /var/lib/cudos/cudos-data/cosmovisor
%doc

%files -n cudos-gex
%defattr(-,root,root,-)
/usr/bin/cosmos-gex
/usr/bin/cudos-gex

%files -n cudos-p2p-scan
%defattr(-,root,root,-)
/usr/bin/cosmos-p2p-scan
/usr/bin/cudos-p2p-scan
/usr/lib64/nagios/plugins/check_cudos_p2p

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
