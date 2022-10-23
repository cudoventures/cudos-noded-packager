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

Name:         cudos-release
Version:      %{_versiontag}
Release:      %{_releasetag}%{?dist}
Summary:      Repository Configuration files from Cudo
BuildArch:    noarch
License:      GPL3
URL:          https://github.com/CudoVentures/cudos-noded-packager.git

Source0:      RPM-GPG-KEY-jenkins-cudos
Source1:      RPM-GPG-KEY-prtn-cudos
Source2:      cudos.repo

%description
A bundle of yum/dnf/apt repository configuration files for
the Cudo Blockchain package sets.

%build
echo -e "\n\n=== Build Section ===\n\n"

%install
echo -e "\n\n=== install Section ===\n\n"

# Make the fixed directory structure
mkdir -p ${RPM_BUILD_ROOT}/etc/pki/rpm-gpg
mkdir -p ${RPM_BUILD_ROOT}/etc/yum.repos.d

# Install rpm package public key files
cp ${RPM_SOURCE_DIR}/RPM-GPG-KEY-jenkins-cudos ${RPM_BUILD_ROOT}/etc/pki/rpm-gpg/
cp ${RPM_SOURCE_DIR}/RPM-GPG-KEY-prtn-cudos    ${RPM_BUILD_ROOT}/etc/pki/rpm-gpg/

# Install Yum repo file
cp ${RPM_SOURCE_DIR}/cudos.repo ${RPM_BUILD_ROOT}/etc/yum.repos.d

%files
%defattr(-,root,root,-)
/etc/pki/rpm-gpg/*
/etc/yum.repos.d/*
%doc README.md

%changelog
