#!/bin/bash -i
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

#
# The cudos_version variable needs to be set in the environment
#
# It is used to
# - select the networks based on the relevant Cudos Node version
#

if [ "$cudos_version" = "" ]
then
    echo "Error: 'cudos_version' variable unset"
    exit 1
fi

#
# BUILD_NUMBER can be inherited from the CI/CD environment and
# represent the serial number of that build for traceability
#
# If unset, tag it with the hostname and datestamp
#
# This is used as
# - The "release_tag" in the rpm packaging
# - The minor release embeded in the cudos-noded binary
#
if [ "$BUILD_NUMBER" = "" ]
then
	BUILD_NUMBER="$( hostname -s ).$( date '+%Y%m%d%H%M%S' )"
fi

#
# Execute the network pack builds relevant for this cudos_version
#

case $cudos_version in

0\.4)
  rpmbuild --define "_topdir $( pwd )" --define "_versiontag ${cudos_version}" --define "_releasetag ${BUILD_NUMBER}" -ba $( pwd )/SPECS/cudos-network-public-testnet.spec
  ;;

0\.6\.0)
  rpmbuild --define "_topdir $( pwd )" --define "_versiontag ${cudos_version}" --define "_releasetag ${BUILD_NUMBER}" -ba $( pwd )/SPECS/cudos-network-dressrehearsal.spec
  ;;

*)
  echo "Unsupported Version '$cudos_version'"
  exit 1
  ;;
  
esac

#
# Feed the rpm binaries into "Alien" to be converted
# to Debian packages
#
mkdir -p debian
cd debian
for FNM in ../RPMS/*/*.rpm
do
   echo -e "\n\nConverting rpm file $FNM to deb package\n\n"
   sudo alien --to-deb --keep-version --scripts $FNM
done
cd ..

#
# Pull the rpm backage information into .txt files
# Pull the file list form the packages into .lst.txt files
#
# These are usesful to store alongside the packages themselves in artifact lists
# So the content and info can easily be opened in the artifact list and viewed
#
for RPMFILE in RPMS/*/*.rpm
do
	rpm -qip $RPMFILE > ${RPMFILE}.txt
	rpm -qlp $RPMFILE > ${RPMFILE}-lst.txt
done
