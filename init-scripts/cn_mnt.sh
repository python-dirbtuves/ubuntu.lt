#!/bin/bash
#
# This helper script will mount linux container file-system.
#
# Author: narunask
# License: MIT license (MIT).
# Original license can be obtained from: http://opensource.org/licenses/MIT
#

# Container root path
_cnroot=$1

# If cnroot hasn't been provided - exit code 1
test -z "${_cnroot}" && { echo error 1; exit 1; }

# If provided but doesn't exist - exit code 2
test -d "${_cnroot}" || { echo error 2; exit 2; }

# Lookup required files and dirs
_mnt=$(find ${_cnroot} -maxdepth 1 -type d -name "mount")
_fs=$(for fs in ext4 ext3; do find ${_cnroot} -maxdepth 1 -type f -name "*.$fs"; done | head -1)

# If either of the required files cannot be obtained - exit code 3
test -z "${_mnt}" -o -z "${_fs}" && { echo error 3; exit 3; }

## If all went well then we are ready to mount
_fstype=$(egrep -o '[[:alnum:]]+$' <<< "${_fs}")

echo "# Initial checks all seem OK"
echo "# Commencing mount process: mount -t ${_fstype} ${_fs} ${_mnt}" && sleep 1
mount -v -t ${_fstype} ${_fs} ${_mnt}
