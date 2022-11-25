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
#

#
# As the correlation between the overall version tag and the tags within the repository
# has varied over time, and to include the development branches in the build mechanism
# this CASE is used to fetch the correct githun tags for the version indicated by the
# "$cudos_version" environment variable.
#
# It is intended for use as a step in a CI/CD chain to solidify the sources into a tarball in
# the conventional location in the rpmbuild tree structure ie ./SOURCES/
#

#
# Define tarball creation function
create_cudos_tarball()
{
    VER="$1"

    echo -e "\n\nCreating $VER Cudos tarball\n\n"

    # Clear out any existing git checkouts
    rm -rf Cudos*

    # Silence the warning
    git config --global advice.detachedHead false
    
    # Check out fresh copies of the current version
    case $VER in

    1.0.1)
      git clone --depth 1 --branch v$VER https://github.com/CudoVentures/cudos-node.git CudosNode
      git clone --depth 1 --branch v$VER https://github.com/CudoVentures/cudos-builders.git CudosBuilders
      git clone --depth 1 --branch v1.0.0 https://github.com/CudoVentures/cosmos-gravity-bridge.git CudosGravityBridge
      ;;
      
    [0-9]\.[0-9]\.[0-9]\.[0-9])
      git clone --depth 1 --branch v$VER https://github.com/CudoVentures/cudos-node.git CudosNode
      git clone --depth 1 --branch v1.0.0 https://github.com/CudoVentures/cudos-builders.git CudosBuilders
      git clone --depth 1 --branch v1.0.0 https://github.com/CudoVentures/cosmos-gravity-bridge.git CudosGravityBridge
      ;;
      
    [0-9]\.[0-9]\.[0-9])
      git clone --depth 1 --branch v$VER https://github.com/CudoVentures/cudos-node.git CudosNode
      git clone --depth 1 --branch v$VER https://github.com/CudoVentures/cudos-builders.git CudosBuilders
      git clone --depth 1 --branch v$VER https://github.com/CudoVentures/cosmos-gravity-bridge.git CudosGravityBridge
      ;;
      
    1.0.master)
      git clone --depth 1 --branch cudos-master https://github.com/CudoVentures/cudos-node.git CudosNode
      git clone --depth 1 --branch cudos-master https://github.com/CudoVentures/cudos-builders.git CudosBuilders
      git clone --depth 1 --branch cudos-master https://github.com/CudoVentures/cosmos-gravity-bridge.git CudosGravityBridge
      ;;
      
    1.0.dev)
      git clone --depth 1 --branch cudos-dev https://github.com/CudoVentures/cudos-node.git CudosNode
      git clone --depth 1 --branch cudos-dev https://github.com/CudoVentures/cudos-builders.git CudosBuilders
      git clone --depth 1 --branch cudos-dev https://github.com/CudoVentures/cosmos-gravity-bridge.git CudosGravityBridge
      ;;
      
    *)
      echo "Unknown Version '$VER'"
      exit 1
      ;;
      
    esac

    tar czf SOURCES/cudos-noded-${VER}.tar.gz Cudos*
    rm -rf Cudos*
}

# Define a utility function for rpmbuild
run_rpmbuild()
{
  VER=$1
  RLS=$2
  SPEC_NAME=$3
  
  echo -ne "\n\n======= Building Package $SPEC_NAME =======\n\n"
  
  rpmbuild \
     --define "_topdir $( pwd )" \
     --define "_versiontag ${VER}" \
     --define "_releasetag ${RLS}" \
     -bs $( pwd )/SPECS/${SPEC_NAME}.spec
  
  sudo rm -rf buildtmp/BUILD buildtmp/BUILDROOT buildtmp/SOURCES buildtmp/SPECS

  rpmbuild \
     --define "_topdir $( pwd )/buildtmp" \
     --define "_versiontag ${VER}" \
     --define "_releasetag ${RLS}" \
     --define "__brp_check_rpaths %{nil}" \
     --rebuild $( pwd )/SRPMS/${SPEC_NAME}-${VER}-${RLS}.*src.rpm
}

# Define toml config tarball function
create_toml_tarball()
{
  FILETAG="$1"
  NTWK="$2"

  echo -e "\n\nCreating TOML tarball '$FILETAG'\n\n"

  mkdir -p toml-tmp
  cd toml-tmp
  wget -4 -q "https://github.com/CudoVentures/cudos-builders/blob/cudos-master/docker/config/genesis.${FILETAG}.json?raw=true"                  -O genesis.json
  wget -4 -q "https://github.com/CudoVentures/cudos-builders/blob/cudos-master/docker/config/persistent-peers.${FILETAG}.config?raw=true"       -O persistent-peers.config
  wget -4 -q "https://github.com/CudoVentures/cudos-builders/blob/cudos-master/docker/config/seeds.${FILETAG}.config?raw=true"                  -O seeds.config
  wget -4 -q "https://github.com/CudoVentures/cudos-builders/blob/cudos-master/docker/config/state-sync-rpc-servers.${FILETAG}.config?raw=true" -O state-sync-rpc-servers.config
  touch unconditional-peers.config
  touch private-peers.config
  tar czvf ../SOURCES/toml-config-${NTWK}.tar.gz *
  cd ..
  rm -rf toml-tmp
}

# define utility to loop through the rpm builds
build_project_from_chain_data()
{
  CHAIN_NAME="$1"
  TMPFILE=/tmp/build.sh.$$

  curl -4 -s https://raw.githubusercontent.com/cosmos/chain-registry/master/${CHAIN_NAME}/chain.json -o "${TMPFILE}"

  CHAIN_NAME="$( cat $TMPFILE | jq .chain_name | tr -d '"' )"
  DAEMON_NAME="$( cat $TMPFILE | jq .daemon_name | tr -d '"' )"
  PRETTY_NAME="$( cat $TMPFILE | jq .pretty_name | tr -d '"' )"
  SYSTEM_VER="$( cat $TMPFILE | jq .codebase.recommended_version | tr -d '"v' )"
  COMPATIBLE_VERSIONS="$( cat $TMPFILE | jq .codebase.compatible_versions | tr -d '"v' | grep '[0-9]' )"

  case "$CHAIN_NAME" in
    cudos)
      DAEMON_NAME="cudos-noded"
      SYSTEM_VER="1.0.1"
      COMPATIBLE_VERSIONS="v0.8.0 v0.9.0 v1.0.1 v1.1.0.1"
      ;;
    osmosis)
      SYSTEM_VER="12.3.0"
      COMPATIBLE_VERSIONS="v11.0.0 v12.3.0 v13.0.0-rc4"
      ;;
  esac
  
  rm -f "${TMPFILE}"

  run_rpmbuild "${SYSTEM_VER}" "${BUILD_NUMBER}" ${DAEMON_NAME}
  for BUILD_VERSION in ${COMPATIBLE_VERSIONS}
  do
    run_rpmbuild "${SYSTEM_VER}" "${BUILD_NUMBER}" ${DAEMON_NAME}-${BUILD_VERSION}
  done
}

#
# Create config tarballs from local repo files
#
cd SOURCES
for FDIR in *-network-*_config
do
  echo -e "\n\nCreating $FDIR tarball\n\n"
  tar -C "${FDIR}" -czvf "${FDIR}.tar.gz" .
done
cd ..

#
# Clear out the old RPM binary files and the old BUILDROOT
#
sudo rm -rf debian RPMS BUILDROOT || true

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
# Copy files up to SOURCES for packaging in src.rpms
#
cp -v README.md  SOURCES
cp -v cudos.repo SOURCES

#
# Create the cudos-noded source tarballs
#
create_cudos_tarball "0.8.0"
create_cudos_tarball "0.9.0"
create_cudos_tarball "1.0.0"
create_cudos_tarball "1.0.1"
create_cudos_tarball "1.1.0.1"

#
# Create the toml config tarballs
#
create_toml_tarball "testnet.private" "private-testnet"
create_toml_tarball "testnet.public"  "testnet"
create_toml_tarball "mainnet"         "mainnet"

#
# Build the spec files
#

#
# Build cosmovisor Project
#
export DAEMON_NAME="cosmovisor"
export SYSTEM_VER="1.0.0"

run_rpmbuild "${SYSTEM_VER}" "${BUILD_NUMBER}" "${DAEMON_NAME}"

#
# Build Cudos Project
#

build_project_from_chain_data cudos

run_rpmbuild "${SYSTEM_VER}" "${BUILD_NUMBER}" cudos-release
run_rpmbuild "${SYSTEM_VER}" "${BUILD_NUMBER}" cudos-network-private-testnet
run_rpmbuild "${SYSTEM_VER}" "${BUILD_NUMBER}" cudos-network-public-testnet
run_rpmbuild "${SYSTEM_VER}" "${BUILD_NUMBER}" cudos-network-mainnet

#
# Build Osmosis Project
#
build_project_from_chain_data osmosis

run_rpmbuild "${SYSTEM_VER}" "${BUILD_NUMBER}" osmosis-network-mainnet
run_rpmbuild "${SYSTEM_VER}" "${BUILD_NUMBER}" osmosis-network-testnet
run_rpmbuild "${SYSTEM_VER}" "${BUILD_NUMBER}" osmosisd

#
# Build Gaia/Cosmos Hub Project
#
build_project_from_chain_data cosmoshub

#
# Feed the rpm binaries into "Alien" to be converted
# to Debian packages
#
# This section also edits in the dependancies which
# alien leaves out
#
mkdir -p debian
cd debian
for FNM in ../buildtmp/RPMS/*/*.rpm
do
   echo -e "\n\nConverting rpm file $FNM to deb package\n\n"
   DEPS="$( rpm -q --requires $FNM | fgrep -v / | fgrep -v '(' | tr '\n' ',' | sed -e's/,$//' )"
   OBSOLETES="$( rpm -q --obsoletes $FNM | fgrep -v / | fgrep -v '(' | tr '\n' ',' | sed -e's/,$//' )"
   DIRNAME="$( rpm -q --queryformat '%{NAME}-%{VERSION}' $FNM || true )"

   echo "Deps: $DEPS"
   echo "Directory: $DIRNAME"

   sudo alien --generate --to-deb --keep-version --scripts $FNM
   sudo sed -i -e's/^Depends:.*/&'",${DEPS}/" ${DIRNAME}/debian/control
   echo -ne "Replaces: ${OBSOLETES}\nConflicts: ${OBSOLETES}\n" | sudo tee -a ${DIRNAME}/debian/control
   cd $DIRNAME
   sudo debian/rules binary
   cd ..
   sudo rm -rf "$DIRNAME"
done
cd ..

#
# Pull the rpm package information into .txt files
# Pull the file lists from the packages into .lst.txt files
#
# These are usesful to store alongside the packages themselves in artifact lists
# So the content and info can easily be opened in the artifact list and viewed
#
for RPMFILE in buildtmp/RPMS/*/*.rpm
do
	rpm -qip $RPMFILE > ${RPMFILE}.txt
	rpm -qlp $RPMFILE > ${RPMFILE}-lst.txt
done
