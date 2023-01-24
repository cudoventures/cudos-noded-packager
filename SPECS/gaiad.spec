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

%global       project_title  CosmosHub
%global       project_url    https://github.com/cosmos/gaia
%global       project_name   gaia

%global       daemon_name    gaiad

%global       username       gaia
%global       data_directory .gaia

#####################################################################
# Do not edit below this line

Name:         %{daemon_name}
Version:      %{_versiontag}
Release:      %{_releasetag}%{?dist}
Summary:      %{project_title} Node Common Files

License:      GPL3
URL:          %{project_url}

Requires:     cosmovisor

%description
%{project_title} Node Common Files
System Version: %{_versiontag}

project_title:  %{project_title}
project_url:    %{project_url}
project_name:   %{project_name}

daemon_name:    %{daemon_name}

username:       %{username}
data_directory: %{data_directory}

%pre
if getent group %{username}>/dev/null
then
  echo "  Group %{username} OK"
else
  echo "  Create Group %{username}"
  groupadd -r %{username}
fi
if getent passwd %{username}>/dev/null
then
  echo "  User %{username} OK"
else
  echo "  Create User %{username}"
  useradd -c "Cosmos User" -g %{username} -s /bin/bash -r -m -d /var/lib/%{username} %{username}
fi

%prep
echo -e "\n\n=== prep section ===\n\n"

%build
echo -e "\n\n=== build section ===\n\n"

export GOPATH="${RPM_BUILD_DIR}/go"

%install
echo -e "\n\n=== install section ===\n\n"

# Make the fixed directory structure
mkdir -p ${RPM_BUILD_ROOT}/var/lib/%{username}/%{data_directory}/config
mkdir -p ${RPM_BUILD_ROOT}/var/lib/%{username}/%{data_directory}/cosmovisor
mkdir -p ${RPM_BUILD_ROOT}/usr/bin
mkdir -p ${RPM_BUILD_ROOT}/etc/default/
mkdir -p ${RPM_BUILD_ROOT}/usr/lib/systemd/system

# Create a daemon environment file from the macro settings
cat <<EOF >${RPM_BUILD_ROOT}/etc/default/cosmovisor@%{username}
DAEMON_NAME=%{daemon_name}
DAEMON_HOME=/var/lib/%{username}/%{data_directory}
DAEMON_RESTART_AFTER_UPGRADE="true"
DAEMON_ALLOW_DOWNLOAD_BINARIES="false"
DAEMON_LOG_BUFFER_SIZE="512"
UNSAFE_SKIP_BACKUP="true"

DAEMON_LOGLEVEL=info
EOF

%clean
rm -rf $RPM_BUILD_ROOT

%post
if [ $1 = "1" ]
then
    echo "  Install: Setting up links"
else
    echo "  Upgrade: Setting up links"
fi
echo "    Refreshing /usr/bin, /lib and /lib64 links"
rm -f /usr/bin/%{daemon_name} /usr/lib/libwasmvm.x86_64.so /lib/libwasmvm.x86_64.so || true

ln -s /var/lib/%{username}/%{data_directory}/cosmovisor/current/bin/%{daemon_name} /usr/bin/%{daemon_name}
ln -s /var/lib/%{username}/%{data_directory}/cosmovisor/current/lib/libwasmvm.x86_64.so /usr/lib/libwasmvm.x86_64.so
ln -s /var/lib/%{username}/%{data_directory}/cosmovisor/current/lib/libwasmvm.x86_64.so /lib/libwasmvm.x86_64.so

if [ -d /var/lib/%{username}/%{data_directory}/cosmovisor/current ]
then
  echo "    Cosmovisor 'current' link in place already"
else
  echo "    Setting Cosmovisor 'current' link to genesis"
  mkdir -p /var/lib/%{username}/%{data_directory}/cosmovisor
  ln -s /var/lib/%{username}/%{data_directory}/cosmovisor/genesis /var/lib/%{username}/%{data_directory}/cosmovisor/current
fi
echo "    Chowning the home dir"
chown -R %{username}:%{username} /var/lib/%{username}
echo "    Reloading systemd config"
systemctl daemon-reload 
echo "    Done"

%files
%defattr(-,root,root,-)
%config(noreplace) /etc/default/cosmovisor@%{username}
%defattr(-,%{username},%{username},-)
%dir /var/lib/%{username}/%{data_directory}/cosmovisor
%doc

%changelog
