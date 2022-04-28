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
##
#
# NB This script is intended to be run from a CI/CD environment like Jenkins.
# It builds the rpm and deb packages relevant for specific Cudos Node code
# release version tags, generally the ones that have active chains.
# 

#
# The cudos_version variable needs to be set in the environment
#
# It is used:
# - To select the networks based on the relevant Cudos Node version
# - As the version embedded in the cudos-noded binary by passing it
#   through to the rpmbuild process.
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
# - The "_releasetag" in the rpm packaging
# - The minor release embedded in the cudos-noded binary
#
if [ "$BUILD_NUMBER" = "" ]
then
	BUILD_NUMBER="$( hostname -s ).$( date '+%Y%m%d%H%M%S' )"
fi

#
# Execute the network pack builds relevant for this cudos_version
#

# Define a utiity function
run_rpmbuild()
{
  VER=$1
  RLS=$2
  PACK_NAME=$3
  
  rpmbuild \
     --define "_topdir $( pwd )" \
     --define "_versiontag ${VER}" \
     --define "_releasetag ${RLS}" \
     -ba $( pwd )/SPECS/cudos-network-${PACK_NAME}.spec
}

case $cudos_version in
  0\.4)
    run_rpmbuild "${cudos_version}" "${BUILD_NUMBER}" "public-testnet"
    ;;

  0\.6\.0)
    run_rpmbuild "${cudos_version}" "${BUILD_NUMBER}" "dressrehearsal"
    ;;

  0\.7\.0)
    run_rpmbuild "${cudos_version}" "${BUILD_NUMBER}" "private-testnet"
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
