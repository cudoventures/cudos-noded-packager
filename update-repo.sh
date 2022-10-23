#!/bin/bash -xe
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


# This script is intended for use with a CI/CD package.
# It is designed to be called by the job once the packages
# have been uploaded to the repo server.
#
# It is placed in the target directory of the "end of job upload" and
# executed by changing to that directory and calling ./update-repo.sh
#
# It assumes the current directory is the base of the repository as
# referenced in the respository client configuration (eg cudos.repo)
# 
# It assumes that the rpm packages have been uploaded to the
# usual RPM and SRPM locations and updates the repo index in the current
# directory. 
#
# It assumes that the debian packages were uploaded to a subdirectory
# called debian, distributes them into the appropriate subdirectories
# and runs the relevant indexers
#
# It can be used to maintain separate repositories on the same server using
# different usernames eg user "testnet" for the "cudos-testnet" repository.
# Different credentials and access right can then be used to separate the
# repositories in security terms. The different "repo users" can have full
# control over their "repo tag" on the web service but limited access to
# the rest of the server.

export PWTMP=$1
export RPMLISTFILE=$2
export DEBLISTFILE=$3

#
# RPMS
#

# Sign the rpm files
if [[ -f $PWTMP ]]
then	
  echo -ne "\n== Sign the new packages == \n\n"

# Set the gpg parameters needed
cat << EOF > ~/.gnupg/gpg.conf
status-fd 1
batch
pinentry-mode loopback
passphrase-file ${PWTMP}
EOF

  # Sign the new packages as listed in the file named in ARG2
  rpmsign --delsign `cat ${RPMLISTFILE}`
  rpmsign --addsign `cat ${RPMLISTFILE}`
fi

# Update the rpm repo files
/usr/bin/createrepo --verbose --deltas .

#
# DEBS
#

# lay out the debian files
cd debian
mkdir -p ./dists/stable/main/binary-amd64
mkdir -p ./dists/stable/main/binary-arm64
mkdir -p ./dists/stable/main/binary-i386

mv -v *.deb ./dists/stable/main/binary-amd64 || true

# Run the package scanner
dpkg-scanpackages -m dists/stable/main/binary-amd64 > dists/stable/main/binary-amd64/Packages
dpkg-scanpackages -m dists/stable/main/binary-arm64 > dists/stable/main/binary-arm64/Packages
dpkg-scanpackages -m dists/stable/main/binary-i386  > dists/stable/main/binary-i386/Packages

