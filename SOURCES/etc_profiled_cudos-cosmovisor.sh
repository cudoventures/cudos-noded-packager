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
# The CUDOS_HOME variable needs to be set in order to fix the location
# of the config files and database
#
. /etc/default/cudos-cosmovisor

export DAEMON_NAME
export DAEMON_HOME
export DAEMON_RESTART_AFTER_UPGRADE
export DAEMON_ALLOW_DOWNLOAD_BINARIES
export DAEMON_LOG_BUFFER_SIZE
export UNSAFE_SKIP_BACKUP

export DAEMON_LOGLEVEL
