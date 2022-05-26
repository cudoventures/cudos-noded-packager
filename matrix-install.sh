#!/bin/bash
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
# This script is intended for use with a CI/CD package.
# It will be called multiple times in parallel, once for
# each combination of possible values for the environment variables:
#  - matrix_platform
#  - matrix_node_type
#  - matrix_cudos_network
#

#
# Print out the values of the above variables for the nenefit of the
# log in this CI/CD subtask
#
echo -ne "\n\n======== Job Variables ==========\n"
echo -ne "Platform Tag:   $matrix_platform\n"
echo -ne "Node Type:      $matrix_node_type\n"
echo -ne "Cudos Network:  $matrix_cudos_network\n"
echo -ne "=================================\n\n"

#
# Source all the include files in matrix-install.d/
#
# These files contain individual platform install function
# definitions for low level install functions
#
# These take arguments:
#   - Cudos Network
#   - Node Type
#
# The name of the include file should be of the form:
#   def-<platform tag>-install.incl.sh
#
# For example def-centos8-docker-install.incl.sh
#
# The file must contain a function definition of the form:
#   <platform tag>-install()
#
# For example centos8-docker-install()
#
# The Matrix variable $matrix_platform sets the platform tag
# and will result in the job being executed on a GCE Cloud Agent 
# of the form:
#   gce-<platform tag>
#
# For example gce-centos8-docker
#
# NB As the docker and native installs are so different and docker is
#    restricted to a small subset of the intended platforms, there
#    will be a GCE Cloud Agent for each of them, along with an
#    associated include file with a matching file and function name,
#    currently including:
#     - gce-centos8-builder
#     - gce-centos8-docker
#     - gce-ubuntu2004-docker
# 
for FNM in matrix-install.d/*.incl.sh
do
	source $FNM
done

${matrix_platform}-install $matrix_cudos_network $matrix_node_type

