#!/bin/bash
#
# This helper script will initialise linux container file-system
# (by default sparse 5GB ext4) and create required mount points.
# Then it will attempt to install Debian Wheezy.
#
# Author: narunask
# License: MIT license (MIT).
# Original license can be obtained from: http://opensource.org/licenses/MIT
#

_time0=$(date +%s)

# Container root path
_cnroot="/home/containers"
_name=$1
_size=${2:-5}
_fstype='ext4'

# If name hasn't been provided - exit code 1
test -z "${_name}" && { echo error 1; exit 1; }
_fs="${_name}-fs"

# If size provided isn't an integer - exit code 2
egrep -q '^[[:digit:]]+$' <<< "${_size}" || { echo error 2; exit 2; }

# Calculate container size
_sz=$((10#${_size} * 1024 - 1))
echo -e "\n# Calculated container size: $((_sz + 1)) MB\n"

# Create cnroot and mount points if doesn't exist
_cnpath="${_cnroot}/${_name}"
echo -e "# Creating mount points in: ${_cnpath}..."
mkdir -vp "${_cnpath}/mount"

# Initialise sparse file-system image
_imgpath="${_cnpath}/${_name}-fs.ext4"
echo -e "\n# Initialising image file..."
dd if=/dev/zero bs=1M count=1 seek="$_sz" of="${_imgpath}"

# Build ext4 file-system
echo -e "\n# Building 'ext4' file-system:"
mke2fs -t "${_fstype}" -m0 -L "${_name}" "${_imgpath}"

# Mount this file-system
source cn_mnt.sh "${_cnpath}"

_time1=$(date +%s)
echo -e "\n## Completed in $((_time1 - _time0)) seconds\n"

# Well, now it's time to install Debian Wheezy.
source ./cn_wheezy.sh "${_cnpath}"
