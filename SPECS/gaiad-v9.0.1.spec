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

%global project_title  CosmosHub
%global parent_url     https://github.com/cosmos
%global project_name   gaia

%global daemon_name    gaiad
%global daemon_version v9.0.1
%global upgrade_name   v9.0.1
%global obsoletes      gaiad-v0.0.0

%global username       gaia
%global data_directory .gaia

#####################################################################
# Do not edit below this line

Version:      %{_versiontag}
Name:         %{daemon_name}-%{daemon_version}
Release:      %{_releasetag}%{?dist}
Summary:      %{project_title} Node Daemon - Version %{daemon_version}

License:      GPL3
URL:          %{parent_url}/%{project_name}

Requires:     %{daemon_name}

Obsoletes:    %{obsoletes}

%description
System Version: %{_versiontag}

project_title:  %{project_title}
parent_url:     %{parent_url}
project_name:   %{project_name}

daemon_name:    %{daemon_name}
daemon_version: %{daemon_version}
upgrade_name:   %{upgrade_name}
obsoletes:      %{obsoletes}

username:       %{username}
data_directory: %{data_directory}

This package contains the files common
to all versions of the %{project_name}
node software

NB This package does not contain any
   genesis or node configuration information

%pre
getent group %{username} >/dev/null || echo "  Create Group %{username}" || groupadd -r %{username} || :
getent passwd %{username} >/dev/null || echo "  Create User %{username}"  useradd -c "%{project_title} Daemon User" -g %{username} -s /bin/bash -r -m -d /var/lib/%{username} %{username} 2> /dev/null || :

%prep
echo -e "\n\n=== prep section ===\n\n"

%build
echo -e "\n\n=== build section ===\n\n"
export GOPATH="${RPM_BUILD_DIR}/go"

rm -rf %{project_name}
git clone -b %{daemon_version} %{parent_url}/%{project_name}
cd %{project_name}
echo -e "\n\n***** Build %{project_title} Daemon *****\n\n"
make install
echo -e "\n\n***** Run %{project_title} Daemon Self Test *****\n\n"
make test || true

%install
echo -e "\n\n=== install section ===\n\n"

# Make the fixed directory structure
mkdir -p ${RPM_BUILD_ROOT}/var/lib/%{username}/%{data_directory}/cosmovisor/upgrades/%{upgrade_name}/bin
#mkdir -p ${RPM_BUILD_ROOT}/var/lib/%{username}/%{data_directory}/cosmovisor/upgrades/%{upgrade_name}/lib/

# Install the newly built binaries
cp -v ${RPM_BUILD_DIR}/go/bin/%{daemon_name} ${RPM_BUILD_ROOT}/var/lib/%{username}/%{data_directory}/cosmovisor/upgrades/%{upgrade_name}/bin/

#cp -v ${RPM_BUILD_DIR}'/go/pkg/mod/github.com/!cosm!wasm/wasmvm@'v*.*.*/internal/api/libwasmvm.x86_64.so  ${RPM_BUILD_ROOT}/var/lib/%{username}/%{data_directory}/cosmovisor/upgrades/%{upgrade_name}/lib/
#chmod 644  ${RPM_BUILD_ROOT}/var/lib/%{username}/%{data_directory}/cosmovisor/upgrades/%{upgrade_name}/lib/*

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,%{username},%{username},-)
/var/lib/%{username}/%{data_directory}/cosmovisor/*
%doc

%changelog
