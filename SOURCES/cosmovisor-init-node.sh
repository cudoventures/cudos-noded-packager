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

export UNM="${1}"

#
# Check for and create the priv-sep username
#
getent group "${UNM}" >/dev/null || groupadd -r "${UNM}" || :
getent passwd "${UNM}" >/dev/null || useradd -c ""${UNM}" User" -g "${UNM}" -s /bin/bash -r -m -d /var/lib/"${UNM}" "${UNM}" 2> /dev/null || :

#
# Check for and create the /etc/default/<chain name> file
#
if [[ -f /etc/default/${UNM}-cosmovisor ]]
then
    echo "INFO Loading existing config in /etc/default/${UNM}-cosmovisor"
else
    echo "INFO Creating /etc/default/${UNM}-cosmovisor"

cat << EOF > /etc/default/${UNM}-cosmovisor
DAEMON_NAME=${UNM}d
DAEMON_HOME=/var/lib/"${UNM}"/."${UNM}"d
DAEMON_RESTART_AFTER_UPGRADE="true"
DAEMON_ALLOW_DOWNLOAD_BINARIES="false"
DAEMON_LOG_BUFFER_SIZE="512"
UNSAFE_SKIP_BACKUP="true"

DAEMON_LOGLEVEL=info
EOF

fi

#
# Check for and create the /etc/profile.d file
#
if [[ -f /etc/profile.d/${UNM}-cosmovisor.sh ]]
then
    echo "INFO Loading existing config in /etc/profile.d/${UNM}-cosmovisor.sh"
else
    echo "INFO Creating /etc/profile.d/${UNM}-cosmovisor.sh"

cat << EOF > /etc/default/${UNM}-cosmovisor
export DAEMON_NAME
export DAEMON_HOME
export DAEMON_RESTART_AFTER_UPGRADE
export DAEMON_ALLOW_DOWNLOAD_BINARIES
export DAEMON_LOG_BUFFER_SIZE
export UNSAFE_SKIP_BACKUP

export DAEMON_LOGLEVEL

EOF

fi

#
# Check for and create the cosmos disk structure for this chain
#
if [[ -d /var/lib/${UNM}/.${UNM}/cosmovisor ]]
then
    echo "INFO Loading chain config in /var/lib/${UNM}/.${UNM}/cosmovisor"
else
    echo "INFO Setting up the /var/lib/${UNM}/.${UNM}/cosmovisor directories"
    mkdir -p /var/lib/${UNM}/.${UNM}d/cosmovisor/upgrades/
    chown -R "${UNM}:${UNM}" /var/lib/${UNM} 
fi
